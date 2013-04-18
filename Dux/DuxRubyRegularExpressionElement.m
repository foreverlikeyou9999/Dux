//
//  DuxRubyRegularExpressionElement.m
//  Dux
//
//  Created by Abhi Beckert on 2012-02-08.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import "DuxRubyRegularExpressionElement.h"
#import "DuxRubyLanguage.h"
#import "DuxPreferences.h"

@implementation DuxRubyRegularExpressionElement

static NSCharacterSet *nextElementCharacterSet;
static NSColor *color;

+ (void)initialize
{
  [super initialize];
  
  nextElementCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"\\/"];
  
if ([DuxPreferences editorDarkMode]) {
  color = [NSColor colorWithDeviceRed:0.71 green:0.84 blue:1.00 alpha:1.0];
} else {
  color = [NSColor colorWithDeviceRed:0.11 green:0.36 blue:0.87 alpha:1.0];
}
}

- (id)init
{
  return [self initWithLanguage:[DuxRubyLanguage sharedInstance]];
}

- (NSUInteger)lengthInString:(NSAttributedString *)string startingAt:(NSUInteger)startingAt nextElement:(DuxLanguageElement *__strong*)nextElement
{
  BOOL keepLooking = YES;
  NSUInteger searchStartLocation = startingAt;
  NSRange foundRange;
  unichar characterFound;
  while (keepLooking) {
    // find next character
    foundRange = [string.string rangeOfCharacterFromSet:nextElementCharacterSet options:NSLiteralSearch range:NSMakeRange(searchStartLocation, string.string.length - searchStartLocation)];
    
    // not found, or the last character in the string?
    if (foundRange.location == NSNotFound || foundRange.location == (string.string.length - 1))
      return string.string.length - startingAt;
    
    // because the start/end characters are the same, so we need to make sure we didn't just find the first character
    if (foundRange.location == startingAt) {
      searchStartLocation++;
      continue;
    }
    
    // backslash? keep searching
    characterFound = [string.string characterAtIndex:foundRange.location];
    if (characterFound == '\\') {
      searchStartLocation = foundRange.location + 2;
      continue;
    }
    
    // stop looking
    keepLooking = NO;
  }
  
  // what's next?
  switch (characterFound) {
    case '/':
      return (foundRange.location + 1) - startingAt;
  }

  
  // should never reach this, but add this line anyway to make the compiler happy
  return string.string.length - startingAt;
}

- (NSColor *)color
{
  return color;
}

@end
