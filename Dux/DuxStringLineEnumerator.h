//
//  DuxStringLineEnumerator.h
//  Dux
//
//  Created by Abhi Beckert on 2011-12-04.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import <Foundation/Foundation.h>

@interface DuxStringLineEnumerator : NSEnumerator
{
  NSString *targetString;
  NSRange targetRange;
  NSUInteger characterLocation;
  NSUInteger targetStringLength;
}

- (id)initWithString:(NSString *)string forLinesInRange:(NSRange)range;

@end
