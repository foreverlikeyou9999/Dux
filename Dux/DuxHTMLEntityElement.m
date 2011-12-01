//
//  DuxHTMLEntityElement.m
//  Dux
//
//  Created by Abhi Beckert on 2011-11-14.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import "DuxHTMLEntityElement.h"
#import "DuxHTMLLanguage.h"

static NSCharacterSet *nextElementCharacterSet;
static NSColor *entityColor;

@implementation DuxHTMLEntityElement

+ (void)initialize
{
  [super initialize];
  
  NSMutableCharacterSet *mutableSet = [[NSCharacterSet alphanumericCharacterSet] mutableCopy];
  [mutableSet addCharactersInString:@"&#;"];
  nextElementCharacterSet = [mutableSet invertedSet];
  
  entityColor = [NSColor colorWithCalibratedRed:0.329 green:0.443 blue:0.459 alpha:1.000];
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
  
  // found ';' character
  return (foundRange.location + 1) - startingAt;
}

- (NSColor *)color
{
  return entityColor;
}

@end
