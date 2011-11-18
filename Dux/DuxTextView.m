//
//  DuxTextView.m
//  Dux
//
//  Created by Abhi Beckert on 2011-10-20.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import "DuxTextView.h"

@implementation DuxTextView

@synthesize highlighter;
@synthesize goToLinePanel;
@synthesize goToLineSearchField;

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib
{
  [super awakeFromNib];
  
  [self addObserver:self forKeyPath:@"textStorage.delegate" options:NSKeyValueChangeSetting context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  if (object != self)
    return;
  
  if ([keyPath isEqualToString:@"textStorage.delegate"]) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syntaxHighlighterDidFinishHighlighting:) name:@"DuxSyntaxHighlighterDidFinishHighlighting" object:self.textStorage.delegate];
  }
}

- (void)syntaxHighlighterDidFinishHighlighting:(NSNotification *)notif
{
  if (self.textStorage.length == 0)
    return;
  
  NSUInteger index = (self.selectedRange.location > 0) ? self.selectedRange.location - 1 : 0;
  index = MIN(index, self.textStorage.length - 1);
  [self setTypingAttributes:[self.textStorage attributesAtIndex:index effectiveRange:NULL]];
}

- (void)insertNewline:(id)sender
{
  // find the start of the current line
  NSUInteger lineStart = 0;
  NSRange newlineRange = [self.textStorage.string rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:NSBackwardsSearch range:NSMakeRange(0, self.selectedRange.location)];
  if (newlineRange.location != NSNotFound) {
    lineStart = newlineRange.location + 1;
  }
  
  // grab the whitespace
  NSString *whitespace = @"";
  NSRange whitespaceRange = [self.textStorage.string rangeOfString:@"^[\t ]+" options:NSRegularExpressionSearch range:NSMakeRange(lineStart, self.textStorage.length - lineStart)];
  if (whitespaceRange.location != NSNotFound) {
    whitespace = [self.textStorage.string substringWithRange:whitespaceRange];
  }
  
  // insert newline, then whitespace
  [super insertNewline:sender];
  if (whitespace) {
    [self insertText:whitespace];
  }
}

- (void)insertTab:(id)sender
{
  // insert two spaces instead of a tab
  [self insertText:@"  "];
}

- (void)deleteBackward:(id)sender
{
  // when deleting spaces, delete twice each time the delete key is pressed
  if (self.selectedRange.length == 0 && self.selectedRange.location > 1) {
    if ([[self.textStorage.string substringWithRange:NSMakeRange(self.selectedRange.location - 2, 2)] isEqualToString:@"  "]) {
      [super deleteBackward:sender];
    }
  }
  
  [super deleteBackward:sender];
}

- (void)deleteForward:(id)sender
{
  // when deleting spaces, delete twice each time the delete key is pressed
  if (self.selectedRange.length == 0 && self.selectedRange.location < (self.textStorage.length - 1)) {
    if ([[self.textStorage.string substringWithRange:NSMakeRange(self.selectedRange.location, 2)] isEqualToString:@"  "]) {
      [super deleteForward:sender];
    }
  }
  
  [super deleteForward:sender];
}

- (IBAction)jumpToLine:(id)sender
{
  if (!self.goToLinePanel) {
    [NSBundle loadNibNamed:@"JumpToLinePanel" owner:self];
  }
  
  [self.goToLinePanel makeKeyAndOrderFront:sender];
  [self.goToLineSearchField becomeFirstResponder];
}

- (IBAction)goToLinePanelButtonClicked:(id)sender
{
  // figure out what line we are navigating to
  int targetLine = self.goToLineSearchField.intValue;
  if (!targetLine) {
    NSBeep();
    return;
  }
  
  // find the line
  int atLine = 1;
  NSUInteger characterLocation = 0;
  while (atLine < targetLine) {
    characterLocation = [self.textStorage.string rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:NSLiteralSearch range:NSMakeRange(characterLocation, (self.textStorage.length - characterLocation))].location;
    
    if (characterLocation == NSNotFound) {
      NSBeep();
      return;
    }
    
    atLine++;
    characterLocation++;
  }
  
  // jump to the line
  NSRange lineRange = [self.textStorage.string rangeOfLineAtOffset:characterLocation];
  [self scrollRangeToVisible:lineRange];
  [self setSelectedRange:lineRange];
  [self.goToLinePanel performClose:self];
}

- (IBAction)commentSelection:(id)sender
{
  NSRange commentRange = self.selectedRange;
  if (commentRange.length == 0) {
    commentRange = [self.textStorage.string rangeOfLineAtOffset:self.selectedRange.location];
  } else {
    if ([self.textStorage.string characterAtIndex:NSMaxRange(commentRange) - 1] == '\n') {
      commentRange.length--;
    }
  }
  
  DuxLanguage *language = [self.highlighter languageForRange:self.selectedRange ofTextStorage:self.textStorage];
  
  [language wrapCommentsAroundRange:commentRange ofTextView:self];
}

- (IBAction)shiftSelectionRight:(id)sender
{
  // figure out the range of the string we are shifting
  NSRange originalSelectedRange = self.selectedRange;
  NSRange shiftRange = originalSelectedRange;
  
  NSUInteger beginingOfLine = [self.textStorage.string beginingOfLineAtOffset:self.selectedRange.location];
  shiftRange = NSMakeRange(beginingOfLine, NSMaxRange(shiftRange) - beginingOfLine);
  
  NSUInteger endOfLine = [self.textStorage.string endOfLineAtOffset:NSMaxRange(self.selectedRange)];
  shiftRange = NSMakeRange(shiftRange.location, endOfLine - shiftRange.location);
  
  // increase indent level
  NSString *existingString = [self.textStorage.string substringWithRange:shiftRange];
  
  NSString *shiftedString= [NSString stringWithFormat:@"  %@", existingString];
  shiftedString = [shiftedString stringByReplacingOccurrencesOfString:@"(\n)" withString:@"$1  " options:NSRegularExpressionSearch range:NSMakeRange(0, shiftedString.length)];
  
  [self insertText:shiftedString replacementRange:shiftRange];
  
  if (originalSelectedRange.length == 0) {
    [self setSelectedRange:NSMakeRange(originalSelectedRange.location + (shiftedString.length - existingString.length), 0)];
  } else {
    [self setSelectedRange:NSMakeRange(shiftRange.location, shiftedString.length)];
  }
}

- (IBAction)shiftSelectionLeft:(id)sender
{
  // figure out the range of the string we are shifting
  NSRange originalSelectedRange = self.selectedRange;
  NSRange shiftRange = originalSelectedRange;
  
  NSUInteger beginingOfLine = [self.textStorage.string beginingOfLineAtOffset:self.selectedRange.location];
  shiftRange = NSMakeRange(beginingOfLine, NSMaxRange(shiftRange) - beginingOfLine);
  
  NSUInteger endOfLine = [self.textStorage.string endOfLineAtOffset:NSMaxRange(self.selectedRange)];
  shiftRange = NSMakeRange(shiftRange.location, endOfLine - shiftRange.location);
  
  // increase indent level
  NSString *existingString = [self.textStorage.string substringWithRange:shiftRange];
  
  NSString *shiftedString = [existingString stringByReplacingOccurrencesOfString:@"(\n|^)  " withString:@"$1" options:NSRegularExpressionSearch range:NSMakeRange(0, existingString.length)];
  
  [self insertText:shiftedString replacementRange:shiftRange];
  
  if (originalSelectedRange.length == 0) {
    [self setSelectedRange:NSMakeRange(originalSelectedRange.location - (existingString.length - shiftedString.length), 0)];
  } else {
    [self setSelectedRange:NSMakeRange(shiftRange.location, shiftedString.length)];
  }
}

- (NSArray *)completionsForPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index
{
  // figure out the partial word
  NSString *partialWord = [self.textStorage.string substringWithRange:charRange];
  
  // find every word in the current document
  NSArray *words = [self.textStorage.string componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
  
  // see which words start with 
  NSMutableSet *matchingWords = [NSMutableSet set];
  NSString *word;
  NSUInteger partialWordLength = partialWord.length;
  for (word in words) {
    if (partialWordLength >= word.length)
      continue;
    
    if ([[word substringWithRange:NSMakeRange(0, partialWordLength)] isEqualToString:partialWord]) {
      if (![matchingWords containsObject:word])
        [matchingWords addObject:word];
    }
  }
  
  if ([matchingWords count] == 0)
    return nil;
  
  return [matchingWords allObjects];
}

- (IBAction)showCompletions:(id)sender
{
  [self complete:sender];
}

- (IBAction)paste:(id)sender
{
  NSArray *copiedItems = [[NSPasteboard generalPasteboard] readObjectsForClasses:[NSArray arrayWithObject:[NSString class]] options:[NSDictionary dictionary]];
  if (copiedItems == nil || copiedItems.count == 0) {
    NSBeep();
    return;
  }
  
  [self insertText:[copiedItems objectAtIndex:0]];
}

@end
