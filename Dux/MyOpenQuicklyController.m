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
@synthesize query;
@synthesize resultsTableView;
@synthesize progressIndicator;

- (id)initWithWindow:(NSWindow *)window
{
  self = [super initWithWindow:window];
  if (self) {
    self.searchPath = [[NSUserDefaults standardUserDefaults] stringForKey:@"OpenQuicklySearchPath"];
    
    self.query = nil;
  }
  
  return self;
}

- (void)dealloc
{
  self.query = nil;
  
}

- (NSMetadataQuery *)query
{
  return query;
}

- (void)setQuery:(NSMetadataQuery *)newQuery
{
  if (query) {
    [query stopQuery];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:query];
  }
  
  query = newQuery;
  
  if (query)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryProgressChange:) name:nil object:query];
}

- (void)showOpenQuicklyPanel
{
  [self.openQuicklyWindow makeKeyAndOrderFront:self];
  [self.searchField becomeFirstResponder];
  
  [self performSearch:self];
}

- (IBAction)performSearch:(id)sender
{
  if (self.query) {
    [self.query stopQuery];
  } else {
    self.query = [[NSMetadataQuery alloc] init];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:(id)kMDItemLastUsedDate ascending:NO];
    NSArray *descriptors = [NSArray arrayWithObject:sortDescriptor];
    [self.query setSortDescriptors:descriptors];
  }
  
  if (self.searchField.stringValue.length == 0) {
    return;
  }
  
  // limit scope to search in path
  [[NSUserDefaults standardUserDefaults] setValue:self.searchPath forKey:@"OpenQuicklySearchPath"];
  NSString *resolvedSerachPath = [self.searchPath stringByStandardizingPath];
  if (resolvedSerachPath && resolvedSerachPath.length != 0) {
    [self.query setSearchScopes:[NSArray arrayWithObject:resolvedSerachPath]];
  }
  
  // build filename search pattern "*f*o*o*" for search string of "foo"
  NSMutableString *searchString = [NSMutableString stringWithString:@"*"];
  for (int charPos = 0; charPos < self.searchField.stringValue.length; charPos++) {
    [searchString appendFormat:@"%@*", [self.searchField.stringValue substringWithRange:NSMakeRange(charPos, 1)]];
  }
        
  // build predicate
  NSPredicate *predicate = [NSPredicate predicateWithFormat: @"((kMDItemContentTypeTree == 'public.data') AND (kMDItemFSName LIKE[cd] %@))", searchString];
  [self.query setPredicate:predicate];
  
  [self.query startQuery];
}

- (IBAction)cancel:(id)sender
{
  self.query = nil;
  [self.window performClose:sender];
}

- (IBAction)open:(id)sender
{
  if ([self.query resultCount] > 0) {
    NSString *resultPath = [[self.query resultAtIndex:self.resultsTableView.selectedRow] valueForKey:@"kMDItemPath"];
    
    [self openResult:resultPath];
  }
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
  }];
}

- (void)openResult:(id)path
{
  [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:[NSURL fileURLWithPath:path] display:YES completionHandler:NULL];
  
  self.query = nil;
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
      
      if (nextIndex >= self.query.resultCount)
        nextIndex = 0;
      
      [self.resultsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:nextIndex] byExtendingSelection:NO];
      [self.resultsTableView scrollRowToVisible:nextIndex];
      
      return YES;
    }
    
    if (commandSelector == @selector(moveUp:)) {
      NSInteger nextIndex = self.resultsTableView.selectedRow - 1;
      
      if (nextIndex < 0)
        nextIndex = 0;
      
      [self.resultsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:nextIndex] byExtendingSelection:NO];
      [self.resultsTableView scrollRowToVisible:nextIndex];
      
      return YES;
    }
  }
  
  return NO;
}

- (void)queryProgressChange:(NSNotification *)notification
{
  if ([notification.name isEqualToString:NSMetadataQueryDidStartGatheringNotification]) {
    [self.progressIndicator startAnimation:self];
  } else if ([notification.name isEqualToString:NSMetadataQueryDidFinishGatheringNotification]) {
    [self.progressIndicator stopAnimation:self];
  }
}

- (void)windowWillClose:(NSNotification *)notification
{
  self.query = nil;
}

@end
