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

- (void)wrapCommentsAroundRange:(NSRange)commentRange ofTextView:(NSTextView *)textView
{
  NSString *existingString = [textView.textStorage.string substringWithRange:commentRange];
  
  NSString *commentedString= [NSString stringWithFormat:@"> %@", existingString];
  commentedString = [commentedString stringByReplacingOccurrencesOfString:@"(\n)" withString:@"$1> " options:NSRegularExpressionSearch range:NSMakeRange(0, commentedString.length)];
  
  [textView insertText:commentedString replacementRange:commentRange];
  [textView setSelectedRange:NSMakeRange(commentRange.location, commentedString.length)];
}

+ (BOOL)isDefaultLanguageForURL:(NSURL *)URL textContents:(NSString *)textContents
{
  // we are the default when no other language returns YES here
  return NO;
}

@end
