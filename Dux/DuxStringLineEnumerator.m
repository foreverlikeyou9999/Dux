//
//  DuxStringLineEnumerator.m
//  Dux
//
//  Created by Abhi Beckert on 2011-12-04.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import "DuxStringLineEnumerator.h"

@implementation DuxStringLineEnumerator

static NSCharacterSet *newlineCharacterSet;

+ (void)initialize
{
  [super initialize];
  
  newlineCharacterSet = [NSCharacterSet newlineCharacterSet];
}

- (id)initWithString:(NSString *)string forLinesInRange:(NSRange)range
{
  if (!(self = [super init]))
    return nil;
  
  // init basic vars
  targetString = string;
  targetRange = range;
  targetStringLength = string.length;
  
  // find the begining of the first line
  characterLocation = [targetString rangeOfCharacterFromSet:newlineCharacterSet options:NSBackwardsSearch | NSLiteralSearch range:NSMakeRange(0, targetRange.location)].location;
  if (characterLocation == NSNotFound) {
    characterLocation = 0;
  } else {
    characterLocation++;
  }
  
  return self;
}

- (id)nextObject
{
  if (characterLocation >= NSMaxRange(targetRange) && characterLocation != targetRange.location)
    return nil;
  
  NSUInteger lineEnd = [targetString rangeOfCharacterFromSet:newlineCharacterSet options:0 range:NSMakeRange(characterLocation, targetStringLength - characterLocation)].location;
  if (lineEnd == NSNotFound) {
    lineEnd = targetStringLength;
  }
  
  NSRange lineRange = NSMakeRange(characterLocation, lineEnd - characterLocation);
  characterLocation = NSMaxRange(lineRange) + 1;
  
  return [NSValue valueWithRange:lineRange];
}

@end
