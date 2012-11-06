//
//  DuxMultiFileSearchWindowController.m
//  Dux
//
//  Created by Abhi Beckert on 2012-11-6.
//
//

#import "DuxMultiFileSearchWindowController.h"
#import "DuxPreferences.h"

@interface DuxMultiFileSearchWindowController ()

@property (strong) NSArray *searchPaths; // list of every subpath in available in the open quickly panel
@property (strong) NSArray *searchResultPaths;
@property (strong) NSOperationQueue *updateResultsQueue;

@property (strong) NSArray *directoryNamesToSkip; // array of directories to skip when doing a search (eg: @".svn")

@end

@implementation DuxMultiFileSearchWindowController

- (id)initWithWindowNibName:(NSString *)windowNibName
{
  if (!(self = [super initWithWindowNibName:windowNibName]))
    return nil;
  
  self.searchResultPaths = [NSArray array];
  self.directoryNamesToSkip = [NSArray arrayWithObjects:@".svn", @"tmp", nil];
  
  // load search path from user defaults
  
  self.updateResultsQueue = [[NSOperationQueue alloc] init];
  self.updateResultsQueue.maxConcurrentOperationCount = 1;
  
  return self;
}

- (void)windowDidLoad
{
  [super windowDidLoad];
}

- (void)showWindow:(id)sender
{
  [super showWindow:sender];
  
  [self.searchField becomeFirstResponder];
  self.searchPath = [[NSUserDefaults standardUserDefaults] stringForKey:@"OpenQuicklySearchPath"];
  self.searchPaths = [NSArray array];
  
  [self updateSearchPaths];
}
- (IBAction)performSearch:(id)sender
{
  // has the search path field's value changed?
  if (![self.searchPathControl.stringValue isEqualToString:self.searchPath]) {
    self.searchPath = self.searchPathControl.stringValue;
    [self updateSearchPaths]; // this will call performSearch as it finds search path
    return;
  }
  
  // empty search string?
  NSString *searchString = self.searchField.stringValue;
  if (searchString.length == 0) {
    self.searchResultPaths = [NSArray array];
    return;
  }
  
  // clear selection
  [self.resultsTableView deselectAll:self];
  
//  // build regex pattern from search string
//  NSMutableString *searchPattern = [NSMutableString stringWithString:@"\\/[^/]*"];
//  NSString *operatorChars = @"*?+[(){}^$|\\./";
//  for (int charPos = 0; charPos < searchString.length; charPos++) {
//    NSString *character = [searchString substringWithRange:NSMakeRange(charPos, 1)];
//    
//    if ([operatorChars rangeOfString:character].location != NSNotFound)
//      character = [NSString stringWithFormat:@"\\%@", character];
//    
//    [searchPattern appendFormat:@"%@[^/]*", character];
//  }
//  [searchPattern appendString:@"$"];
//  
//  NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:searchPattern options:NSRegularExpressionCaseInsensitive error:NULL];
  
  // cancel the operation queue
  [self.updateResultsQueue cancelAllOperations];
  [self.updateResultsQueue waitUntilAllOperationsAreFinished];
  
  NSArray *operationSearchPaths = [self.searchPaths copy];
  DuxMultiFileSearchWindowController *blockSelf = self; // avoid retain cycle warnings
  
  __block NSBlockOperation *updateResultsBlock = [NSBlockOperation blockOperationWithBlock:^{
    NSMutableArray *mutableSearchResults = [NSMutableArray array];
    NSDate *lastUIUpdate = [NSDate date]; // when this hits 1/30th of a second ago, we update the GUI
    BOOL haveNewResults = YES;
    
    [blockSelf.progressIndicator setIndeterminate:NO];
    blockSelf.progressIndicator.maxValue = operationSearchPaths.count;
    blockSelf.progressIndicator.doubleValue = 0;
    [blockSelf.progressIndicator startAnimation:self];
    
    for (NSURL *url in operationSearchPaths) {
      if (updateResultsBlock.isCancelled)
        break;
      
      if ([lastUIUpdate timeIntervalSinceNow] < -0.033) { // update GUI after 1/30th of a second
        if (haveNewResults) {
          dispatch_async(dispatch_get_main_queue(), ^{
            BOOL wasNoSelection = blockSelf.resultsTableView.selectedRow == -1;
            blockSelf.searchResultPaths = [mutableSearchResults copy];
            if (wasNoSelection)
              [blockSelf.resultsTableView deselectAll:blockSelf];
          });
          if (updateResultsBlock.isCancelled)
            break;
          
          haveNewResults = NO;
        }
        
        lastUIUpdate = [NSDate date];
      }
      
      NSString *fileContents = [NSString stringWithContentsOfURL:url usedEncoding:NULL error:NULL];
      if (!fileContents || [fileContents rangeOfString:searchString options:NSCaseInsensitiveSearch].location == NSNotFound) {
        [blockSelf.progressIndicator incrementBy:1];
        continue;
      }
      
//      NSUInteger urlIndex = [mutableSearchResults indexOfObject:url inSortedRange:NSMakeRange(0, mutableSearchResults.count) options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(NSURL *leftObj, NSURL *rightObj) {
//        NSString *leftLastPathComponent = leftObj.lastPathComponent;
//        NSUInteger leftLength = leftLastPathComponent.length;
//        
//        NSString *rightLastPathComponent = rightObj.lastPathComponent;
//        NSUInteger rightLength = rightLastPathComponent.length;
//        
//        if (leftLength < rightLength) {
//          return -1;
//        } else if (leftLength > rightLength) {
//          return 1;
//        } else {
//          return [leftLastPathComponent compare:rightLastPathComponent];
//        }
//      }];
//      [mutableSearchResults insertObject:url atIndex:urlIndex];
      [mutableSearchResults addObject:url];
      haveNewResults = YES;
      
      [blockSelf.progressIndicator incrementBy:1];
    }
    [blockSelf.progressIndicator setIndeterminate:YES];
    
    if (updateResultsBlock.isCancelled)
      return;
    
    if (haveNewResults) {
      dispatch_async(dispatch_get_main_queue(), ^{
        BOOL wasNoSelection = blockSelf.resultsTableView.selectedRow == -1;
        blockSelf.searchResultPaths = [mutableSearchResults copy];
        if (wasNoSelection)
          [blockSelf.resultsTableView deselectAll:blockSelf];
      });
    }
  }];
  [self.updateResultsQueue addOperation:updateResultsBlock];
}

- (IBAction)cancel:(id)sender
{
  [self.window performClose:sender];
}

- (IBAction)open:(id)sender
{
  if (self.searchResultPaths.count == 0)
    return;
  
  NSInteger selectedRow = self.resultsTableView.selectedRow;
  if (selectedRow == -1)
    selectedRow = 0; // if no selection, use 1st row instead
  
  NSURL *resultURL = [self.searchResultPaths objectAtIndex:selectedRow];
  
  [self openResult:resultURL];
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
  
  if (!self.searchPath || self.searchPath.length == 0) {
    return;
  }
  
  [self.progressIndicator setIndeterminate:YES];
  [self.progressIndicator startAnimation:self];
  
  // enumerate all the files in the path
  NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtURL:[NSURL fileURLWithPath:self.searchPath] includingPropertiesForKeys:[NSArray arrayWithObject:NSURLIsDirectoryKey] options:0 errorHandler:nil];
  NSSet *excludeFilesWithExtension = [NSSet setWithArray:[DuxPreferences openQuicklyExcludesFilesWithExtension]];
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
      
      // ignore certain file types
      if ([excludeFilesWithExtension containsObject:fileURL.pathExtension])
        continue;
      
      // add this to a scratch list of search paths
      [scratchSearchPaths addObject:fileURL];
      
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

- (void)openResult:(id)url
{
  [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:url display:YES completionHandler:NULL];
  
  [self.window performClose:self];
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector
{
  if (control == self.searchField || control == self.searchPathControl) {
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
