//
//  DuxCSSNumberValueElement.m
//  Dux
//
//  Created by Abhi Beckert on 2011-11-20.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import "DuxCSSNumberValueElement.h"
#import "DuxCSSLanguage.h"

@implementation DuxCSSNumberValueElement

static NSCharacterSet *nextElementCharacterSet;
static NSColor *color;

+ (void)initialize
{
  [super initialize];
  
  nextElementCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@".0123456789"] invertedSet];
  
  color = [NSColor colorWithCalibratedRed:0.255 green:0.008 blue:0.847 alpha:1.000];
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
  
  // did we just find a known measurment unit (px, pt, %, etc)
  if (string.string.length > foundRange.location + 1 && [[string.string substringWithRange:NSMakeRange(foundRange.location, 1)] isEqualToString:@"%"]) {
    foundRange.location += 1;
  }
  if (string.string.length > foundRange.location + 2 && [[string.string substringWithRange:NSMakeRange(foundRange.location, 2)] isEqualToString:@"in"]) {
    foundRange.location += 2;
  }
  if (string.string.length > foundRange.location + 2 && [[string.string substringWithRange:NSMakeRange(foundRange.location, 2)] isEqualToString:@"cm"]) {
    foundRange.location += 2;
  }
  if (string.string.length > foundRange.location + 2 && [[string.string substringWithRange:NSMakeRange(foundRange.location, 2)] isEqualToString:@"mm"]) {
    foundRange.location += 2;
  }
  if (string.string.length > foundRange.location + 2 && [[string.string substringWithRange:NSMakeRange(foundRange.location, 2)] isEqualToString:@"em"]) {
    foundRange.location += 2;
  }
  if (string.string.length > foundRange.location + 2 && [[string.string substringWithRange:NSMakeRange(foundRange.location, 2)] isEqualToString:@"ex"]) {
    foundRange.location += 2;
  }
  if (string.string.length > foundRange.location + 2 && [[string.string substringWithRange:NSMakeRange(foundRange.location, 2)] isEqualToString:@"pt"]) {
    foundRange.location += 2;
  }
  if (string.string.length > foundRange.location + 2 && [[string.string substringWithRange:NSMakeRange(foundRange.location, 2)] isEqualToString:@"pc"]) {
    foundRange.location += 2;
  }
  if (string.string.length > foundRange.location + 2 && [[string.string substringWithRange:NSMakeRange(foundRange.location, 2)] isEqualToString:@"px"]) {
    foundRange.location += 2;
  }
  
  return foundRange.location - startingAt;
}

- (NSColor *)color
{
  return color;
}

@end
