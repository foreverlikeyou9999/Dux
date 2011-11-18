//
//  DuxLanguage.h
//  Dux
//
//  Created by Abhi Beckert on 2011-10-22.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import <Foundation/Foundation.h>
#import "DuxLanguageElement.h"

@interface DuxLanguage : NSObject

+ (id)sharedInstance;

- (DuxLanguageElement *)baseElement;

- (void)wrapCommentsAroundRange:(NSRange)commentRange ofTextView:(NSTextView *)textView;

- (void)prepareToParseTextStorage:(NSTextStorage *)textStorage;

@end
