//
//  DuxRunBundleQuicklyWindowController.m
//  Dux
//
//  Created by Abhi Beckert on 2013-1-1.
//
//

#import "DuxRunBundleQuicklyWindowController.h"
#import "DuxBundle.h"

@interface DuxRunBundleQuicklyWindowController ()

@property NSOperationQueue *updateResultsQueue;

@end

@implementation DuxRunBundleQuicklyWindowController

- (id)initWithWindow:(NSWindow *)window
{
  self = [super initWithWindow:window];
  if (self) {
    // Initialization code here.
  }
  
  return self;
}

- (void)windowDidLoad
{
  [super windowDidLoad];
  
  self.updateResultsQueue = [[NSOperationQueue alloc] init];
  self.updateResultsQueue.maxConcurrentOperationCount = 1;
}

- (void)showWindow:(id)sender
{
  [super showWindow:sender];
  
  [self.window makeFirstResponder:self.searchTextField];
  [self.searchTextField selectText:self];
  
  [self performSearch:sender];
}

- (IBAction)performSearch:(id)sender
{
  // empty search string?
  NSString *searchString = self.searchTextField.stringValue;
  
  // clear selection
  [self.resultsTableView deselectAll:self];
  
  // build regex pattern from search string (if there is a search string)
  NSRegularExpression *expression = nil;
  if (searchString.length > 0) {
    NSMutableString *searchPattern = [NSMutableString stringWithString:@""];
    NSString *operatorChars = @"*?+[(){}^$|\\./";
    for (int charPos = 0; charPos < searchString.length; charPos++) {
      NSString *character = [searchString substringWithRange:NSMakeRange(charPos, 1)];
      
      if ([operatorChars rangeOfString:character].location != NSNotFound)
        character = [NSString stringWithFormat:@"\\%@", character];
      
      [searchPattern appendFormat:@"%@.*", character];
    }
    
    expression = [NSRegularExpression regularExpressionWithPattern:searchPattern options:NSRegularExpressionCaseInsensitive error:NULL];
  }
  
  NSArray *operationSearchPaths = [DuxBundle allBundles];
  DuxRunBundleQuicklyWindowController *blockSelf = self; // avoid retain cycle warnings
  
  NSMutableArray *mutableSearchResults = [NSMutableArray array];
  
  for (DuxBundle *bundle in operationSearchPaths) {
    // can we execute this bundle item at all?
    id target = [NSApp targetForAction:@selector(performDuxBundle:)];
    if (!target) {
      continue;
    }
    if ([target respondsToSelector:@selector(validateMenuItem:)] && ![target validateMenuItem:bundle.menuItem]) {
        continue;
    }
    
    // does the regex pattern match? (assuming we have a regex pattern)
    if (expression && [expression rangeOfFirstMatchInString:bundle.displayName options:0 range:NSMakeRange(0, bundle.displayName.length)].location == NSNotFound)
      continue;
    
    NSUInteger urlIndex = [mutableSearchResults indexOfObject:bundle inSortedRange:NSMakeRange(0, mutableSearchResults.count) options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(DuxBundle *leftObj, DuxBundle *rightObj) {
      NSString *leftLastPathComponent = leftObj.displayName;
      NSUInteger leftLength = leftLastPathComponent.length;
      
      NSString *rightLastPathComponent = rightObj.displayName;
      NSUInteger rightLength = rightLastPathComponent.length;
      
      if (leftLength < rightLength) {
        return -1;
      } else if (leftLength > rightLength) {
        return 1;
      } else {
        return [leftLastPathComponent compare:rightLastPathComponent];
      }
    }];
    [mutableSearchResults insertObject:bundle atIndex:urlIndex];
  }
  BOOL wasNoSelection = blockSelf.resultsTableView.selectedRow == -1;
  blockSelf.searchResultPaths = [mutableSearchResults copy];
  [self.resultsTableView.enclosingScrollView flashScrollers];
  if (wasNoSelection)
    [blockSelf.resultsTableView deselectAll:blockSelf];
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector
{
  if (control == self.searchTextField) {
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
  
  DuxBundle *resultURL = [self.searchResultPaths objectAtIndex:selectedRow];
  
  [self.window orderOut:self];
  
  [NSApp sendAction:@selector(performDuxBundle:) to:nil from:resultURL.menuItem];
  
//  [NSResponder ]
  
  //  [self openResult:resultURL];
}

@end
