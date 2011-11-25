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

@class MyTextDocument;

@interface DuxTextView : NSTextView <NSTextViewDelegate>
{
}

@property (weak) MyTextDocument *textDocument;
@property (weak) DuxSyntaxHighlighter *highlighter;

@property (strong) IBOutlet NSPanel *goToLinePanel;
@property (weak) IBOutlet NSSearchField *goToLineSearchField;

- (void)initDuxTextView;

- (IBAction)jumpToLine:(id)sender;
- (IBAction)goToLinePanelButtonClicked:(id)sender;

- (IBAction)commentSelection:(id)sender; // will forward to uncommentSelection: if the selection is commented
- (IBAction)uncomment:(NSRange)commentRange;

- (void)moveSubwordBackward:(id)sender;
- (void)moveSubwordBackwardAndModifySelection:(id)sender;
- (void)moveSubwordForward:(id)sender;
- (void)moveSubwordForwardAndModifySelection:(id)sender;
- (void)deleteSubwordBackward:(id)sender;
- (void)deleteSubwordForward:(id)sender;

- (NSUInteger)findBeginingOfSubwordStartingAt:(NSUInteger)offset;
- (NSUInteger)findEndOfSubwordStartingAt:(NSUInteger)offset;

@end
