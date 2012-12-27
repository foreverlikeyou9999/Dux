//
//  DuxMultiFileSearchWindowController.h
//  Dux
//
//  Created by Abhi Beckert on 2012-11-6.
//
//

#import <Cocoa/Cocoa.h>

@interface DuxMultiFileSearchWindowController : NSWindowController <NSTextViewDelegate>

@property (weak) IBOutlet NSSearchField *searchField;
@property (weak) IBOutlet NSTableView *resultsTableView;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;

@property (strong) NSString *searchPath;
@property (readonly, strong) NSArray *searchResultPaths;

- (void)showWindowWithSearchPath:(NSString *)searchPath;

@end
