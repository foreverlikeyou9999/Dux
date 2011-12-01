//
//  NSStringDuxAdditions.h
//  Dux
//
//  Created by Abhi Beckert on 2011-11-18.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import <Foundation/Foundation.h>

enum {
  DuxNewlineUnknown = 0,
  DuxNewlineUnix = 1,
  DuxNewlineWindows = 2,
  DuxNewlineClassicMac = 4
};
typedef NSUInteger DuxNewlineOptions;

@interface NSString (NSStringDuxAdditions)

+ (id)stringWithUnknownData:(NSData *)data usedEncoding:(NSStringEncoding *)enc;

- (NSRange)rangeOfLineAtOffset:(NSUInteger)location;
- (NSUInteger)beginingOfLineAtOffset:(NSUInteger)location;
- (NSUInteger)endOfLineAtOffset:(NSUInteger)location;

- (DuxNewlineOptions)newlineStyles;
- (DuxNewlineOptions)newlineStyleForFirstNewline;
+ (NSString *)stringForNewlineStyle:(DuxNewlineOptions)newlineStyle;

- (NSString *)stringByReplacingNewlinesWithNewline:(DuxNewlineOptions)newlineStyle;

@end
