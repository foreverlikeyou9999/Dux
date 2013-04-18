//
//  DuxAcknowledgementsController.m
//  Dux
//
//  Created by Abhi Beckert on 2013-4-19.
//
//

#import "DuxAcknowledgementsController.h"

@implementation DuxAcknowledgementsController

+ (void)showAcknowledgementsWindow
{
  static DuxAcknowledgementsController *viewController = nil;
  
  if (!viewController) {
    viewController = [[DuxAcknowledgementsController alloc] initWithWindowNibName:@"Acknowledgements"];
  }
  
  [viewController showWindow:self];
}

- (void)windowDidLoad
{
  NSString *license = [NSString stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"license" withExtension:@"txt" subdirectory:@"Fonts"] usedEncoding:NULL error:NULL];
  
  
  [self.textView.textStorage replaceCharactersInRange:NSMakeRange(0, self.textView.textStorage.length) withString:license];
}


@end
