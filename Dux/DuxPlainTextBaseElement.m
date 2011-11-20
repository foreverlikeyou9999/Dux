//
//  DuxPlainTextBaseElement.m
//  Dux
//
//  Created by Abhi Beckert on 2011-11-20.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import "DuxPlainTextBaseElement.h"
#import "DuxPlainTextLanguage.h"

@implementation DuxPlainTextBaseElement

- (id)init
{
  return [self initWithLanguage:[DuxPlainTextLanguage sharedInstance]];
}

- (NSUInteger)lengthInString:(NSAttributedString *)string startingAt:(NSUInteger)startingAt nextElement:(DuxLanguageElement *__strong*)nextElement
{
  return string.string.length - startingAt;
}

@end
