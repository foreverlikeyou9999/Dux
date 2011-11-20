//
//  DuxPlainTextBaseElement.m
//  Dux
//
//  Created by Woody Beckert on 2011-11-20.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
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
