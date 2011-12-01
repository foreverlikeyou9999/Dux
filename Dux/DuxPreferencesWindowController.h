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

@property (weak) IBOutlet NSTextField *fontTextField;
@property (weak) IBOutlet NSButton *showLineNumbersButton;
@property (weak) IBOutlet NSButton *showPageGuideButton;
@property (weak) IBOutlet NSTextField *pageGuidePositionTextField;
@property (weak) IBOutlet NSButton *showOtherInstancesOfSelectedSymbolButton;
@property (weak) IBOutlet NSPopUpButton *indentStylePopUpButton;
@property (weak) IBOutlet NSTextField *tabWidthTextField;
@property (weak) IBOutlet NSTextField *indentWidthTextField;
@property (weak) IBOutlet NSPopUpButton *tabKeyBehaviourPopUpButton;
@property (weak) IBOutlet NSButton *lineWrappingButton;
@property (weak) IBOutlet NSTextField *lineWrappingSizeTextField;

@end
