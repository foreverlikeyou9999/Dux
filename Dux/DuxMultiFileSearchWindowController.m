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

@property (strong) NSString *lastSearchString;
@property (strong) NSMutableSet *pathsThatDidNotContainLastSearchString;

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
  
  self.lastSearchString = nil;
  self.pathsThatDidNotContainLastSearchString = nil;
  
  return self;
}

- (void)windowDidLoad
{
  [super windowDidLoad];
}

- (void)showWindowWithSearchPath:(NSString *)searchPath
{
  [self showWindow:self];
  
  [self.searchField becomeFirstResponder];
  self.searchPath = searchPath;
  self.searchPaths = [NSArray array];
  
  [self updateSearchPaths];
}

- (void)windowWillClose:(NSNotification *)notification
{
  [self.progressIndicator stopAnimation:self]; // just incase it's still going
}

- (IBAction)performSearch:(id)sender
{
  // do we have any search paths?
  if (self.searchPaths.count == 0) {
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
  
  // cancel the operation queue
  [self.updateResultsQueue cancelAllOperations];
  [self.updateResultsQueue waitUntilAllOperationsAreFinished];
  
  NSArray *operationSearchPaths = [self.searchPaths copy];
  DuxMultiFileSearchWindowController *blockSelf = self; // avoid retain cycle warnings
  
  __block NSBlockOperation *updateResultsBlock = [NSBlockOperation blockOperationWithBlock:^{
    NSMutableArray *mutableSearchResults = [NSMutableArray array];
    NSDate *lastUIUpdate = [NSDate date]; // when this hits 1/30th of a second ago, we update the GUI
    BOOL haveNewResults = YES;
    
    double progressPosition = 0;
    __block NSDate *progressIndicatorSetToIndeterminateDate;
    dispatch_async(dispatch_get_main_queue(), ^{
      // set progress indicator to indeterminate, but change it to determinate once the user has been given enough time to stop typing (this prevents the progress indicator from flickering horribly)
      progressIndicatorSetToIndeterminateDate = [NSDate date];
      [blockSelf.progressIndicator setIndeterminate:YES];
      [blockSelf.progressIndicator startAnimation:self];
      blockSelf.progressIndicator.alphaValue = 1.0;
      if (blockSelf.progressIndicator.maxValue != operationSearchPaths.count) {
        blockSelf.progressIndicator.maxValue = operationSearchPaths.count;
      }
    });
    
    // does this search string contain the last search string? eg last searced for "foo" now searching for "foobar". if it does, we do not need to search any file that did not contain "foo" last time
    BOOL ignorePathsMissingLastSearchString = (self.lastSearchString && [searchString rangeOfString:self.lastSearchString].location != NSNotFound);
    NSMutableSet *pathsMissingThisSearchString = [NSMutableSet set];
    
    int pathsIgnored = 0;
    for (NSURL *url in operationSearchPaths) {
      if (updateResultsBlock.isCancelled)
        break;
      
      if ([lastUIUpdate timeIntervalSinceNow] < -0.06) { // update gui?
        dispatch_async(dispatch_get_main_queue(), ^{
          if ([progressIndicatorSetToIndeterminateDate timeIntervalSinceNow] < -0.3) {
            [blockSelf.progressIndicator setIndeterminate:NO];
            blockSelf.progressIndicator.doubleValue = progressPosition;
          }
        });
        if (haveNewResults) {
          dispatch_async(dispatch_get_main_queue(), ^{
            BOOL wasNoSelection = blockSelf.resultsTableView.selectedRow == -1;
            blockSelf.searchResultPaths = [mutableSearchResults copy];
            [self.resultsTableView.enclosingScrollView flashScrollers];
            if (wasNoSelection)
              [blockSelf.resultsTableView deselectAll:blockSelf];
          });
          if (updateResultsBlock.isCancelled)
            break;
          
          haveNewResults = NO;
        }
        
        lastUIUpdate = [NSDate date];
      }
      
      if (ignorePathsMissingLastSearchString) {
        if ([self.pathsThatDidNotContainLastSearchString containsObject:url]) {
          progressPosition++;
          pathsIgnored++;
          [pathsMissingThisSearchString addObject:url];
          continue;
        }
      }
      
      NSString *fileContents = [NSString stringWithContentsOfURL:url usedEncoding:NULL error:NULL];
      if (!fileContents || [fileContents rangeOfString:searchString options:NSCaseInsensitiveSearch].location == NSNotFound) {
        progressPosition++;
        [pathsMissingThisSearchString addObject:url];
        continue;
      }
      
      [mutableSearchResults addObject:url];
      haveNewResults = YES;
      progressPosition++;
    }
    self.pathsThatDidNotContainLastSearchString = pathsMissingThisSearchString;
    self.lastSearchString = searchString;

    if (updateResultsBlock.isCancelled) {
      // do not stop the progress indicator. if we are canceled, it is because some new task has been added
      return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
      blockSelf.progressIndicator.doubleValue = blockSelf.progressIndicator.maxValue;
      if (blockSelf.progressIndicator.isIndeterminate) {
        [blockSelf.progressIndicator stopAnimation:self];
      }
      [blockSelf.progressIndicator.animator setAlphaValue:0.0];
    });
    
    if (haveNewResults) {
      dispatch_async(dispatch_get_main_queue(), ^{
        BOOL wasNoSelection = blockSelf.resultsTableView.selectedRow == -1;
        blockSelf.searchResultPaths = [mutableSearchResults copy];
        [self.resultsTableView.enclosingScrollView flashScrollers];
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

- (void)updateSearchPaths
{
  self.window.title = [NSString stringWithFormat:@"Find in Files — %@", [self.searchPath stringByAbbreviatingWithTildeInPath]];
  
  // init
  self.searchPaths = [NSArray array];
  
  if (!self.searchPath || self.searchPath.length == 0) {
    return;
  }
  
  // enumerate all the files in the path
  NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtURL:[NSURL fileURLWithPath:self.searchPath.stringByStandardizingPath] includingPropertiesForKeys:[NSArray arrayWithObject:NSURLIsDirectoryKey] options:0 errorHandler:nil];
  NSSet *excludeFilesWithExtension = [NSSet setWithArray:[DuxPreferences openQuicklyExcludesFilesWithExtension]];
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    dispatch_sync(dispatch_get_main_queue(), ^{
      [self.progressIndicator setIndeterminate:YES];
      [self.progressIndicator startAnimation:self];
      self.progressIndicator.alphaValue = 1.0;
    });
    
    NSMutableArray *scratchSearchPaths = [NSMutableArray array];
    
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
    }
    
    // finish up
    dispatch_sync(dispatch_get_main_queue(), ^{
      self.searchPaths = [scratchSearchPaths copy];
      self.progressIndicator.alphaValue = 0;
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
  if (control == self.searchField) {
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
