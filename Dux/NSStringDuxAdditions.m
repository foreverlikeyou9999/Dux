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

- (DuxNewlineOptions)newlineStyles
{
  NSUInteger stringLength = self.length;
  
  NSUInteger characterLocation = 0;
  DuxNewlineOptions newlineStyles = DuxNewlineUnknown;
  DuxNewlineOptions characterNewlineType;
  while (characterLocation < stringLength) {
    characterLocation = [self rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:NSLiteralSearch range:NSMakeRange(characterLocation, (stringLength - characterLocation))].location;
    
    if (characterLocation == NSNotFound) {
      break;
    }
    
    // type of newline?
    unichar newlineChar = [self characterAtIndex:characterLocation];
    if (newlineChar == '\n') {
      characterNewlineType = DuxNewlineUnix;
    } else {
      characterNewlineType = DuxNewlineClassicMac;
    }
    
    // if we are at a \r character and the next character is a \n, we have windows newlines and should skip the next character
    if (characterNewlineType == DuxNewlineClassicMac &&
        stringLength > characterLocation &&
        [self characterAtIndex:characterLocation + 1] == '\n') {
      
      characterNewlineType = DuxNewlineWindows;
      characterLocation++;
    }
    
    newlineStyles |= characterNewlineType;
    characterLocation++;
  }
  
  return newlineStyles;
}

- (DuxNewlineOptions)newlineStyleForFirstNewline
{
  DuxNewlineOptions newlineStyle;
  
  NSUInteger characterLocation = [self rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:NSLiteralSearch range:NSMakeRange(0, (self.length))].location;
    
  if (characterLocation == NSNotFound) {
    return DuxNewlineUnknown;
  }
  
  // type of newline?
  unichar newlineChar = [self characterAtIndex:characterLocation];
  if (newlineChar == '\n') {
    newlineStyle = DuxNewlineUnix;
  } else {
    newlineStyle = DuxNewlineClassicMac;
  }
  
  // if we are at a \r character and the next character is a \n, we have windows newlines and should skip the next character
  if (newlineStyle == DuxNewlineClassicMac &&
      self.length >= characterLocation &&
      [self characterAtIndex:characterLocation + 1] == '\n') {
    
    newlineStyle = DuxNewlineWindows;
  }
  
  return newlineStyle;
}

+ (NSString *)stringForNewlineStyle:(DuxNewlineOptions)newlineStyle
{
  if (newlineStyle & DuxNewlineClassicMac)
    return @"\r";
  
  if (newlineStyle & DuxNewlineWindows)
    return @"\r\n";
  
  return @"\n";
}

- (NSString *)stringByReplacingNewlinesWithNewline:(DuxNewlineOptions)newlineStyle
{
  NSString *newlineSting = [[self class] stringForNewlineStyle:newlineStyle];
  
  
  NSMutableString *newString = [NSMutableString stringWithCapacity:self.length];
  
  NSUInteger stringLength = self.length;
  NSUInteger previousCharacterLocation = 0;
  NSUInteger characterLocation = 0;
  DuxNewlineOptions characterNewlineType;
  NSCharacterSet *newlineCharset = [NSCharacterSet newlineCharacterSet];
  while (characterLocation < stringLength) {
    characterLocation = [self rangeOfCharacterFromSet:newlineCharset options:NSLiteralSearch range:NSMakeRange(characterLocation, (stringLength - characterLocation))].location;
    
    if (characterLocation == NSNotFound) {
      if (previousCharacterLocation != stringLength)
        [newString appendString:[self substringWithRange:NSMakeRange(previousCharacterLocation, stringLength - previousCharacterLocation)]];
      break;
    }
    
    if (characterLocation != previousCharacterLocation)
      [newString appendString:[self substringWithRange:NSMakeRange(previousCharacterLocation, characterLocation - previousCharacterLocation)]];
    
    // type of newline?
    unichar newlineChar = [self characterAtIndex:characterLocation];
    if (newlineChar == '\n') {
      characterNewlineType = DuxNewlineUnix;
    } else {
      characterNewlineType = DuxNewlineClassicMac;
    }
    
    // if we are at a \r character and the next character is a \n, we have windows newlines and should skip the next character
    if (characterNewlineType == DuxNewlineClassicMac &&
        stringLength >= characterLocation &&
        [self characterAtIndex:characterLocation + 1] == '\n') {
      
      characterNewlineType = DuxNewlineWindows;
    }
    
    [newString appendString:newlineSting];
    
    characterLocation++;
    if (characterNewlineType == DuxNewlineWindows)
      characterLocation++;
    
    previousCharacterLocation = characterLocation;
  }
  
  return [newString copy];
}

@end
