//
//  DuxPreferencesController.m
//  Dux
//
//  Created by Abhi Beckert on 2011-12-02.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import "DuxPreferences.h"

static NSUserDefaults *userDefaults;

@implementation DuxPreferences

+ (void)initialize
{
  [super initialize];
  
  userDefaults = [NSUserDefaults standardUserDefaults];
}

+ (void)registerDefaults
{
  NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
  
  NSFont *font = [NSFont fontWithName:@"Menlo" size:13];
  [defaults setObject:font.fontName forKey:@"DuxEditorFontName"];
  [defaults setObject:[NSNumber numberWithFloat:font.pointSize] forKey:@"DuxEditorFontSize"];
  
  [defaults setObject:[NSNumber numberWithBool:YES] forKey:@"DuxEditorShowLineNumbers"];
  [defaults setObject:[NSNumber numberWithBool:YES] forKey:@"DuxEditorPageGuide"];
  [defaults setObject:[NSNumber numberWithInt:800] forKey:@"DuxEditorPageGuidePosition"];
  
  [userDefaults registerDefaults:defaults.copy];
}

+ (NSFont *)editorFont
{
  NSFont *font = [NSFont fontWithName:[userDefaults stringForKey:@"DuxEditorFontName"] size:[userDefaults floatForKey:@"DuxEditorFontSize"]];
  return font;
}

+ (void)setEditorFont:(NSFont *)newFont
{
  [userDefaults setObject:newFont.fontName forKey:@"DuxEditorFontName"];
  [userDefaults setObject:[NSNumber numberWithFloat:newFont.pointSize] forKey:@"DuxEditorFontSize"];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:DuxPreferencesEditorFontDidChangeNotification object:self];
}

+ (BOOL)showLineNumbers
{
  return [userDefaults boolForKey:@"DuxEditorShowLineNumbers"];
}

+ (void)setShowLineNumbers:(BOOL)newValue
{
  [userDefaults setBool:newValue forKey:@"DuxEditorShowLineNumbers"];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:DuxPreferencesShowLineNumbersDidChangeNotification object:self];
}

+ (BOOL)showPageGuide
{
  return [userDefaults boolForKey:@"DuxEditorShowPageGuide"];
}

+ (void)setShowPageGuide:(BOOL)newValue
{
  [userDefaults setBool:newValue forKey:@"DuxEditorShowPageGuide"];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:DuxPreferencesShowPageGuideDidChangeNotification object:self];
}

+ (NSUInteger)pageGuidePosition
{
  return [userDefaults integerForKey:@"DuxEditorPageGuidePosition"];
}

+ (void)setPageGuidePosition:(NSUInteger)newValue
{
  [userDefaults setInteger:newValue forKey:@"DuxEditorPageGuidePosition"];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:DuxPreferencesPageGuidePositionDidChangeNotification object:self];
}

@end

const NSString *DuxPreferencesEditorFontDidChangeNotification = @"DuxPreferencesEditorFontDidChangeNotification";
const NSString *DuxPreferencesShowLineNumbersDidChangeNotification = @"DuxPreferencesShowLineNumbersDidChangeNotification";
const NSString *DuxPreferencesShowPageGuideDidChangeNotification = @"DuxPreferencesShowPageGuideDidChangeNotification";
const NSString *DuxPreferencesPageGuidePositionDidChangeNotification = @"DuxPreferencesPageGuidePositionDidChangeNotification";

