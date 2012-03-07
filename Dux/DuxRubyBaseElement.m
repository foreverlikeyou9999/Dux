//
//  DuxRubyBaseElement.m
//  Dux
//
//  Created by Abhi Beckert on 2012-02-08.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import "DuxRubyBaseElement.h"
#import "DuxRubyLanguage.h"
#import "DuxRubySingleQuotedStringElement.h"
#import "DuxRubyDoubleQuotedStringElement.h"
#import "DuxRubyNumberElement.h"
#import "DuxRubyKeywordElement.h"
#import "DuxRubySingleLineCommentElement.h"
#import "DuxRubyRegularExpressionElement.h"

@implementation DuxRubyBaseElement

static NSCharacterSet *nextElementCharacterSet;

static DuxRubySingleQuotedStringElement *singleQuotedStringElement;
static DuxRubyDoubleQuotedStringElement *doubleQuotedStringElement;
static DuxRubyNumberElement *numberElement;
static DuxRubyKeywordElement *keywordElement;
static DuxRubySingleLineCommentElement *singleLineCommentElement;
static DuxRubyRegularExpressionElement *regularExpressionElement;

+ (void)initialize
{
  [super initialize];
  
  nextElementCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"'\"#/0123456789"];
  
  singleQuotedStringElement = [DuxRubySingleQuotedStringElement sharedInstance];
  doubleQuotedStringElement = [DuxRubyDoubleQuotedStringElement sharedInstance];
  numberElement = [DuxRubyNumberElement sharedInstance];
  keywordElement = [DuxRubyKeywordElement sharedInstance];
  singleLineCommentElement = [DuxRubySingleLineCommentElement sharedInstance];
  regularExpressionElement = [DuxRubyRegularExpressionElement sharedInstance];
}

- (id)init
{
  return [self initWithLanguage:[DuxRubyLanguage sharedInstance]];
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
    
    characterFound = [string.string characterAtIndex:foundCharacterSetRange.location];
    
    keepLooking = NO;
  }
  
  // search for the next keyword
  NSRange foundKeywordRange = NSMakeRange(NSNotFound, 0);

  NSIndexSet *keywordIndexes = [DuxRubyLanguage keywordIndexSet];
  if (keywordIndexes) {
    NSUInteger foundKeywordMax = (foundCharacterSetRange.location == NSNotFound) ? string.string.length : foundCharacterSetRange.location;
    for (NSUInteger index = startingAt; index < foundKeywordMax; index++) {
      if ([keywordIndexes containsIndex:index]) {
        if (foundKeywordRange.location == NSNotFound) {
          foundKeywordRange.location = index;
          foundKeywordRange.length = 1;
        } else {
          foundKeywordRange.length++;
        }
      } else {
        if (foundKeywordRange.location != NSNotFound) {
          break;
        }
      }
    }
  }
  
  // scanned up to the end of the string?
  if (foundCharacterSetRange.location == NSNotFound && foundKeywordRange.location == NSNotFound)
    return string.string.length - startingAt;
  
  // did we find a keyword before a character?
  if (foundKeywordRange.location != NSNotFound) {
    if (foundCharacterSetRange.location == NSNotFound || foundKeywordRange.location < foundCharacterSetRange.location) {
      *nextElement = keywordElement;
      return foundKeywordRange.location - startingAt;
    }
  }
  
  // what character did we find?
  switch (characterFound) {
    case '\'':
      *nextElement = singleQuotedStringElement;
      return foundCharacterSetRange.location - startingAt;
    case '"':
      *nextElement = doubleQuotedStringElement;
      return foundCharacterSetRange.location - startingAt;
    case '0':
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
      *nextElement = numberElement;
      return foundCharacterSetRange.location - startingAt;
    case '#':
      *nextElement = singleLineCommentElement;
      return foundCharacterSetRange.location - startingAt;
    case '/':
      *nextElement = regularExpressionElement;
      return foundCharacterSetRange.location - startingAt;
  }
  
  // should never reach this, but add this line anyway to make the compiler happy
  return string.string.length - startingAt;
}

@end
