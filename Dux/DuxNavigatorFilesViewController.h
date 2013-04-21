//
//  DuxNavigatorFilesViewController.h
//  Dux
//
//  Created by Abhi Beckert on 2013-4-20.
//
//

#import <Cocoa/Cocoa.h>

@protocol DuxNavigatorFilesViewControllerDelegate;

@interface DuxNavigatorFilesViewController : NSViewController <NSOutlineViewDataSource, NSOutlineViewDelegate>

@property (strong, nonatomic) NSURL *rootURL;

@property (weak) IBOutlet NSOutlineView *filesView;

@property (weak) IBOutlet id <DuxNavigatorFilesViewControllerDelegate> delegate;

@end

@protocol DuxNavigatorFilesViewControllerDelegate <NSObject>
@optional

- (void)duxNavigatorDidSelectFile:(NSURL *)url;

@end