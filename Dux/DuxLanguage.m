//
//  DuxLanguage.m
//  Dux
//
//  Created by Abhi Beckert on 2011-10-22.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import "DuxLanguage.h"

@implementation DuxLanguage

static NSMutableDictionary *sharedInstances = nil;
static NSMutableArray *registeredLanguages = nil;

+ (void)load
{
  registeredLanguages = [[NSMutableArray alloc] init];
}

+ (id)sharedInstance
{
  if (!sharedInstances)
    sharedInstances = [[NSMutableDictionary alloc] init];
  
  NSString *className = NSStringFromClass(self);
  id sharedInstance = [sharedInstances valueForKey:className];
  
  if (!sharedInstance) {
    sharedInstance = [[self alloc] init];
    [sharedInstances setValue:sharedInstance forKey:className];
  }
  
  return sharedInstance;
}

+ (NSArray *)registeredLanguages
{
  return registeredLanguages;
}

+ (void)registerLanguage:(Class)language
{
  [registeredLanguages addObject:language];
}

- (DuxLanguageElement *)baseElement
{
  @throw [NSException exceptionWithName:@"not defined" reason:@"baseElement must be implemented by a subclass" userInfo:nil];
}

- (void)wrapCommentsAroundRange:(NSRange)commentRange ofTextView:(NSTextView *)textView
{
}

- (void)removeCommentsAroundRange:(NSRange)commentRange ofTextView:(NSTextView *)textView
{
}

- (void)prepareToParseTextStorage:(NSTextStorage *)textStorage
{
}

+ (BOOL)isDefaultLanguageForURL:(NSURL *)URL textContents:(NSString *)textContents
{
  @throw [NSException exceptionWithName:@"not defined" reason:@"isDefaultLanguageForURL:textContents: must be implemented by a subclass" userInfo:nil];
}

@end
