//
//  DuxCSSLanguage.m
//  Dux
//
//  Created by Abhi Beckert on 2011-11-20.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import "DuxCSSLanguage.h"
#import "DuxCSSBaseElement.h"

@implementation DuxCSSLanguage

+ (void)load
{
  [DuxLanguage registerLanguage:[self class]];
}

- (DuxLanguageElement *)baseElement
{
  return [DuxCSSBaseElement sharedInstance];
}

+ (BOOL)isDefaultLanguageForURL:(NSURL *)URL textContents:(NSString *)textContents
{
  if (URL && [[URL pathExtension] isEqualToString:@"css"])
    return YES;
  
  return NO;
}

@end
