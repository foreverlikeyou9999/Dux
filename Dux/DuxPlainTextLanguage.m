//
//  DuxPlainTextLanguage.m
//  Dux
//
//  Created by Abhi Beckert on 2011-11-20.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import "DuxPlainTextLanguage.h"
#import "DuxPlainTextBaseElement.h"

@implementation DuxPlainTextLanguage

+ (void)load
{
  [DuxLanguage registerLanguage:[self class]];
}

- (DuxLanguageElement *)baseElement
{
  return [DuxPlainTextBaseElement sharedInstance];
}

+ (BOOL)isDefaultLanguageForURL:(NSURL *)URL textContents:(NSString *)textContents
{
  // we are the default when no other language returns YES here
  return NO;
}

@end
