//
//  DuxShellNumberElement.m
//  Dux
//
//  Created by Abhi Beckert on 2012-03-07.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import "DuxShellNumberElement.h"
#import "DuxShellLanguage.h"
#import "DuxPreferences.h"

@implementation DuxShellNumberElement

static NSCharacterSet *nextElementCharacterSet;
static NSColor *color;

+ (void)initialize
{
  [super initialize];
  
  nextElementCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
  
if ([DuxPreferences editorDarkMode]) {
  color = [NSColor colorWithDeviceRed:0.71 green:0.84 blue:1.00 alpha:1.0];
} else {
  color = [NSColor colorWithDeviceRed:0.11 green:0.36 blue:0.87 alpha:1.0];
}
}

- (id)init
{
  return [self initWithLanguage:[DuxShellLanguage sharedInstance]];
}

- (NSUInteger)lengthInString:(NSAttributedString *)string startingAt:(NSUInteger)startingAt nextElement:(DuxLanguageElement *__strong*)nextElement
{
  // find next character
  NSRange foundRange = [string.string rangeOfCharacterFromSet:nextElementCharacterSet options:NSLiteralSearch range:NSMakeRange(startingAt, string.string.length - startingAt)];
  
  // not found, or the last character in the string?
  if (foundRange.location == NSNotFound || foundRange.location == (string.string.length - 1))
    return string.string.length - startingAt;
  
  return foundRange.location - startingAt;
}

- (NSColor *)color
{
  return color;
}

@end
