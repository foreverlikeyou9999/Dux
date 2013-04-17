//
//  NSColor+DuxColors.h
//  Dux
//
//  Created by Abhi Beckert on 2013-4-17.
//
//

#import <Cocoa/Cocoa.h>

@interface NSColor (DuxColors)

+ (NSColor *)duxEditorColor; // DuxTextView color when it is the first responder in the main window
+ (NSColor *)duxBackgroundEditorColor; // DuxTextView color when it is not the first responder in the main window

@end
