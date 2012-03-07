//
//  DuxRubyLanguage.m
//  Dux
//
//  Created by Abhi Beckert on 2012-02-08.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import "DuxRubyLanguage.h"
#import "DuxRubyBaseElement.h"

static NSRegularExpression *keywordsExpression;
static NSIndexSet *keywordIndexSet = nil;

@implementation DuxRubyLanguage

+ (void)load
{
  [DuxLanguage registerLanguage:[self class]];
}

- (DuxLanguageElement *)baseElement
{
  return [DuxRubyBaseElement sharedInstance];
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
    NSArray *keywords = [[NSArray alloc] initWithObjects:@"BEGIN", @"END", @"__ENCODING__", @"__END__", @"__FILE__", @"__LINE__", @"alias", @"and", @"begin", @"break", @"case", @"class", @"def", @"defined", @"do", @"else", @"elsif", @"end", @"ensure", @"false", @"for", @"if", @"in", @"module", @"next", @"nil", @"not", @"or", @"redo", @"rescue", @"retry", @"return", @"self", @"super", @"then", @"true", @"undef", @"unless", @"until", @"when", @"while", @"yield", nil];
    
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
    extensions = [NSArray arrayWithObjects:@"rb", @"rbw", nil];
  }
  
  if (URL && [extensions containsObject:[URL pathExtension]])
    return YES;
  
  if (textContents.length >= 15 && [[textContents substringToIndex:15] isEqualToString:@"#!/usr/bin/ruby"])
    return YES;

  
  return NO;
}

@end
