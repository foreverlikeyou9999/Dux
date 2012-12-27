//
//  DuxOpenQuicklyTableViewCell.m
//  Dux
//
//  Created by Abhi Beckert on 2011-11-25.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import "DuxOpenQuicklyTableViewCell.h"

@implementation DuxOpenQuicklyTableViewCell

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
  // init static text attributes
  static NSDictionary *filenameAttributes = nil;
  static NSDictionary *pathAttributes = nil;
  static NSLayoutManager *layoutManager = nil;
  static NSTextContainer *textContainer = nil;
  static NSTextStorage *textStorage = nil;
  if (!filenameAttributes) {
    NSMutableParagraphStyle *pathParagrpahStyle = [[[NSParagraphStyle alloc] init] mutableCopy];
    [pathParagrpahStyle setLineBreakMode:NSLineBreakByTruncatingHead];
    
    filenameAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:13], NSFontAttributeName, nil];
    pathAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:11], NSFontAttributeName,
    [NSColor grayColor], NSForegroundColorAttributeName,
    [pathParagrpahStyle copy], NSParagraphStyleAttributeName, nil];
    
    layoutManager = [[NSLayoutManager alloc] init];
    textContainer = [[NSTextContainer alloc] init];
    textStorage = [[NSTextStorage alloc] init];
    
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
  }
  
  // data to be rendered
  NSURL *url = self.objectValue;
  NSString *filename = url.lastPathComponent;
  
  // render filename
  NSRect filenameRect = NSMakeRect(NSMinX(cellFrame) + 5,
                                   NSMinY(cellFrame) + 2,
                                   NSMaxX(cellFrame) - 10,
                                   17);
  [textStorage replaceCharactersInRange:NSMakeRange(0, textStorage.length) withAttributedString:[[NSAttributedString alloc] initWithString:filename attributes:filenameAttributes]];
  textContainer.containerSize = filenameRect.size;
  [layoutManager drawGlyphsForGlyphRange:[layoutManager glyphRangeForTextContainer:textContainer] atPoint:filenameRect.origin];
  
  // render path
  NSRect pathRect = NSMakeRect(NSMinX(cellFrame) + 5,
                               NSMinY(cellFrame) + 18,
                               NSMaxX(cellFrame) - 10,
                               17);
  [textStorage replaceCharactersInRange:NSMakeRange(0, textStorage.length) withAttributedString:[[NSAttributedString alloc] initWithString:url.relativePath attributes:pathAttributes]];
  textContainer.containerSize = pathRect.size;
  [layoutManager drawGlyphsForGlyphRange:[layoutManager glyphRangeForTextContainer:textContainer] atPoint:pathRect.origin];
}

@end
