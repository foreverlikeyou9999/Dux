//
//  DuxSyntaxHighlighter.h
//  Dux
//
//  Created by Abhi Beckert on 2011-10-22.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import <Foundation/Foundation.h>
#import "DuxLanguage.h"
#import "DuxHTMLLanguage.h"
#import "DuxPHPLanguage.h"

@interface DuxSyntaxHighlighter : NSObject <NSTextStorageDelegate> {
  NSDictionary *baseAttributes;
  DuxLanguage *baseLanguage;
}

- (id)init; // designated

@property (strong, readonly) NSDictionary *baseAttributes;
@property (strong, readonly) DuxLanguage *baseLanguage;

- (void)setBaseLanguage:(DuxLanguage *)newBaseLanguage forTextStorage:(NSTextStorage *)textStorage;

- (void)updateHighlightingForStorage:(NSTextStorage *)textStorage;

- (DuxLanguage *)languageForRange:(NSRange)range ofTextStorage:(NSTextStorage *)textStorage;

@end
