//
//  DuxHTMLTagElement.m
//  Dux
//
//  Created by Abhi Beckert on 2011-10-28.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import "DuxHTMLTagElement.h"
#import "DuxHTMLLanguage.h"

static NSCharacterSet *nextElementCharacterSet;
static DuxHTMLTagAttributeElement *tagAttributeElement;
static NSColor *tagColor;

@implementation DuxHTMLTagElement

+ (void)initialize
{
  [super initialize];
  
  nextElementCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@">\""];
  
  tagAttributeElement = [DuxHTMLTagAttributeElement sharedInstance];
  
  tagColor = [NSColor colorWithCalibratedRed:0.39 green:0.22 blue:0.13 alpha:1];
}

- (id)init
{
  return [self initWithLanguage:[DuxHTMLLanguage sharedInstance]];
}

- (NSUInteger)lengthInString:(NSAttributedString *)string startingAt:(NSUInteger)startingAt nextElement:(DuxLanguageElement *__strong*)nextElement
{
  // scan up to the next character
  NSRange foundRange = [string.string rangeOfCharacterFromSet:nextElementCharacterSet options:NSLiteralSearch range:NSMakeRange(startingAt, string.string.length - startingAt)];
  
  // scanned up to the end of the string?
  if (foundRange.location == NSNotFound)
    return string.string.length - startingAt;
  
  // what's next?
  unichar characterFound = [string.string characterAtIndex:foundRange.location];
  switch (characterFound) {
    case '>':
      return (foundRange.location + 1) - startingAt;
    case '"':
      *nextElement = tagAttributeElement;
      return foundRange.location - startingAt;
  }
  
  // should never reach this, but add this line anyway to make the compiler happy
  return string.string.length - startingAt;
}

- (NSColor *)color
{
  return tagColor;
}

@end
