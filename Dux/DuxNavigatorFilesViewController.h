//
//  DuxNavigatorFilesViewController.h
//  Dux
//
//  Created by Abhi Beckert on 2013-4-20.
//
//

#import <Cocoa/Cocoa.h>

@protocol DuxNavigatorFilesViewControllerDelegate;

@interface DuxNavigatorFilesViewController : NSViewController <NSOutlineViewDataSource, NSOutlineViewDelegate, NSMenuDelegate>

@property (strong, nonatomic) NSURL *rootURL;

@property (weak) IBOutlet NSOutlineView *filesView;

@property (assign) IBOutlet id <DuxNavigatorFilesViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet NSMenu *filesMenu;

- (void)revealFileInNavigator:(NSURL *)fileURL;

@end

@protocol DuxNavigatorFilesViewControllerDelegate <NSObject>
@optional

- (void)duxNavigatorDidSelectFile:(NSURL *)url;
@end