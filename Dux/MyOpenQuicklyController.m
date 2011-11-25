//
//  MyOpenQuicklyController.m
//  Dux
//
//  Created by Abhi Beckert on 2011-08-25.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import "MyOpenQuicklyController.h"

@implementation MyOpenQuicklyController

@synthesize searchField;
@synthesize searchPathField;
@synthesize searchPath;
@synthesize openQuicklyWindow;
@synthesize resultsTableView;
@synthesize progressIndicator;
@synthesize searchPaths;
@synthesize searchResultPaths;
@synthesize directoryNamesToSkip;

- (id)initWithWindow:(NSWindow *)window
{
  self = [super initWithWindow:window];
  if (self) {
    self.searchResultPaths = [NSArray array];
    self.directoryNamesToSkip = [NSArray arrayWithObjects:@".svn", @"tmp", nil];
    
    // load search path from user defaults
    self.searchPath = [[NSUserDefaults standardUserDefaults] stringForKey:@"OpenQuicklySearchPath"];
    self.searchPaths = [NSArray array];
    
    // Due to app sandboxing, we don't have access to a path until the user selects that
    // path in an NSOpenPanel. The permission to access a path does not survive across
    // app launches as of Mac OS X 10.7.2, however I've seen references that this feature
    // will be implemented at some future point, so we only throw the path away if it
    // actually isn't writable.
    if (self.searchPath && ![[NSFileManager defaultManager] isWritableFileAtPath:self.searchPath]) {
      self.searchPath = nil;
    }
  }
  
  return self;
}

- (void)showOpenQuicklyPanel
{
  [self.openQuicklyWindow makeKeyAndOrderFront:self];
  [self.searchField becomeFirstResponder];
  
  [self updateSearchPaths];
}

- (IBAction)performSearch:(id)sender
{
  // has the search path field's value changed?
  if (![self.searchPathField.stringValue isEqualToString:self.searchPath]) {
    self.searchPath = self.searchPathField.stringValue;
    [self updateSearchPaths]; // this will call performSearch as it finds search path
    return;
  }
  
  // empty search string?
  if (self.searchField.stringValue.length == 0) {
    return;
  }
  
  // build regex pattern from search string
  NSMutableString *searchPattern = [NSMutableString stringWithString:@"\\/[^/]*"];
  NSString *operatorChars = @"*?+[(){}^$|\\./";
  for (int charPos = 0; charPos < self.searchField.stringValue.length; charPos++) {
    NSString *character = [self.searchField.stringValue substringWithRange:NSMakeRange(charPos, 1)];
    
    if ([operatorChars rangeOfString:character].location != NSNotFound)
      character = [NSString stringWithFormat:@"\\%@", character];
    
    [searchPattern appendFormat:@"%@[^/]*", character];
  }
  [searchPattern appendString:@"$"];
  
  NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:searchPattern options:NSRegularExpressionCaseInsensitive error:NULL];
  
  NSMutableArray *mutableSearchResults = [NSMutableArray array];
  for (NSString *path in self.searchPaths) {
    if ([expression rangeOfFirstMatchInString:path options:0 range:NSMakeRange(0, path.length)].location == NSNotFound)
      continue;
    
    [mutableSearchResults addObject:path];
  }
  [mutableSearchResults sortUsingComparator:(NSComparator)^(id leftObj, id rightObj) {
    return [[(NSString *)leftObj lastPathComponent] compare:[(NSString *)rightObj lastPathComponent]];
  }];
  
  self.searchResultPaths = [mutableSearchResults copy];
}

- (IBAction)cancel:(id)sender
{
  [self.window performClose:sender];
}

- (IBAction)open:(id)sender
{
  if (self.searchResultPaths.count == 0)
    return;
  
  NSString *resultPath = [self.searchResultPaths objectAtIndex:self.resultsTableView.selectedRow];
  
  [self openResult:resultPath];
}

- (IBAction)browseForSearchIn:(id)sender
{
  NSOpenPanel *panel = [NSOpenPanel openPanel];
  [panel setCanChooseFiles:NO];
  [panel setCanChooseDirectories:YES];
  [panel setAllowsMultipleSelection:NO];
  
  [panel beginWithCompletionHandler:^(NSInteger buttonClicked){
    if (buttonClicked == NSFileHandlingPanelCancelButton)
      return;
    
    self.searchPath = [[panel.URL path] stringByAbbreviatingWithTildeInPath];
    [[NSUserDefaults standardUserDefaults] setValue:self.searchPath forKey:@"OpenQuicklySearchPath"];
    [self updateSearchPaths];
  }];
}

- (void)updateSearchPaths
{
  // init
  self.searchPaths = [NSArray array];
  
  if (!self.searchPath || self.searchPath.length == 0 || [self.searchPath isEqualToString:@"(select search path)"]) {
    self.searchPathField.stringValue = @"(select search path)";
    return;
  }
  
  [self.progressIndicator startAnimation:self];
  
  // enumerate all the files in the path
  NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtURL:[NSURL fileURLWithPath:self.searchPath] includingPropertiesForKeys:[NSArray arrayWithObject:NSURLIsDirectoryKey] options:0 errorHandler:nil];
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSMutableArray *scratchSearchPaths = [NSMutableArray arrayWithCapacity:200];
    
    for (NSURL *fileURL in enumerator) {
      // is this a directory?
      NSNumber *isDirectory = nil;
      if ([fileURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL] && [isDirectory boolValue]) {
        
        // do not enumerate specific subpaths
        if ([self.directoryNamesToSkip containsObject:[fileURL lastPathComponent]]) {
          [enumerator skipDescendants];
        }
        
        // do not add directories to the list of search pathns
        continue;
      }
      
      // add this to a scratch list of search paths
      [scratchSearchPaths addObject:fileURL.path];
      
      // when the scratch has 200 items, add them to the real seacrh paths and refresh the search results
      if (scratchSearchPaths.count == 200) {
        self.searchPaths = [self.searchPaths arrayByAddingObjectsFromArray:scratchSearchPaths];
        scratchSearchPaths = [NSMutableArray arrayWithCapacity:200];
        
        [self performSearch:self];
      }
    }
    
    // add the final items in the scratch to the search paths, refresh the search, and stop the animation
    dispatch_sync(dispatch_get_main_queue(), ^{
      if (scratchSearchPaths.count > 0) {
        self.searchPaths = [self.searchPaths arrayByAddingObjectsFromArray:scratchSearchPaths];
        
        [self performSearch:self];
      }
      
      [self.progressIndicator stopAnimation:self];
    });
  });
}

- (void)openResult:(id)path
{
  [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:[NSURL fileURLWithPath:path] display:YES completionHandler:NULL];
  
  [self.window performClose:self];
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector
{
  if (control == self.searchField || control == self.searchPathField) {
    if (commandSelector == @selector(insertNewline:)) {
      [self open:control];
      return YES;
    }
    
    if (commandSelector == @selector(cancelOperation:)) {
      [self cancel:control];
      return YES;
    }
    
    if (commandSelector == @selector(moveDown:)) {
      NSInteger nextIndex = self.resultsTableView.selectedRow + 1;
      
      if (nextIndex >= self.searchResultPaths.count)
        nextIndex = 0;
      
      [self.resultsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:nextIndex] byExtendingSelection:NO];
      [self.resultsTableView scrollRowToVisible:nextIndex];
      
      return YES;
    }
    
    if (commandSelector == @selector(moveUp:)) {
      NSInteger nextIndex = self.resultsTableView.selectedRow - 1;
      
      if (nextIndex < 0)
        nextIndex = self.searchResultPaths.count - 1;
      
      [self.resultsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:nextIndex] byExtendingSelection:NO];
      [self.resultsTableView scrollRowToVisible:nextIndex];
      
      return YES;
    }
  }
  
  return NO;
}

@end
