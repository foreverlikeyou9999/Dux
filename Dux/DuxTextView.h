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
  NSUInteger _lastUupdateHighlightedElements;
	
  NSUInteger lastProcessLinesStringHash;
  NSUInteger lineCharacterIndexes[100000]; // characted index of every line. used to draw line numbers. Unused line indexes contain NSNotFound. We do not draw line numbers after 99,999 lines (too slow, and the gutter is too narrow to fit them anyway)
}

@property (weak) MyTextDocument *textDocument;
@property (weak) DuxSyntaxHighlighter *highlighter;
@property (strong) NSSet *highlightedElements;
@property BOOL showLineNumbers;
@property BOOL showPageGuide;
@property NSUInteger pageGuidePosition;

@property (strong) IBOutlet NSPanel *goToLinePanel;
@property (weak) IBOutlet NSSearchField *goToLineSearchField;

- (void)initDuxTextView;

- (IBAction)jumpToLine:(id)sender;
- (IBAction)goToLinePanelButtonClicked:(id)sender;

- (IBAction)commentSelection:(id)sender; // will forward to uncommentSelection: if the selection is commented
- (IBAction)uncomment:(NSRange)commentRange;
- (IBAction)shiftSelectionLeft:(id)sender;
- (IBAction)shiftSelectionRight:(id)sender;

- (void)insertSnippet:(NSString *)snippet;

- (void)moveSubwordBackward:(id)sender;
- (void)moveSubwordBackwardAndModifySelection:(id)sender;
- (void)moveSubwordForward:(id)sender;
- (void)moveSubwordForwardAndModifySelection:(id)sender;
- (void)deleteSubwordBackward:(id)sender;
- (void)deleteSubwordForward:(id)sender;

- (NSUInteger)findBeginingOfSubwordStartingAt:(NSUInteger)offset;
- (NSUInteger)findEndOfSubwordStartingAt:(NSUInteger)offset;

- (void)selectionDidChange:(NSNotification *)notif;

- (void)updateHighlightedElements;
- (void)processLines;
- (void)drawLineNumbersInRect:(NSRect)targetRect;

- (BOOL)insertionPointInLeadingWhitespace;
- (BOOL)tabShouldIndentWithCurrentSelectedRange;

- (NSUInteger)countSpacesInLeadingWhitespace:(NSString *)lineString;

@end
