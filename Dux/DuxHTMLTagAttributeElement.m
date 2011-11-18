//
//  DuxHTMLTagAttributeElement.m
//  Dux
//
//  Created by Abhi Beckert on 2011-11-13.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import "DuxHTMLTagAttributeElement.h"
#import "DuxHTMLLanguage.h"

static NSCharacterSet *nextElementCharacterSet;
static DuxHTMLEntityElement *entityElement;
static NSColor *attributeColor;

@implementation DuxHTMLTagAttributeElement

+ (void)initialize
{
  [super initialize];
  
  nextElementCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"\"&"];
  
  entityElement = [DuxHTMLEntityElement sharedInstance];
  
  attributeColor = [NSColor colorWithCalibratedRed:0.76 green:0.1 blue:0.08 alpha:1];
}

- (id)init
{
  return [self initWithLanguage:[DuxHTMLLanguage sharedInstance]];
}

- (NSUInteger)lengthInString:(NSAttributedString *)string startingAt:(NSUInteger)startingAt nextElement:(DuxLanguageElement *__strong*)nextElement
{
  // find next character
  NSRange foundRange = [string.string rangeOfCharacterFromSet:nextElementCharacterSet options:NSLiteralSearch range:NSMakeRange(startingAt, string.string.length - startingAt)];
  
  // not found, or the last character in the string?
  if (foundRange.location == NSNotFound || foundRange.location == (string.string.length - 1))
    return string.string.length - startingAt;
  
  // because the start/end characters are the same, so we need to make sure we didn't just find the first character
  if (foundRange.location == startingAt) {
    foundRange = [string.string rangeOfCharacterFromSet:nextElementCharacterSet options:NSLiteralSearch range:NSMakeRange(startingAt + 1, string.string.length - (startingAt + 1))];
  }
  
  // not found, or the last character in the string?
  if (foundRange.location == NSNotFound || foundRange.location == (string.string.length - 1))
    return string.string.length - startingAt;
  
  
  // what's next?
  unichar characterFound = [string.string characterAtIndex:foundRange.location];
  switch (characterFound) {
    case '"':
      return (foundRange.location + 1) - startingAt;
    case '&':
      *nextElement = entityElement;
      return foundRange.location - startingAt;
  }

  
  // should never reach this, but add this line anyway to make the compiler happy
  return string.string.length - startingAt;
}

- (NSColor *)color
{
  return attributeColor;
}

@end
