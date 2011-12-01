//
//  DuxXMLBaseElement.m
//  Dux
//
//  Created by Abhi Beckert on 2011-11-20.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import "DuxXMLBaseElement.h"
#import "DuxXMLLanguage.h"
#import "DuxXMLTagElement.h"
#import "DuxXMLEntityElement.h"
#import "DuxXMLCommentElement.h"

static NSCharacterSet *nextElementCharacterSet;
static DuxXMLTagElement *tagElement;
static DuxXMLEntityElement *entityElement;
static DuxXMLCommentElement *commentElement;

@implementation DuxXMLBaseElement

+ (void)initialize
{
  [super initialize];
  
  nextElementCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"<&"];
  
  tagElement = [DuxXMLTagElement sharedInstance];
  entityElement = [DuxXMLEntityElement sharedInstance];
  commentElement = [DuxXMLCommentElement sharedInstance];
}

- (id)init
{
  return [self initWithLanguage:[DuxXMLLanguage sharedInstance]];
}

- (NSUInteger)lengthInString:(NSAttributedString *)string startingAt:(NSUInteger)startingAt nextElement:(DuxLanguageElement *__strong*)nextElement
{
  // search for next character
  NSRange foundRange = [string.string rangeOfCharacterFromSet:nextElementCharacterSet options:NSLiteralSearch range:NSMakeRange(startingAt, string.length - startingAt)];

  // reached end of string?
  if (foundRange.location == NSNotFound)
    return string.length - startingAt;
  
  // did we find a comment?
  unichar characterFound = [string.string characterAtIndex:foundRange.location];
  if (characterFound == '<' && string.length > foundRange.location + 3) {
    if ([[string.string substringWithRange:NSMakeRange(foundRange.location + 1, 3)] isEqualToString:@"!--"])
      characterFound = '!';
  }
  
  // what next?
  switch (characterFound) {
    case '<':
      *nextElement = tagElement;
      return foundRange.location - startingAt;
    case '!':
      *nextElement = commentElement;
      return foundRange.location - startingAt;
    case '&':
      *nextElement = entityElement;
      return foundRange.location - startingAt;
  }
  
  // should never reach this, but add this line anyway to make the compiler happy
  return string.string.length - startingAt;
}

@end
