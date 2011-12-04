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

static NSCharacterSet *newlineCharacterSet;
static NSCharacterSet *nonWhitespaceCharacterSet;

+ (void)initialize
{
  [super initialize];
  
  newlineCharacterSet = [NSCharacterSet newlineCharacterSet];
  nonWhitespaceCharacterSet = [[NSCharacterSet whitespaceCharacterSet] invertedSet];
}

+ (id)stringWithUnknownData:(NSData *)data usedEncoding:(NSStringEncoding *)enc
{
  // list encodings, in the order we should check (the order was chosen after trial/error)
  NSUInteger encodingsCount = 6;
  NSUInteger encodings[6] = {
    NSUTF8StringEncoding,               //  Unicode (UTF-8)
    NSWindowsCP1252StringEncoding,      //  Western (Windows Latin 1)
    NSUnicodeStringEncoding,            //  Unicode (UTF-16)
    NSISOLatin1StringEncoding,          //  Western (ISO Latin 1)
    NSMacOSRomanStringEncoding,         //  Western (Mac OS Roman)
    NSNonLossyASCIIStringEncoding       //  Non-lossy ASCII
  };
  
  NSString *string = nil;
  NSUInteger encodingIndex;
  for (encodingIndex = 0; encodingIndex < encodingsCount && !string; encodingIndex++) {
    string = [[NSString alloc] initWithData:data encoding:encodings[encodingIndex]];
    
    if (string) {
      *enc = encodings[encodingIndex];
      return string;
    }
  }
  
  return nil;
}

- (NSRange)rangeOfLineAtOffset:(NSUInteger)location
{
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
  NSUInteger lineBegining = [self rangeOfCharacterFromSet:newlineCharacterSet options:NSBackwardsSearch range:NSMakeRange(0, location)].location;
  
  if (lineBegining == NSNotFound) {
    return 0;
  }
  
  return lineBegining + 1;
}

- (NSUInteger)endOfLineAtOffset:(NSUInteger)location
{
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
    characterLocation = [self rangeOfCharacterFromSet:newlineCharacterSet options:NSLiteralSearch range:NSMakeRange(characterLocation, (stringLength - characterLocation))].location;
    
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
  
  NSUInteger characterLocation = [self rangeOfCharacterFromSet:newlineCharacterSet options:NSLiteralSearch range:NSMakeRange(0, (self.length))].location;
    
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
  while (characterLocation < stringLength) {
    characterLocation = [self rangeOfCharacterFromSet:newlineCharacterSet options:NSLiteralSearch range:NSMakeRange(characterLocation, (stringLength - characterLocation))].location;
    
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

- (DuxStringLineEnumerator *)lineEnumeratorForLinesInRange:(NSRange)range
{
  return [[DuxStringLineEnumerator alloc] initWithString:self forLinesInRange:range];
}

- (NSString *)whitespaceForLineBeginingAtLocation:(NSUInteger)lineBegining
{
  if (self.length == 0)
    return @"";
  
  NSUInteger charLocation = [self rangeOfCharacterFromSet:nonWhitespaceCharacterSet options:NSLiteralSearch range:NSMakeRange(lineBegining, self.length - lineBegining)].location;
  
  if (charLocation == NSNotFound)
    charLocation = self.length;
  
  if (charLocation == lineBegining)
    return @"";
  
  return [self substringWithRange:NSMakeRange(lineBegining, charLocation - lineBegining)];
}

- (NSUInteger)countOccurancesOfString:(NSString *)substring
{
  NSUInteger count = 0;
  NSUInteger searchPosition = 0;
  NSUInteger stringLength = self.length;
  
  while (searchPosition < stringLength) {
    searchPosition = [self rangeOfString:substring options:NSLiteralSearch range:NSMakeRange(searchPosition, stringLength - searchPosition)].location;
    
    if (searchPosition == NSNotFound)
      break;
    
    count++;
    searchPosition += substring.length;
  }
  
  return count;
}

@end
