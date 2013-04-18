//
//  DuxPreferencesWindowController.h
//  Dux
//
//  Created by Abhi Beckert on 2011-12-01.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import <Cocoa/Cocoa.h>

@interface DuxPreferencesWindowController : NSWindowController

+ (void)showPreferencesWindow;
- (void)showSection:(NSString *)sectionIdentifier animate:(BOOL)animate;

@property (weak) IBOutlet NSToolbar *windowToolbar;
@property (weak) IBOutlet NSView *editorSectionView;
@property (weak) IBOutlet NSView *colorsSectionView;

// editor section
@property (weak) IBOutlet NSTextField *fontTextField;
@property (weak) IBOutlet NSButton *showLineNumbersButton;
@property (weak) IBOutlet NSButton *showPageGuideButton;
@property (weak) IBOutlet NSTextField *pageGuidePositionTextField;
@property (weak) IBOutlet NSButton *showOtherInstancesOfSelectedSymbolButton;
@property (weak) IBOutlet NSPopUpButton *indentStylePopUpButton;
@property (weak) IBOutlet NSTextField *tabWidthTextField;
@property (weak) IBOutlet NSTextField *indentWidthTextField;
@property (weak) IBOutlet NSPopUpButton *tabKeyBehaviourPopUpButton;

- (IBAction)showEditorSection:(id)sender;
- (IBAction)showColorsSection:(id)sender;

- (IBAction)setShowLineNumbers:(id)sender;
- (IBAction)setShowPageGuide:(id)sender;
- (IBAction)setPageGuidePosition:(id)sender;
- (IBAction)setTabIndentBehaviour:(id)sender;
- (IBAction)setIndentWithSpaces:(id)sender;
- (IBAction)setTabWidth:(id)sender;
- (IBAction)setIndentWidth:(id)sender;
- (IBAction)setShowOtherInstancesOfSelectedSymbol:(id)sender;

// colors section
@property (weak) IBOutlet NSMatrix *darkModeRadioMatrix;

- (IBAction)setDarkMode:(id)sender;

@end
