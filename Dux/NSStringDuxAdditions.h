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

@interface NSString (NSStringDuxAdditions)

- (NSRange)rangeOfLineAtOffset:(NSUInteger)location;
- (NSUInteger)beginingOfLineAtOffset:(NSUInteger)location;
- (NSUInteger)endOfLineAtOffset:(NSUInteger)location;

@end
