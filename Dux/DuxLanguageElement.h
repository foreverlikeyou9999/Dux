//
//  DuxLanguageElement.h
//  Dux
//
//  Created by Abhi Beckert on 2011-10-22.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import <Foundation/Foundation.h>

@class DuxLanguage;

@interface DuxLanguageElement : NSObject

@property (strong) DuxLanguage *language;
@property (readonly) BOOL shouldHighlightOtherIdenticalElements;

+ (id)sharedInstance;

- (id)initWithLanguage:(DuxLanguage *)language; // designated
- (id)init; // all subclasses must implement this, to call initWithLanguage: instead

/**
 * Calculate the length of this language element in a string
 * 
 * @param string - the entire language string
 * @param startingAt - the start position of this element
 * @param *nextElement - if one is provided, this element will be pushed to the stack. if left as nil, then the reciever will be popped off the stack
 * @return NSUintger
 */
- (NSUInteger)lengthInString:(NSAttributedString *)string startingAt:(NSUInteger)startingAt nextElement:(DuxLanguageElement *__strong*)nextElement;

- (NSColor *)color;
- (BOOL)isComment;

@end
