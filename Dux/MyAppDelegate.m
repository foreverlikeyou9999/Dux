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

@implementation MyAppDelegate
@synthesize openQuicklyController;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
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
