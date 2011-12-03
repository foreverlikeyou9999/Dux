//
//  DuxPreferencesController.h
//  Dux
//
//  Created by Abhi Beckert on 2011-12-02.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import <Cocoa/Cocoa.h>

@interface DuxPreferences : NSObject

+ (void)registerDefaults;

+ (NSFont *)editorFont;
+ (void)setEditorFont:(NSFont *)newFont;

+ (BOOL)showLineNumbers;
+ (void)setShowLineNumbers:(BOOL)newValue;

+ (BOOL)showPageGuide;
+ (void)setShowPageGuide:(BOOL)newValue;
+ (NSUInteger)pageGuidePosition;
+ (void)setPageGuidePosition:(NSUInteger)newValue;

@end

extern NSString *DuxPreferencesEditorFontDidChangeNotification;
extern NSString *DuxPreferencesShowLineNumbersDidChangeNotification;
extern NSString *DuxPreferencesShowPageGuideDidChangeNotification;
extern NSString *DuxPreferencesPageGuidePositionDidChangeNotification;
