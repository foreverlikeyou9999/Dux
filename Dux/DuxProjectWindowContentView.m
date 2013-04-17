//
//  DuxProjectWindowContentView.m
//  Dux
//
//  Created by Abhi Beckert on 2013-4-17.
//
//

#import "DuxProjectWindowContentView.h"

@implementation DuxProjectWindowContentView

- (void)awakeFromNib
{
  NSLog(@"%@", self.layer);
}

- (BOOL)wantsLayer
{
  return YES;
}

- (BOOL)isOpaque
{
  return NO;
}

- (void)drawRect:(NSRect)dirtyRect
{
  [[NSColor redColor] set];
  [NSBezierPath fillRect:dirtyRect];
}

@end
