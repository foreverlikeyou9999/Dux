//
//  DuxLineNumberString.m
//  Dux
//
//  Created by Abhi Beckert on 2011-11-26.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import "DuxLineNumberString.h"
#import "DuxPreferences.h"

static NSDictionary *marginAttributes = nil;
static NSMutableArray *lineNumberStrings = nil;

static NSLayoutManager *layoutManager = nil;
static NSTextContainer *textContainer = nil;
static NSTextStorage *textStorage = nil;


@implementation DuxLineNumberString

+ (void)initialize
{
  [super initialize];
  
  NSMutableParagraphStyle *paragraphStyle = [[[NSParagraphStyle alloc] init] mutableCopy];
  [paragraphStyle setAlignment:NSRightTextAlignment];
  [paragraphStyle setLineBreakMode:NSLineBreakByTruncatingMiddle];
if ([DuxPreferences editorDarkMode]) {
  marginAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:[NSFont fontWithName:@"Source Code Pro ExtraLight" size:10], NSFontAttributeName,
                      [NSColor colorWithCalibratedWhite:1 alpha:0.8], NSForegroundColorAttributeName,
                      paragraphStyle, NSParagraphStyleAttributeName,
                      nil];
} else {
  marginAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:[NSFont fontWithName:@"Source Code Pro Light" size:10], NSFontAttributeName,
                      [NSColor colorWithCalibratedWhite:0 alpha:1], NSForegroundColorAttributeName,
                      paragraphStyle, NSParagraphStyleAttributeName,
                      nil];
}
  lineNumberStrings = [[NSMutableArray alloc] initWithCapacity:10000];
  
  layoutManager = [[NSLayoutManager alloc] init];
  textContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(37, 16)];
  textStorage = [[NSTextStorage alloc] init];
  
  [layoutManager addTextContainer:textContainer];
  [textStorage addLayoutManager:layoutManager];
}

+ (DuxLineNumberString *)stringForNumber:(NSUInteger)number
{
  if (lineNumberStrings.count <= number) {
    NSUInteger destIndex = number + 1000;
    NSUInteger index = lineNumberStrings.count;
    while (index < destIndex) {
      [lineNumberStrings addObject:[[DuxLineNumberString alloc] initWithNumber:index]];
      index++;
    }
  }
  
  return [lineNumberStrings objectAtIndex:number];
}

- (id)initWithNumber:(NSUInteger)number
{
  if (!(self = [super init]))
    return nil;
  
  string = [[NSString alloc] initWithFormat:@"%lu", (unsigned long)number];
  
  return self;
}

- (void)drawInRect:(NSRect)lineFragmentRect
{
  [textStorage replaceCharactersInRange:NSMakeRange(0, textStorage.length) withAttributedString:[[NSAttributedString alloc] initWithString:string attributes:marginAttributes]];
  
  NSPoint drawPoint = NSMakePoint(-4, lineFragmentRect.origin.y + 3);
  [layoutManager drawGlyphsForGlyphRange:[layoutManager glyphRangeForTextContainer:textContainer] atPoint:drawPoint];
}

- (void)drawAtY:(float)lineY
{
  [textStorage replaceCharactersInRange:NSMakeRange(0, textStorage.length) withAttributedString:[[NSAttributedString alloc] initWithString:string attributes:marginAttributes]];
  
  NSPoint drawPoint = NSMakePoint(-4, lineY + 2);
  [layoutManager drawGlyphsForGlyphRange:[layoutManager glyphRangeForTextContainer:textContainer] atPoint:drawPoint];
}

@end
