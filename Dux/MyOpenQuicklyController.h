//
//  MyOpenQuicklyController.h
//  Dux
//
//  Created by Abhi Beckert on 2011-08-25.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import <Cocoa/Cocoa.h>
#import "DuxPreferences.h"

@interface MyOpenQuicklyController : NSWindowController <NSTextFieldDelegate> {
  NSWindow *openQuicklyWindow;
  NSString *searchPath;
  NSSearchField *__weak searchField;
  NSTableView *__weak resultsTableView;
  NSProgressIndicator *__weak progressIndicator;
  NSOperationQueue *updateResultsQueue;
}

@property (weak) IBOutlet NSSearchField *searchField;
@property (weak) IBOutlet NSPathControl *searchPathField;
@property (strong) IBOutlet NSString *searchPath;
@property (strong) IBOutlet NSWindow *openQuicklyWindow;
@property (weak) IBOutlet NSTableView *resultsTableView;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;

@property (strong) NSArray *searchPaths; // list of every subpath in available in the open quickly panel
@property (strong) NSArray *searchResultPaths;

@property (strong) NSArray *directoryNamesToSkip; // array of directories to skip when doing a search (eg: @".svn")

- (void)showOpenQuicklyPanel;
- (IBAction)performSearch:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)open:(id)sender;
- (IBAction)browseForSearchIn:(id)sender;

- (void)openResult:(id)result;

// Update the searchPaths array.
// 
// This will perform the actual search on a background queue
// and update the searchPaths property every 200 items. It
// will call performSearch: every time the searchPaths value
// is changed
- (void)updateSearchPaths;

@end
