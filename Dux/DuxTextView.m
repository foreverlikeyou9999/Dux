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
#import "MyTextDocument.h"

@implementation DuxTextView

@synthesize highlighter;
@synthesize goToLinePanel;
@synthesize goToLineSearchField;
@synthesize textDocument;

- (id)initWithCoder:(NSCoder *)aDecoder
{
  if (!(self = [super initWithCoder:aDecoder]))
    return nil;
  
  self.delegate = self;
  
  return self;
}

- (id)initWithFrame:(NSRect)frameRect textContainer:(NSTextContainer *)container
{
  if (!(self = [super initWithFrame:frameRect textContainer:container]))
    return nil;
  
  self.delegate = self;
  
  return self;
}

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
  
  // are we about to insert a unix newline immediately after a mac newline? This will create a windows newline, which
  // do nothing as far as the user is concerned, and we need to insert *two* unix newlines
  if (self.textDocument.activeNewlineStyle == DuxNewlineUnix) {
    if (self.selectedRange.location > 0 && [self.string characterAtIndex:self.selectedRange.location - 1] == '\r') {
      [self insertText:[NSString stringForNewlineStyle:self.textDocument.activeNewlineStyle]];
    }
  }
  
  // insert newline
  [self insertText:[NSString stringForNewlineStyle:self.textDocument.activeNewlineStyle]];
  
  // insert whitespace
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
  NSInteger targetLine = self.goToLineSearchField.integerValue;
  if (!targetLine) {
    NSBeep();
    return;
  }
  
  // find the line
  int atLine = 1;
  NSString *string = self.textStorage.string;
  NSUInteger stringLength = string.length;
  NSUInteger characterLocation = 0;
  while (atLine < targetLine) {
    characterLocation = [string rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:NSLiteralSearch range:NSMakeRange(characterLocation, (stringLength - characterLocation))].location;
    
    if (characterLocation == NSNotFound) {
      NSBeep();
      return;
    }
    
    // if we are at a \r character and the next character is a \n, skip the next character
    if (string.length >= characterLocation &&
        [string characterAtIndex:characterLocation] == '\r' &&
        [string characterAtIndex:characterLocation + 1] == '\n') {
      characterLocation++;
    }
    
    atLine++;
    characterLocation++;
  }
  
  // jump to the line
  NSRange lineRange = [string rangeOfLineAtOffset:characterLocation];
  [self scrollRangeToVisible:lineRange];
  [self setSelectedRange:lineRange];
  [self.goToLinePanel performClose:self];
}

- (IBAction)commentSelection:(id)sender
{
  // if there's no selection, grab the entire line
  NSRange commentRange = self.selectedRange;
  if (commentRange.length == 0) {
    commentRange = [self.textStorage.string rangeOfLineAtOffset:self.selectedRange.location];
  }
  
  // if the last character is a newline, select one less character (this gives nicer results in most situations)
  if ([self.textStorage.string characterAtIndex:NSMaxRange(commentRange) - 1] == '\n') {
     commentRange.length--;
  }
  
  // is the *entire* selected range commented? If so, uncomment instead
  NSRange uncommentRange;
  if ([self.highlighter rangeIsComment:commentRange inTextStorage:self.textStorage commentRange:&uncommentRange]) {
    
    [self uncomment:uncommentRange];
    return;
  }
  
  // find the language, and ask it to remove commenting
  DuxLanguage *language = [self.highlighter languageForRange:self.selectedRange ofTextStorage:self.textStorage];
  [language wrapCommentsAroundRange:commentRange ofTextView:self];
}

- (IBAction)uncomment:(NSRange)commentRange
{
  DuxLanguage *language = [self.highlighter languageForRange:self.selectedRange ofTextStorage:self.textStorage];
  [language removeCommentsAroundRange:commentRange ofTextView:self];
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
  
  NSString *pasteString = [copiedItems objectAtIndex:0];
  pasteString = [pasteString stringByReplacingNewlinesWithNewline:self.textDocument.activeNewlineStyle];
  
  [self insertText:pasteString];
}

- (BOOL)smartInsertDeleteEnabled
{
  return NO;
}

- (BOOL)isAutomaticQuoteSubstitutionEnabled
{
  return NO;
}

- (BOOL)isAutomaticLinkDetectionEnabled
{
  return NO;
}

- (BOOL)isAutomaticDataDetectionEnabled
{
  return NO;
}

- (BOOL)isAutomaticDashSubstitutionEnabled
{
  return NO;
}

- (BOOL)isAutomaticTextReplacementEnabled
{
  return NO;
}

- (BOOL)isAutomaticSpellingCorrectionEnabled
{
  return NO;
}

- (void)keyDown:(NSEvent *)theEvent
{
  switch ([[theEvent charactersIgnoringModifiers] characterAtIndex:0]) {
    case NSLeftArrowFunctionKey:
      if (!([theEvent modifierFlags] & NSControlKeyMask))
        break;
      
      if ([theEvent modifierFlags] & NSShiftKeyMask) {
        [self moveSubwordBackwardAndModifySelection:self];
      } else {
        [self moveSubwordBackward:self];
      }
      return;
    case NSRightArrowFunctionKey:;
      if (!([theEvent modifierFlags] & NSControlKeyMask))
        break;
      
      if ([theEvent modifierFlags] & NSShiftKeyMask) {
        [self moveSubwordForwardAndModifySelection:self];
      } else {
        [self moveSubwordForward:self];
      }
      return;
    case NSDeleteCharacter: // "delete" on mac keyboards, but "backspace" on others
      if (!([theEvent modifierFlags] & NSControlKeyMask))
        break;
      
      [self deleteSubwordBackward:self];
      return;
    case NSDeleteFunctionKey: // "delete forward" on mac keyboards, but "delete" on others
      if (!([theEvent modifierFlags] & NSControlKeyMask))
        break;
      
      [self deleteSubwordForward:self];
      return;
  }
  
  [super keyDown:theEvent];
}

- (NSUInteger)findBeginingOfSubwordStartingAt:(NSUInteger)offset
{
  // find one of three possibilities:
  //  - the begining of a single word, all uppercase, that is at the end of the search range (parenthesis set 2)
  //  - a point where a non-lowercase character is followed by a lowercase character (parenthesis set 4)
  NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"([^a-z0-9]([A-Z]+[^a-z0-9]*$))|(^|[^a-z0-9])([a-z0-9])" options:0 error:NULL];
  
  // we only work with one line at a time, to make the regex faster
  NSRange lineRange = [self.textStorage.string rangeOfLineAtOffset:offset];
  NSString *searchString = [self.textStorage.string substringWithRange:lineRange];
  
  // prepare search range
  NSUInteger insertionPoint = offset - lineRange.location;
  NSRange searchRange = NSMakeRange(0, insertionPoint);
  
  // we may need to try the search again on the previous line
  NSUInteger newInsertionPoint = 0;
  while (YES) {
    // don't bother searching from the begining of the line... try again on the previous line (unless we are at the begining of the file!)
    if (insertionPoint == 0 && lineRange.location != 0) {
      lineRange = [self.textStorage.string rangeOfLineAtOffset:lineRange.location - 1];
      searchString = [self.textStorage.string substringWithRange:lineRange];
      insertionPoint = lineRange.length - 1;
      searchRange = NSMakeRange(0, lineRange.length);
      continue;
    }
    
    // find the last match
    NSTextCheckingResult *match = [[expression matchesInString:searchString options:0 range:searchRange] lastObject];
    
    // which match do we want?
    newInsertionPoint = 0;
    if (match && [match rangeAtIndex:2].location != NSNotFound) {
      newInsertionPoint = [match rangeAtIndex:2].location;
    } else if (match && [match rangeAtIndex:4].location != NSNotFound) {
      newInsertionPoint = [match rangeAtIndex:4].location;
    } else { // no match found at all, try again on the previous line
      if (lineRange.location != 0) { // make sure we aren't at the begining of the file
        lineRange = [self.textStorage.string rangeOfLineAtOffset:lineRange.location - 1];
        searchString = [self.textStorage.string substringWithRange:lineRange];
        insertionPoint = lineRange.length - 1;
        searchRange = NSMakeRange(0, lineRange.length);
        continue;
      }
    }
    
    // if we are in between an uppercase letter and a lowercase letter, than we need to drop 1 from the index
    if ([[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[searchString characterAtIndex:newInsertionPoint - 1]]) {
      newInsertionPoint--;
    }
    
    break;
  }
    
  return newInsertionPoint + lineRange.location;
}

- (NSUInteger)findEndOfSubwordStartingAt:(NSUInteger)offset
{
  // find one of two possibilities:
  //  - the end of a single word, all uppercase, that is at the begining of the search range (parenthesis set 2)
  //  - a point where a lowercase character is followed by a non-lowercase character (parenthesis set 4)
  NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"((^[^a-z0-9]*[A-Z]+)[^A-Z])|([a-z0-9])($|[^a-z0-9])" options:0 error:NULL];
  
  // we only work with one line at a time, to make the regex faster
  NSRange lineRange = [self.textStorage.string rangeOfLineAtOffset:offset];
  NSString *searchString = [self.textStorage.string substringWithRange:lineRange];
  
  // prepare search range
  NSUInteger insertionPoint = offset - lineRange.location;
  NSRange searchRange = NSMakeRange(MIN(insertionPoint + 1, searchString.length), searchString.length == 0 ? 0 : (searchString.length - (insertionPoint + 1)));
  
  // we may need to try the search again on the previous line
  NSUInteger newInsertionPoint = searchString.length;
  while (YES) {
    // don't bother searching from the begining of the line... try again on the next line (unless we are at the end of the file!)
    if (insertionPoint >= (searchString.length - 1) && (NSMaxRange(lineRange) < self.textStorage.string.length)) {
      lineRange = [self.textStorage.string rangeOfLineAtOffset:NSMaxRange(lineRange) + 1];
      searchString = [self.textStorage.string substringWithRange:lineRange];
      insertionPoint = 0;
      searchRange = NSMakeRange(0, searchString.length);
      continue;
    }
    
    // find the last match
    NSTextCheckingResult *match = [expression firstMatchInString:searchString options:0 range:searchRange];
    
    // which match do we want?
    newInsertionPoint = searchString.length;
    if (match && [match rangeAtIndex:2].location != NSNotFound) {
      newInsertionPoint = NSMaxRange([match rangeAtIndex:2]);
    } else if (match && [match rangeAtIndex:4].location != NSNotFound) {
      newInsertionPoint = [match rangeAtIndex:4].location;
    } else { // no match found at all, try again on the previous line
      if (NSMaxRange(lineRange) < self.textStorage.string.length) { // make sure we aren't at the begining of the file
        lineRange = [self.textStorage.string rangeOfLineAtOffset:NSMaxRange(lineRange) + 1];
        searchString = [self.textStorage.string substringWithRange:lineRange];
        insertionPoint = 0;
        searchRange = NSMakeRange(0, searchString.length);
        continue;
      }
    }
    
    // if we are in between an uppercase letter and a lowercase letter, than we need to drop 1 from the index
    if (searchString.length > 0) {
      BOOL prevCharIsUppercase = [[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[searchString characterAtIndex:newInsertionPoint - 1]];
      BOOL nextCharIsLowercase = [[NSCharacterSet lowercaseLetterCharacterSet] characterIsMember:[searchString characterAtIndex:MIN(newInsertionPoint, searchString.length - 1)]];
      if (prevCharIsUppercase && nextCharIsLowercase) {
        newInsertionPoint--;
      }
    }
    
    break;
  }
  
  return newInsertionPoint + lineRange.location;
}

- (void)moveSubwordBackward:(id)sender
{
  NSMutableArray *newSelectedRanges = [NSMutableArray array];
  
  for (NSValue *rangeValue in self.selectedRanges) {
    NSUInteger newInsertionPoint = [self findBeginingOfSubwordStartingAt:rangeValue.rangeValue.location];
    
    NSRange newRange = NSMakeRange(newInsertionPoint, 0);
    
    [newSelectedRanges addObject:[NSValue valueWithRange:newRange]];
  }
  
  [self setSelectedRanges:[newSelectedRanges copy]];
}

- (void)moveSubwordBackwardAndModifySelection:(id)sender
{
  NSMutableArray *newSelectedRanges = [NSMutableArray array];
  
  for (NSValue *rangeValue in self.selectedRanges) {
    NSUInteger newInsertionPoint = [self findBeginingOfSubwordStartingAt:rangeValue.rangeValue.location];
    
    NSRange newRange = NSMakeRange(newInsertionPoint, NSMaxRange(rangeValue.rangeValue) - newInsertionPoint);
    
    [newSelectedRanges addObject:[NSValue valueWithRange:newRange]];
  }
  
  [self setSelectedRanges:[newSelectedRanges copy]];
}

- (void)moveSubwordForward:(id)sender
{
  NSMutableArray *newSelectedRanges = [NSMutableArray array];
  
  for (NSValue *rangeValue in self.selectedRanges) {
    NSUInteger newInsertionPoint = [self findEndOfSubwordStartingAt:NSMaxRange(rangeValue.rangeValue)];
    
    NSRange newRange = NSMakeRange(newInsertionPoint, 0);
    
    [newSelectedRanges addObject:[NSValue valueWithRange:newRange]];
  }
  
  [self setSelectedRanges:[newSelectedRanges copy]];
}

- (void)moveSubwordForwardAndModifySelection:(id)sender
{
  NSMutableArray *newSelectedRanges = [NSMutableArray array];
  
  for (NSValue *rangeValue in self.selectedRanges) {
    NSUInteger newInsertionPoint = [self findEndOfSubwordStartingAt:NSMaxRange(rangeValue.rangeValue)];
    
    NSRange newRange = NSMakeRange(rangeValue.rangeValue.location, newInsertionPoint - rangeValue.rangeValue.location);
      
    [newSelectedRanges addObject:[NSValue valueWithRange:newRange]];
  }
  
  [self setSelectedRanges:[newSelectedRanges copy]];
}

- (void)deleteSubwordBackward:(id)sender
{
  if (self.selectedRanges.count > 1 || self.selectedRange.length > 0)
    return [self deleteBackward:sender];
  
  NSUInteger deleteOffset = [self findBeginingOfSubwordStartingAt:self.selectedRange.location];
  
  NSRange newRange = NSMakeRange(deleteOffset, self.selectedRange.location - deleteOffset);
  
  [self insertText:@"" replacementRange:newRange];
}

- (void)deleteSubwordForward:(id)sender
{
  if (self.selectedRanges.count > 1 || self.selectedRange.length > 0)
    return [self deleteForward:sender];
  
  NSUInteger deleteOffset = [self findEndOfSubwordStartingAt:self.selectedRange.location];
  
  NSRange newRange = NSMakeRange(self.selectedRange.location, deleteOffset - self.selectedRange.location);
  
  [self insertText:@"" replacementRange:newRange];
}

@end
