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

@end

const NSString *DuxPreferencesEditorFontDidChangeNotification = @"DuxPreferencesEditorFontDidChangeNotification";
