//
//  NSColor+DuxColors.m
//  Dux
//
//  Created by Abhi Beckert on 2013-4-17.
//
//

#import "NSColor+DuxColors.h"
#import "DuxPreferences.h"

@implementation NSColor (DuxColors)

+ (NSColor *)duxEditorColor
{
  static NSColor *color;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
if ([DuxPreferences editorDarkMode]) {
    color = [NSColor colorWithCalibratedWhite:0 alpha:1.000];
} else {
    color = [NSColor colorWithCalibratedWhite:1 alpha:1.000];
}
  });
  
  return color;
}

+ (NSColor *)duxBackgroundEditorColor
{
  static NSColor *color;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
if ([DuxPreferences editorDarkMode]) {
    color = [NSColor colorWithCalibratedWhite:0.07 alpha:1.000];
} else {
    color = [NSColor colorWithCalibratedRed:0.931 green:0.942 blue:0.960 alpha:1.000];
}
  });
  
  return color;
}

@end
