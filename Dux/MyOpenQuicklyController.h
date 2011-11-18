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

@interface MyOpenQuicklyController : NSWindowController <NSTextFieldDelegate> {
  NSWindow *openQuicklyWindow;
  NSString *searchPath;
  NSSearchField *__weak searchField;
  NSTextField *__weak searchPathField;
  NSMetadataQuery *query;
  NSTableView *__weak resultsTableView;
  NSProgressIndicator *__weak progressIndicator;
}

@property (weak) IBOutlet NSSearchField *searchField;
@property (weak) IBOutlet NSTextField *searchPathField;
@property (strong) IBOutlet NSString *searchPath;
@property (strong) IBOutlet NSWindow *openQuicklyWindow;
@property (strong) NSMetadataQuery *query;
@property (weak) IBOutlet NSTableView *resultsTableView;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;

- (void)showOpenQuicklyPanel;
- (IBAction)performSearch:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)open:(id)sender;
- (IBAction)browseForSearchIn:(id)sender;

- (void)openResult:(id)result;

@end
