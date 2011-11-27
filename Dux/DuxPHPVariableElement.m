//
//  DuxPHPVariableElement.m
//  Dux
//
//  Created by Abhi Beckert on 2011-11-16.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import "DuxPHPVariableElement.h"
#import "DuxPHPLanguage.h"

@implementation DuxPHPVariableElement

static NSCharacterSet *nextElementCharacterSet;
static NSCharacterSet *checkForOpenBraceRangeCharacterSet;
static NSColor *color;

+ (void)initialize
{
  [super initialize];
  
  nextElementCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwrxyzABCDEFGHIJKLMNOPQRSTUVWRXYZ0123456789_"] invertedSet];
  checkForOpenBraceRangeCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwrxyzABCDEFGHIJKLMNOPQRSTUVWRXYZ0123456789_ "] invertedSet];
  
  color = [NSColor colorWithCalibratedRed:0.216 green:0.349 blue:0.365 alpha:1];
}

- (id)init
{
  return [self initWithLanguage:[DuxPHPLanguage sharedInstance]];
}

- (NSUInteger)lengthInString:(NSAttributedString *)string startingAt:(NSUInteger)startingAt nextElement:(DuxLanguageElement *__strong*)nextElement
{
  BOOL keepLooking = YES;
  NSUInteger searchStartLocation = startingAt + 1; // plus 1, because the $ character is an invalid variable
  NSRange foundRange;
  while (keepLooking) {
    // find next character
    foundRange = [string.string rangeOfCharacterFromSet:nextElementCharacterSet options:NSLiteralSearch range:NSMakeRange(searchStartLocation, string.string.length - searchStartLocation)];
    
    // not found, or the last character in the string?
    if (foundRange.location == NSNotFound || foundRange.location == (string.string.length - 1))
      return string.string.length - startingAt;
    
    // did we just find a -> operator?
    unichar characterFound = [string.string characterAtIndex:foundRange.location];
    if (string.string.length > foundRange.location + 2) {
      unichar nextCharacterFound = [string.string characterAtIndex:foundRange.location + 1];
      if (characterFound == '-' && nextCharacterFound == '>') {
        searchStartLocation = foundRange.location + 2;
        
        // ignore -> operators if they are a method call
        NSRange checkForOpenBraceRange = [string.string rangeOfCharacterFromSet:checkForOpenBraceRangeCharacterSet options:NSLiteralSearch range:NSMakeRange(searchStartLocation, string.string.length - searchStartLocation)];
        if (checkForOpenBraceRange.location == NSNotFound || [string.string characterAtIndex:checkForOpenBraceRange.location] != '(')
          continue;
      }
    }
    
    keepLooking = NO;
  }
  
  return foundRange.location - startingAt;
}

- (NSColor *)color
{
  return color;
}

- (BOOL)shouldHighlightOtherIdenticalElements
{
  return YES;
}

@end
