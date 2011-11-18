//
//  DuxHTMLLanguage.m
//  Dux
//
//  Created by Abhi Beckert on 2011-10-22.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import "DuxHTMLLanguage.h"

@implementation DuxHTMLLanguage

- (DuxLanguageElement *)baseElement
{
  return [DuxHTMLBaseElement sharedInstance];
}

- (void)wrapCommentsAroundRange:(NSRange)commentRange ofTextView:(NSTextView *)textView
{
  NSString *existingString = [textView.textStorage.string substringWithRange:commentRange];
  NSString *commentedString = [NSString stringWithFormat:@"<!-- %@ -->", existingString];
  
  [textView insertText:commentedString replacementRange:commentRange];
}

@end
