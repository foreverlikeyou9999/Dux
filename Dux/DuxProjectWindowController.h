//
//  DuxProjectWindowController.h
//  Dux
//
//  Created by Abhi Beckert on 2012-12-26.
//
//

#import <Cocoa/Cocoa.h>

@class MyOpenQuicklyController, DuxClickAndHoldPopUpButton;

@interface DuxProjectWindowController : NSWindowController

@property (nonatomic, strong) NSURL *rootUrl;
@property (nonatomic, strong) NSMutableArray *documents;

@property (nonatomic, strong) NSMutableArray *goBackDocuments;
@property (nonatomic, strong) NSMutableArray *goForwardDocuments;

@property (unsafe_unretained) IBOutlet NSWindow *editorWindow;

@property (weak) IBOutlet NSView *noEditorView;
@property (weak) IBOutlet NSImageView *noEditorLogoView;
@property (weak) IBOutlet NSTextField *noEditorTextView;

@property (weak) IBOutlet NSView *documentView;
@property (weak) IBOutlet NSTextField *documentPathLabel;
@property (weak) IBOutlet NSPopUpButton *documentHistoryPopUp;
@property (weak) IBOutlet DuxClickAndHoldPopUpButton *goBackPopUp;
@property (weak) IBOutlet DuxClickAndHoldPopUpButton *goForwardPopUp;

@property (weak) IBOutlet NSToolbarItem *historyToolbarItem;
@property (strong) IBOutlet NSView *historyToolbarItemView;
@property (weak) IBOutlet NSToolbarItem *pathToolbarItem;
@property (strong) IBOutlet NSView *pathToolbarItemView;

@property (nonatomic,strong) IBOutlet MyOpenQuicklyController *openQuicklyController;

+ (NSArray *)projectWindowControllers;
+ (DuxProjectWindowController *)newProjectWindowControllerWithRoot:(NSURL *)rootUrl;
+ (void)closeProjectWindowController:(DuxProjectWindowController *)controller;

- (void)reloadDocumentHistoryPopUp;
- (IBAction)loadDocumentFromHistoryPopUp:(NSPopUpButton *)sender;
- (IBAction)goBack:(id)sender;
- (IBAction)goForward:(id)sender;

- (IBAction)openQuickly:(id)sender;
- (IBAction)setProjectRoot:(id)sender;

- (IBAction)newWindow:(id)sender;

- (IBAction)findInFiles:(id)sender;

- (IBAction)closeDocument:(id)sender; // close the current document without closing the window

@end
