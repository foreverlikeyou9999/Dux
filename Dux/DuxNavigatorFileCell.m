//
//  DuxNavigatorFileCell.m
//  Dux
//
//  Created by Matt Langtree on 2013-4-22.
//
//

#import "DuxNavigatorFileCell.h"

#define kDefaultIconImageSize   16.0
#define kImageFrameXOffset      3
#define kImageFrameYOffset      1
#define kTextFrameXOffset       6
#define kTextFrameYOffset       2

@interface DuxNavigatorFileCell ()
@property (readwrite, strong) NSImage *image;
@end

@implementation DuxNavigatorFileCell

- (id)init
{
	self = [super init];
	if (self)
  {
    [self setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
  }
	return self;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
  NSRect newCellFrame = cellFrame;
  NSRect imageFrame;

  NSSize	imageSize = CGSizeMake(kDefaultIconImageSize, kDefaultIconImageSize);
  NSDivideRect(newCellFrame, &imageFrame, &newCellFrame, imageSize.width, NSMinXEdge);
  if ([self drawsBackground])
  {
      [[self backgroundColor] set];
      NSRectFill(imageFrame);
  }

  imageFrame.origin.y += kImageFrameYOffset;
  imageFrame.origin.x += kImageFrameXOffset;
  imageFrame.size = imageSize;

  [self.image drawInRect:imageFrame
                fromRect:NSZeroRect
               operation:NSCompositeSourceOver
                fraction:1.0
          respectFlipped:YES
                   hints:nil];

  newCellFrame.origin.x += kTextFrameXOffset;
  newCellFrame.size.width -= kTextFrameXOffset;
  newCellFrame.origin.y += kTextFrameYOffset;
  newCellFrame.size.height -= (kTextFrameYOffset / 2);

  [super drawWithFrame:newCellFrame inView:controlView];
}

@end

