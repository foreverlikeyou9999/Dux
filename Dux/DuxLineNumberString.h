//
//  DuxLineNumberString.h
//  Dux
//
//  Created by Abhi Beckert on 2011-11-26.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import <AppKit/AppKit.h>

@interface DuxLineNumberString : NSObject {
  NSString *string;
}

// high performance method to return a singleton object for a given number
+ (DuxLineNumberString *)stringForNumber:(NSUInteger)number;

// designated initilaizer
- (id)initWithNumber:(NSUInteger)number;

// draw the line
- (void)drawInRect:(NSRect)lineFragmentRect;
- (void)drawAtY:(float)lineY;

@end
