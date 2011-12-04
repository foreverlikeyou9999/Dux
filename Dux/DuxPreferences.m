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
  [defaults setObject:[NSNumber numberWithInteger:800] forKey:@"DuxEditorPageGuidePosition"];
	[defaults setObject:[NSNumber numberWithBool:YES] forKey:@"DuxEditorShowOtherInstancesOfSelectedSymbol"];
  [defaults setObject:[NSNumber numberWithInteger:DuxTabIndentInLeadingWhitespace] forKey:@"DuxEditorTabIndentBehaviour"];
	[defaults setObject:[NSNumber numberWithBool:NO] forKey:@"DuxEditorIndentWithSpaces"];
	[defaults setObject:[NSNumber numberWithInteger:4] forKey:@"DuxEditorTabWidth"];
	[defaults setObject:[NSNumber numberWithInteger:4] forKey:@"DuxEditorIndentWidth"];
  
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

+ (BOOL)showOtherInstancesOfSelectedSymbol
{
	return [userDefaults boolForKey:@"DuxEditorShowOtherInstancesOfSelectedSymbol"];
}

+ (void)setShowOtherInstancesOfSelectedSymbol:(BOOL)newValue
{
	[userDefaults setBool:newValue forKey:@"DuxEditorShowOtherInstancesOfSelectedSymbol"];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:DuxPreferencesShowOtherInstancesOfSelectedSymbolDidChangeNotification object:self];
}

+ (DuxTabIndentBehaviour)tabIndentBehaviour
{
  return [userDefaults integerForKey:@"DuxEditorTabIndentBehaviour"];
}

+ (void)setTabIndentBehaviour:(DuxTabIndentBehaviour)newValue
{
  [userDefaults setInteger:newValue forKey:@"DuxEditorTabIndentBehaviour"];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:DuxPreferencesTabIndentBehaviourDidChangeNotification object:self];
}

+ (BOOL)indentWithSpaces
{
	return [userDefaults boolForKey:@"DuxEditorIndentWithSpaces"];
}

+ (void)setIndentWithSpaces:(BOOL)newValue
{
	[userDefaults setInteger:newValue forKey:@"DuxEditorIndentWithSpaces"];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:DuxPreferencesIndentWithSpacesDidChangeNotification object:self];
}

+ (NSUInteger)tabWidth
{
	return [userDefaults integerForKey:@"DuxEditorTabWidth"];
}

+ (void)setTabWidth:(NSUInteger)newValue
{
	[userDefaults setInteger:newValue forKey:@"DuxEditorTabWidth"];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:DuxPreferencesTabWidthDidChangeNotification object:self];
}

+ (NSUInteger)indentWidth
{
	return [userDefaults integerForKey:@"DuxEditorIndentWidth"];
}

+ (void)setIndentWidth:(NSUInteger)newValue
{
	[userDefaults setInteger:newValue forKey:@"DuxEditorIndentWidth"];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:DuxPreferencesIndentWidthDidChangeNotification object:self];
}

@end

const NSString *DuxPreferencesEditorFontDidChangeNotification = @"DuxPreferencesEditorFontDidChangeNotification";
const NSString *DuxPreferencesShowLineNumbersDidChangeNotification = @"DuxPreferencesShowLineNumbersDidChangeNotification";
const NSString *DuxPreferencesShowPageGuideDidChangeNotification = @"DuxPreferencesShowPageGuideDidChangeNotification";
const NSString *DuxPreferencesPageGuidePositionDidChangeNotification = @"DuxPreferencesPageGuidePositionDidChangeNotification";
const NSString *DuxPreferencesShowOtherInstancesOfSelectedSymbolDidChangeNotification = @"DuxPreferencesShowOtherInstancesOfSelectedSymbolDidChangeNotification";
const NSString *DuxPreferencesTabIndentBehaviourDidChangeNotification = @"DuxPreferencesTabIndentBehaviourDidChangeNotification";
const NSString *DuxPreferencesIndentWithSpacesDidChangeNotification = @"DuxPreferencesIndentWithSpacesDidChangeNotification";
const NSString *DuxPreferencesTabWidthDidChangeNotification = @"DuxPreferencesTabWidthDidChangeNotification";
const NSString *DuxPreferencesIndentWidthDidChangeNotification = @"DuxPreferencesIndentWidthDidChangeNotification";
