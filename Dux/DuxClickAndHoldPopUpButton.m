//
//  DuxClickAndHoldPopUpButton.m
//  Dux
//
//  Created by Abhi Beckert on 2012-12-30.
//
//

#import "DuxClickAndHoldPopUpButton.h"

@interface DuxClickAndHoldPopUpButton ()

@property BOOL mouseIsDown;
@property BOOL menuWasShownForLastMouseDown;
@property int mouseDownUniquenessCounter;

@end

@implementation DuxClickAndHoldPopUpButton

// highlight the button immediately but wait a moment before calling the super method (which will show our popup menu) if the mouse comes up
// in that moment, don't tell the super method about the mousedown at all.
- (void)mouseDown:(NSEvent *)theEvent
{
  self.mouseIsDown = YES;
  self.menuWasShownForLastMouseDown = NO;
  self.mouseDownUniquenessCounter++;
  int mouseDownUniquenessCounterCopy = self.mouseDownUniquenessCounter;
  
  [self highlight:YES];
  
  float delayInSeconds = 0.2;
  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
  dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    if (self.mouseIsDown && mouseDownUniquenessCounterCopy == self.mouseDownUniquenessCounter) {
      self.menuWasShownForLastMouseDown = YES;
      [super mouseDown:theEvent];
    }
  });
}

// if the mouse was down for a short enough period to avoid showing a popup menu, fire our target/action with no selected menu item, then
// remove the button highlight.
- (void)mouseUp:(NSEvent *)theEvent
{
  self.mouseIsDown = NO;
  
  if (!self.menuWasShownForLastMouseDown) {
    [self selectItem:nil];
    
    [self sendAction:self.action to:self.target];
  }
  
  [self highlight:NO];
}

@end
