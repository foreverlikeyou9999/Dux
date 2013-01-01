//
//  DuxRunBundleQuicklyWindowController.h
//  Dux
//
//  Created by Abhi Beckert on 2013-1-1.
//
//

#import <Cocoa/Cocoa.h>

@interface DuxRunBundleQuicklyWindowController : NSWindowController

@property (weak) IBOutlet NSSearchField *searchTextField;
@property (weak) IBOutlet NSTableView *resultsTableView;
@property IBOutlet NSArray *searchResultPaths;

- (IBAction)performSearch:(id)sender;

- (IBAction)cancel:(id)sender;
- (IBAction)open:(id)sender;

@end
