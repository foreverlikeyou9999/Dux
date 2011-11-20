//
//  DuxCSSBaseElement.m
//  Dux
//
//  Created by Abhi Beckert on 2011-11-20.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import "DuxCSSBaseElement.h"
#import "DuxCSSLanguage.h"
#import "DuxCSSCommentElement.h"
#import "DuxCSSClassSelectorElement.h"
#import "DuxCSSIDSelectorElement.h"
#import "DuxCSSPseudoSelectorElement.h"
#import "DuxCSSDefinitionBlockElement.h"

static NSCharacterSet *nextElementCharacterSet;

static DuxCSSCommentElement *commentElement;
static DuxCSSClassSelectorElement *classSelectorElement;
static DuxCSSIDSelectorElement *idSelectorElement;
static DuxCSSPseudoSelectorElement *pseudoSelectorElement;
static DuxCSSDefinitionBlockElement *definitionBlockElement;

@implementation DuxCSSBaseElement

+ (void)initialize
{
  [super initialize];
  
  nextElementCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"/.#:{"];
  
  commentElement = [DuxCSSCommentElement sharedInstance];
  classSelectorElement = [DuxCSSClassSelectorElement sharedInstance];
  idSelectorElement = [DuxCSSIDSelectorElement sharedInstance];
  pseudoSelectorElement = [DuxCSSPseudoSelectorElement sharedInstance];
  definitionBlockElement = [DuxCSSDefinitionBlockElement sharedInstance];
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
    case '.':
      *nextElement = classSelectorElement;
      return foundCharacterSetRange.location - startingAt;
    case '#':
      *nextElement = idSelectorElement;
      return foundCharacterSetRange.location - startingAt;
    case ':':
      *nextElement = pseudoSelectorElement;
      return foundCharacterSetRange.location - startingAt;
    case '{':
      *nextElement = definitionBlockElement;
      return foundCharacterSetRange.location - startingAt;
  }
  
  // should never reach this, but add this line anyway to make the compiler happy
  return string.string.length - startingAt;
}

@end
