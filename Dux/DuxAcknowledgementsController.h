//
//  DuxAcknowledgementsController.h
//  Dux
//
//  Created by Abhi Beckert on 2013-4-19.
//
//

#import <Cocoa/Cocoa.h>

@interface DuxAcknowledgementsController : NSWindowController

@property (unsafe_unretained) IBOutlet NSTextView *textView;

+ (void)showAcknowledgementsWindow;

@end
