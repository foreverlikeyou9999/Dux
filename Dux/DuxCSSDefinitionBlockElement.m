//
//  DuxCSSDefinitionBlockElement.m
//  Dux
//
//  Created by Abhi Beckert on 2011-11-20.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import "DuxCSSDefinitionBlockElement.h"
#import "DuxCSSLanguage.h"
#import "DuxCSSCommentElement.h"
#import "DuxCSSPropertyNameElement.h"
#import "DuxCSSPropertyValueElement.h"

@implementation DuxCSSDefinitionBlockElement

static NSCharacterSet *nextElementCharacterSet;
static NSCharacterSet *propertyNameElementCharacterSet;

static DuxCSSCommentElement *commentElement;
static DuxCSSPropertyNameElement *propertyNameElement;
static DuxCSSPropertyValueElement *propertyValueElement;

+ (void)initialize
{
  [super initialize];
  
  nextElementCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"}/:-abcdefghijklmnopqrstuvwrxyzABCDEFGHIJKLMNOPQRSTUVWRXYZ"];
  propertyNameElementCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"-abcdefghijklmnopqrstuvwrxyzABCDEFGHIJKLMNOPQRSTUVWRXYZ"];
  
  commentElement = [DuxCSSCommentElement sharedInstance];
  propertyNameElement = [DuxCSSPropertyNameElement sharedInstance];
  propertyValueElement = [DuxCSSPropertyValueElement sharedInstance];
}

- (id)init
{
  return [self initWithLanguage:[DuxCSSLanguage sharedInstance]];
}

- (NSUInteger)lengthInString:(NSAttributedString *)string startingAt:(NSUInteger)startingAt nextElement:(DuxLanguageElement *__strong*)nextElement
{
  // scan up to the next character
  BOOL keepLooking = YES;
  NSUInteger searchStartLocation = startingAt;
  NSRange foundCharacterSetRange;
  unichar characterFound;
  while (keepLooking) {
    foundCharacterSetRange = [string.string rangeOfCharacterFromSet:nextElementCharacterSet options:NSLiteralSearch range:NSMakeRange(searchStartLocation, string.string.length - searchStartLocation)];
    
    if (foundCharacterSetRange.location == NSNotFound)
      break;
    
    // did we find a / character? check if it's a comment or not
    characterFound = [string.string characterAtIndex:foundCharacterSetRange.location];
    if (string.string.length > (foundCharacterSetRange.location + 1) && characterFound == '/') {
      characterFound = [string.string characterAtIndex:foundCharacterSetRange.location + 1];
      if (characterFound != '/' && characterFound != '*') {
        searchStartLocation++;
        continue;
      }
    }
    
    keepLooking = NO;
  }  
  // scanned up to the end of the string?
  if (foundCharacterSetRange.location == NSNotFound)
    return string.string.length - startingAt;
  
  // what character did we find?
  switch (characterFound) {
    case '*':
      *nextElement = commentElement;
      return foundCharacterSetRange.location - startingAt;
    case '}':
      return foundCharacterSetRange.location - startingAt;
    case ':':
      *nextElement = propertyValueElement;
      return foundCharacterSetRange.location - startingAt;
  }
  if ([propertyNameElementCharacterSet characterIsMember:characterFound]) {
    *nextElement = propertyNameElement;
    return foundCharacterSetRange.location - startingAt;
  }
  
  // should never reach this, but add this line anyway to make the compiler happy
  return string.string.length - startingAt;
}

@end
