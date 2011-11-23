//
//  MyAppDelegate.m
//  Dux
//
//  Created by Abhi Beckert on 2011-08-25.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import "MyAppDelegate.h"
#import "NSStringDuxAdditions.h"

@implementation MyAppDelegate
@synthesize openQuicklyController;

- (id)init
{
  if (!(self = [super init]))
    return nil;
  
  return self;
}

- (IBAction)openQuickly:(id)sender
{
  if (!openQuicklyController) {
    [NSBundle loadNibNamed:@"OpenQuickly" owner:self];
  }
  
  [self.openQuicklyController showOpenQuicklyPanel];
}

@end
