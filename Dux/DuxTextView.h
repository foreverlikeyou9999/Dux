//
//  DuxTextView.h
//  Dux
//
//  Created by Abhi Beckert on 2011-10-20.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import <AppKit/AppKit.h>
#import "NSStringDuxAdditions.h"
#import "DuxSyntaxHighlighter.h"

@interface DuxTextView : NSTextView
{
}

@property (weak) DuxSyntaxHighlighter *highlighter;

@property (strong) IBOutlet NSPanel *goToLinePanel;
@property (weak) IBOutlet NSSearchField *goToLineSearchField;

- (IBAction)jumpToLine:(id)sender;
- (IBAction)goToLinePanelButtonClicked:(id)sender;
- (IBAction)commentSelection:(id)sender;

@end
