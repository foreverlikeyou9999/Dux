//
//  NSStringDuxAdditions.m
//  Dux
//
//  Created by Abhi Beckert on 2011-11-18.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import "NSStringDuxAdditions.h"

@implementation NSString (NSStringDuxAdditions)

static NSCharacterSet *newlineCharacterSet = nil;

- (NSRange)rangeOfLineAtOffset:(NSUInteger)location
{
  if (!newlineCharacterSet) {
    newlineCharacterSet = [NSCharacterSet newlineCharacterSet];
  }
  
  NSUInteger lineBegining = [self rangeOfCharacterFromSet:newlineCharacterSet options:NSBackwardsSearch range:NSMakeRange(0, location)].location;
  if (lineBegining == NSNotFound) {
    lineBegining = 0;
  } else {
    lineBegining++;
  }
  
  NSUInteger lineEnd = [self rangeOfCharacterFromSet:newlineCharacterSet options:0 range:NSMakeRange(location, self.length - location)].location;
  if (lineEnd == NSNotFound) {
    lineEnd = self.length;
  }
  
  return NSMakeRange(lineBegining, lineEnd - lineBegining);
}

- (NSUInteger)beginingOfLineAtOffset:(NSUInteger)location
{
  if (!newlineCharacterSet) {
    newlineCharacterSet = [NSCharacterSet newlineCharacterSet];
  }
  
  NSUInteger lineBegining = [self rangeOfCharacterFromSet:newlineCharacterSet options:NSBackwardsSearch range:NSMakeRange(0, location)].location;
  
  if (lineBegining == NSNotFound) {
    return 0;
  }
  
  return lineBegining + 1;
}

- (NSUInteger)endOfLineAtOffset:(NSUInteger)location
{
  if (!newlineCharacterSet) {
    newlineCharacterSet = [NSCharacterSet newlineCharacterSet];
  }
  
  NSUInteger lineEnd = [self rangeOfCharacterFromSet:newlineCharacterSet options:0 range:NSMakeRange(location, self.length - location)].location;
  
  if (lineEnd == NSNotFound) {
    return self.length;
  }
  
  return lineEnd;
}

@end
