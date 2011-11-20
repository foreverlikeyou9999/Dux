//
//  DuxCSSColorValueElement.m
//  Dux
//
//  Created by Abhi Beckert on 2011-11-20.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import "DuxCSSColorValueElement.h"
#import "DuxCSSLanguage.h"

@implementation DuxCSSColorValueElement

static NSCharacterSet *nextElementCharacterSet;
static NSColor *color;

+ (void)initialize
{
  [super initialize];
  
  nextElementCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789abcdefABCDEF"] invertedSet];
  
  color = [NSColor colorWithCalibratedRed:0.784 green:0.157 blue:0.161 alpha:1.000];
}

- (id)init
{
  return [self initWithLanguage:[DuxCSSLanguage sharedInstance]];
}

- (NSUInteger)lengthInString:(NSAttributedString *)string startingAt:(NSUInteger)startingAt nextElement:(DuxLanguageElement *__strong*)nextElement
{
  // find next character
  NSUInteger searchStart = startingAt + 1;
  NSRange foundRange = [string.string rangeOfCharacterFromSet:nextElementCharacterSet options:NSLiteralSearch range:NSMakeRange(searchStart, string.string.length - searchStart)];
  
  // not found, or the last character in the string?
  if (foundRange.location == NSNotFound || foundRange.location == (string.string.length - 1))
    return string.string.length - startingAt;
  
  // only accept 3 or 6 character colour codes
  if (foundRange.location - searchStart != 3 && foundRange.location - searchStart != 6) {
    foundRange.location = searchStart;
  }
  
  return foundRange.location - startingAt;
}

- (NSColor *)color
{
  return color;
}

@end
