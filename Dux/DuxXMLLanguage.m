//
//  DuxXMLLanguage.m
//  Dux
//
//  Created by Abhi Beckert on 2011-11-20.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import "DuxXMLLanguage.h"
#import "DuxXMLBaseElement.h"

@implementation DuxXMLLanguage

+ (void)load
{
  [DuxLanguage registerLanguage:[self class]];
}

- (DuxLanguageElement *)baseElement
{
  return [DuxXMLBaseElement sharedInstance];
}

- (void)wrapCommentsAroundRange:(NSRange)commentRange ofTextView:(NSTextView *)textView
{
  NSString *existingString = [textView.textStorage.string substringWithRange:commentRange];
  NSString *commentedString = [NSString stringWithFormat:@"<!-- %@ -->", existingString];
  
  [textView insertText:commentedString replacementRange:commentRange];
}

+ (BOOL)isDefaultLanguageForURL:(NSURL *)URL textContents:(NSString *)textContents
{
  static NSArray *extensions = nil;
  if (!extensions) {
    extensions = [NSArray arrayWithObjects:@"xml", nil];
  }
  
  if (URL && [extensions containsObject:[URL pathExtension]])
    return YES;
  
  if (textContents.length >= 5 && [[textContents substringToIndex:5] isEqualToString:@"<?xml"])
    return YES;
  
  return NO;
}

@end
