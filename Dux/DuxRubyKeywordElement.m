//
//  DuxRubyKeywordElement.m
//  Dux
//
//  Created by Abhi Beckert on 2012-02-08.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import "DuxRubyKeywordElement.h"
#import "DuxRubyLanguage.h"

@implementation DuxRubyKeywordElement

static NSCharacterSet *nextElementCharacterSet;
static NSColor *color;

+ (void)initialize
{
  [super initialize];
  
  NSMutableCharacterSet *mutableCharset = [[NSCharacterSet alphanumericCharacterSet] mutableCopy];
  [mutableCharset addCharactersInString:@"_"];
  nextElementCharacterSet = [[mutableCharset copy] invertedSet];
  
  color = [NSColor colorWithCalibratedRed:0.557 green:0.031 blue:0.329 alpha:1];
}

- (id)init
{
  return [self initWithLanguage:[DuxRubyLanguage sharedInstance]];
}

- (NSUInteger)lengthInString:(NSAttributedString *)string startingAt:(NSUInteger)startingAt nextElement:(DuxLanguageElement *__strong*)nextElement
{
  NSRange foundRange = [string.string rangeOfCharacterFromSet:nextElementCharacterSet options:NSLiteralSearch range:NSMakeRange(startingAt, string.string.length - startingAt)];
  
  if (foundRange.location == NSNotFound)
    return string.string.length - startingAt;
  
  return foundRange.location - startingAt;
}

- (NSColor *)color
{
  return color;
}

@end
