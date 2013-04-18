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

enum {
  DuxTabAlwaysIndents = 0,
  DuxTabNeverIndents = 1,
  DuxTabIndentInLeadingWhitespace = 2
};
typedef NSUInteger DuxTabIndentBehaviour;

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
+ (BOOL)showOtherInstancesOfSelectedSymbol;
+ (void)setShowOtherInstancesOfSelectedSymbol:(BOOL)newValue;

+ (DuxTabIndentBehaviour)tabIndentBehaviour;
+ (void)setTabIndentBehaviour:(DuxTabIndentBehaviour)newValue;

+ (BOOL)indentWithSpaces;
+ (void)setIndentWithSpaces:(BOOL)newValue;
+ (NSUInteger)tabWidth; // in number spaces
+ (void)setTabWidth:(NSUInteger)newValue;
+ (NSUInteger)indentWidth;
+ (void)setIndentWidth:(NSUInteger)newValue;

+ (NSArray *)openQuicklyExcludesFilesWithExtension;

+ (BOOL)editorDarkMode;
+ (void)setEditorDarkMode:(BOOL)darkMode;

@end

extern NSString *DuxPreferencesEditorFontDidChangeNotification;
extern NSString *DuxPreferencesShowLineNumbersDidChangeNotification;
extern NSString *DuxPreferencesShowPageGuideDidChangeNotification;
extern NSString *DuxPreferencesShowOtherInstancesOfSelectedSymbolDidChangeNotification;
extern NSString *DuxPreferencesPageGuidePositionDidChangeNotification;
extern NSString *DuxPreferencesTabIndentBehaviourDidChangeNotification;
extern NSString *DuxPreferencesIndentWithSpacesDidChangeNotification;
extern NSString *DuxPreferencesTabWidthDidChangeNotification;
extern NSString *DuxPreferencesIndentWidthDidChangeNotification;
