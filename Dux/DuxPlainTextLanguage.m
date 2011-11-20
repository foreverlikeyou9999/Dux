//
//  DuxPlainTextLanguage.m
//  Dux
//
//  Created by Woody Beckert on 2011-11-20.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DuxPlainTextLanguage.h"
#import "DuxPlainTextBaseElement.h"

@implementation DuxPlainTextLanguage

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

@end
