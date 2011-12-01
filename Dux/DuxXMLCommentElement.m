//
//  DuxXMLCommentElement.m
//  Dux
//
//  Created by Abhi Beckert on 2011-12-01.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import "DuxXMLCommentElement.h"
#import "DuxXMLLanguage.h"

static NSCharacterSet *nextElementCharacterSet;
static NSColor *entityColor;

@implementation DuxXMLCommentElement

+ (void)initialize
{
  [super initialize];
  
  nextElementCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"-"];
  
  entityColor = [NSColor colorWithCalibratedRed:0.075 green:0.529 blue:0.000 alpha:1.000];
}

- (id)init
{
  return [self initWithLanguage:[DuxXMLLanguage sharedInstance]];
}

- (NSUInteger)lengthInString:(NSAttributedString *)string startingAt:(NSUInteger)startingAt nextElement:(DuxLanguageElement *__strong*)nextElement
{
  // scan up to the next character
  NSUInteger stringLength = string.length;
  NSUInteger searchPosition = startingAt;
  NSRange foundRange;
  while (searchPosition < stringLength) {
    foundRange = [string.string rangeOfCharacterFromSet:nextElementCharacterSet options:NSLiteralSearch range:NSMakeRange(searchPosition, string.string.length - searchPosition)];
    
    if (foundRange.location == NSNotFound)
      break;
    
    if (stringLength > foundRange.location + 2) {
      if ([[string.string substringWithRange:NSMakeRange(foundRange.location, 3)] isEqualToString:@"-->"]) {
        foundRange.location += 3;
        break;
      }
    }
    
    searchPosition = foundRange.location + 1;
    foundRange.location = NSNotFound;
  }
  
  // scanned up to the end of the string?
  if (foundRange.location == NSNotFound)
    return string.string.length - startingAt;
  
  // found end of comment character
  return foundRange.location - startingAt;
}

- (NSColor *)color
{
  return entityColor;
}

- (BOOL)isComment
{
  return YES;
}

@end
