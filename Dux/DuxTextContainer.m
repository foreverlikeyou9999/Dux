//
//  DuxTextContainer.m
//  Dux
//
//  Created by Abhi Beckert on 2011-11-25.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import "DuxTextContainer.h"

@implementation DuxTextContainer

- (NSRect)lineFragmentRectForProposedRect:(NSRect)proposedRect sweepDirection:(NSLineSweepDirection)sweepDirection movementDirection:(NSLineMovementDirection)movementDirection remainingRect:(NSRectPointer)remainingRect
{
  proposedRect.origin.x = 34;
  
  return [super lineFragmentRectForProposedRect:proposedRect sweepDirection:sweepDirection movementDirection:movementDirection remainingRect:remainingRect];
}

@end
