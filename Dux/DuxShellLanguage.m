//
//  DuxShellLanguage.m
//  Dux
//
//  Created by Abhi Beckert on 2012-03-07.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import "DuxShellLanguage.h"
#import "DuxShellBaseElement.h"

static NSRegularExpression *keywordsExpression;
static NSIndexSet *keywordIndexSet = nil;

@implementation DuxShellLanguage

+ (void)load
{
  [DuxLanguage registerLanguage:[self class]];
}

- (DuxLanguageElement *)baseElement
{
  return [DuxShellBaseElement sharedInstance];
}

- (void)wrapCommentsAroundRange:(NSRange)commentRange ofTextView:(NSTextView *)textView
{
  NSString *existingString = [textView.textStorage.string substringWithRange:commentRange];
  
  NSString *commentedString= [NSString stringWithFormat:@"# %@", existingString];
  commentedString = [commentedString stringByReplacingOccurrencesOfString:@"(\n)" withString:@"$1# " options:NSRegularExpressionSearch range:NSMakeRange(0, commentedString.length)];
  
  [textView insertText:commentedString replacementRange:commentRange];
  [textView setSelectedRange:NSMakeRange(commentRange.location, commentedString.length)];
}

- (void)removeCommentsAroundRange:(NSRange)commentRange ofTextView:(NSTextView *)textView
{
  NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"^\\s*# ?" options:NSRegularExpressionAnchorsMatchLines error:NULL];
  
  NSMutableString *newString = [[textView.textStorage.string substringWithRange:commentRange] mutableCopy];
  [expression replaceMatchesInString:newString options:0 range:NSMakeRange(0, newString.length) withTemplate:@""];
  
  [textView insertText:[newString copy] replacementRange:commentRange];
  [textView setSelectedRange:NSMakeRange(commentRange.location, newString.length)];
}

+ (NSIndexSet *)keywordIndexSet
{
  return keywordIndexSet;
}

- (void)prepareToParseTextStorage:(NSTextStorage *)textStorage
{
  [super prepareToParseTextStorage:textStorage];
  
  if (!keywordsExpression) {
    NSArray *keywords = [[NSArray alloc] initWithObjects:@"echo", @"printf", @"read", @"cd", @"pwd", @"pushd", @"popd", @"dirs", @"let", @"eval", @"set", @"unset", @"export", @"declare", @"typeset", @"readonly", @"getopts", @"source", @"exit", @"exec", @"shopt", @"caller", @"true", @"false", @"type", @"hash", @"bind", nil];
    
    keywordsExpression = [[NSRegularExpression alloc] initWithPattern:[[NSString alloc] initWithFormat:@"\\b(%@)\\b", [keywords componentsJoinedByString:@"|"]] options:NSRegularExpressionCaseInsensitive error:NULL];
  }
  
  NSMutableIndexSet *keywordIndexesMutable = [[NSIndexSet indexSet] mutableCopy];
  [keywordsExpression enumerateMatchesInString:textStorage.string options:0 range:NSMakeRange(0, textStorage.length) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
    [keywordIndexesMutable addIndexesInRange:match.range];
  }];
  
  keywordIndexSet = [keywordIndexesMutable copy];
}

+ (BOOL)isDefaultLanguageForURL:(NSURL *)URL textContents:(NSString *)textContents
{
  static NSArray *extensions = nil;
  if (!extensions) {
    extensions = [NSArray arrayWithObjects:@"sh", nil];
  }
  
  if (URL && [extensions containsObject:[URL pathExtension]])
    return YES;
  
  if (textContents.length >= 9 && [[textContents substringToIndex:9] isEqualToString:@"#!/bin/sh"])
    return YES;
  if (textContents.length >= 11 && [[textContents substringToIndex:11] isEqualToString:@"#!/bin/bash"])
    return YES;
  if (textContents.length >= 11 && [[textContents substringToIndex:11] isEqualToString:@"#!/bin/tcsh"])
    return YES;
  if (textContents.length >= 10 && [[textContents substringToIndex:10] isEqualToString:@"#!/bin/zsh"])
    return YES;
  if (textContents.length >= 10 && [[textContents substringToIndex:10] isEqualToString:@"#!/bin/csh"])
    return YES;
  if (textContents.length >= 11 && [[textContents substringToIndex:11] isEqualToString:@"#!/bin/scsh"])
    return YES;
  if (textContents.length >= 10 && [[textContents substringToIndex:10] isEqualToString:@"#!/bin/ksh"])
    return YES;

  
  return NO;
}

@end
