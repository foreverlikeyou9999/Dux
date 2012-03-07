//
//  DuxFontSelectorTextField.h
//  Dux
//
//  Created by Abhi Beckert on 2012-02-05.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import <AppKit/AppKit.h>

@class DuxPreferencesWindowController;

@interface DuxFontSelectorTextField : NSTextField

@property (unsafe_unretained) IBOutlet DuxPreferencesWindowController *preferencesWindowController;
@property (unsafe_unretained) IBOutlet NSButton *chooseFontButton;

@end
