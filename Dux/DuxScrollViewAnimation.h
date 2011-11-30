//
//  DuxScrollViewAnimation.h
//  Dux
//
//  Created by Woody Beckert on 2011-11-30.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface DuxScrollViewAnimation : NSAnimation

@property (retain) NSScrollView *scrollView;
@property NSPoint originPoint;
@property NSPoint targetPoint;

+ (void)animatedScrollPointToCenter:(NSPoint)targetPoint inScrollView:(NSScrollView *)scrollView;
+ (void)animatedScrollToPoint:(NSPoint)targetPoint inScrollView:(NSScrollView *)scrollView;

@end
