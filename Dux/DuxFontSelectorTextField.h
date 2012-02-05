//
//  DuxFontSelectorTextField.h
//  Dux
//
//  Created by Abhi Beckert on 2012-02-05.
//  Copyright (c) 2012 Precedence. All rights reserved.
//

#import <AppKit/AppKit.h>

@class DuxPreferencesWindowController;

@interface DuxFontSelectorTextField : NSTextField

@property (unsafe_unretained) IBOutlet DuxPreferencesWindowController *preferencesWindowController;
@property (unsafe_unretained) IBOutlet NSButton *chooseFontButton;

@end
