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

@synthesize leftGutterWidth;

- (void)setContainerSize:(NSSize)size
{
	[super setContainerSize:size];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:DuxTextContainerSizeDidChangeNotification object:self];
}

@end

const NSString *DuxTextContainerSizeDidChangeNotification = @"DuxTextContainerSizeDidChangeNotification";