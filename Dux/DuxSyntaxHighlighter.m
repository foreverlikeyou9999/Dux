//
//  DuxSyntaxHighlighter.m
//  Dux
//
//  Created by Abhi Beckert on 2011-10-22.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import "DuxSyntaxHighlighter.h"
#import "DuxPreferences.h"

@implementation DuxSyntaxHighlighter

- (id)init
{
  if (!(self = [super init]))
    return nil;
  
  baseLanguage = [DuxPlainTextLanguage sharedInstance];
  
  NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
  [notifCenter addObserver:self selector:@selector(editorFontDidChange:) name:DuxPreferencesEditorFontDidChangeNotification object:nil];
	[notifCenter addObserver:self selector:@selector(editorTabWidthDidChange:) name:DuxPreferencesTabWidthDidChangeNotification object:nil];
  
  return self;
}

- (void)dealloc
{
  NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
  [notifCenter removeObserver:self];
}

- (NSDictionary *)baseAttributes
{
  if (baseAttributes)
    return baseAttributes;
  
  baseAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
    [DuxPreferences editorFont], NSFontAttributeName,
  nil];

  return baseAttributes;
}

- (DuxLanguage *)baseLanguage
{
  return baseLanguage;
}

- (void)setBaseLanguage:(DuxLanguage *)newBaseLanguage forTextStorage:(NSTextStorage *)textStorage
{
  baseLanguage = newBaseLanguage;
  
  [textStorage setAttributes:[self baseAttributes] range:NSMakeRange(0, textStorage.length)];
  [self updateHighlightingForStorage:textStorage];
}

- (void)updateHighlightingForStorage:(NSTextStorage *)textStorage
{
  // we can't do anything with a zero length string, and we'll fail with an exception if we try
  if (textStorage.length == 0)
    return;
  
  static BOOL isHighlighting = NO;
  if (isHighlighting)
    return;
  
  isHighlighting = YES;
  [textStorage beginEditing];
  
  // figure out where we are going to start from and what attributes are already there
  NSRange effectiveRange; // warning: we tell NSAttributedString not to search the entire string to calculate this, so only the location property is valid
  NSInteger highlightIndex = 0;
  NSDictionary *startingAtts = [textStorage attributesAtIndex:highlightIndex longestEffectiveRange:&effectiveRange inRange:NSMakeRange(0, 1)];
  
  // grab the element stack
  NSArray *elementStack = [startingAtts valueForKey:@"DuxLanguageElementStack"];
  
  // if there's no language, apply the base language
  if (!elementStack) {
    elementStack = [NSArray arrayWithObject:[self.baseLanguage baseElement]];
    
    NSMutableDictionary *atts = [self.baseAttributes mutableCopy];
    [atts setValue:elementStack forKey:@"DuxLanguageElementStack"];
    
    NSRange attsRange = NSMakeRange(effectiveRange.location, textStorage.length - effectiveRange.location);
    [textStorage addAttributes:[atts copy] range:attsRange];
    
    startingAtts = atts;
  }
  
  // if highlightIndex is 0 and the starting language is not the base element, then force the base element
  if (highlightIndex == 0 && [elementStack count] > 1) {
    elementStack = [NSArray arrayWithObject:[self.baseLanguage baseElement]];
  }
  
  // begin highlighting
  DuxLanguage *thisLanguage = nil;
  NSUInteger endlessLoopDetectionRecentHighlightIndexes[10] = { [0 ... 9] = NSNotFound };
  while (highlightIndex < textStorage.length) {
    // prepare this element
    DuxLanguageElement *thisElement = [elementStack lastObject];
    if (thisElement.language != thisLanguage) {
      thisLanguage = thisElement.language;
      [thisLanguage prepareToParseTextStorage:textStorage];
    }
    
    // how long is this element, and what is the next one?
    DuxLanguageElement *nextElement = nil;
    NSUInteger elementLength = [thisElement lengthInString:textStorage startingAt:highlightIndex nextElement:&nextElement];
    
    // verify response
    if (elementLength == 0) {
      for (int i = 1; i < 10; i++)
        endlessLoopDetectionRecentHighlightIndexes[i - 1] = endlessLoopDetectionRecentHighlightIndexes[i];
      endlessLoopDetectionRecentHighlightIndexes[9] = highlightIndex;
      
      BOOL foundDifference = NO;
      for (int i = 0; i < 10; i++) {
        if (endlessLoopDetectionRecentHighlightIndexes[i] != highlightIndex) {
          foundDifference = YES;
          break;
        }
      }
      
      if (!foundDifference) {
        NSLog(@"Detected endless loop in syntax highlighter at offset %lu. forcing highlighter to move 1 character forwards.", (unsigned long)elementLength);
        elementLength = 1;
        break;
      }
    }
    if (highlightIndex + elementLength > textStorage.length) {
      NSLog(@"elementLength %lu is too long, changing it to %lu instead", (unsigned long)elementLength, (unsigned long)(textStorage.length - highlightIndex));
      elementLength = textStorage.length - highlightIndex;
    }
    
    // figure out what we need to do
    NSRange attsRange = NSMakeRange(highlightIndex, elementLength);
    NSRange oldAttsRange;
    NSArray *oldElementStack = [textStorage attribute:@"DuxLanguageElementStack" atIndex:highlightIndex longestEffectiveRange:&oldAttsRange inRange:NSMakeRange(0, textStorage.length)];
    
    // trim oldAttsRange down so it's no larger than attsRange, for example if we are doing <tag><other tag> then oldAttsRange will be larger
    oldAttsRange = NSIntersectionRange(oldAttsRange, attsRange);
    
    // apply new value if there's anything to apply
    if (attsRange.length != 0 && !(attsRange.location >= oldAttsRange.location && NSMaxRange(attsRange) <= NSMaxRange(oldAttsRange) && [elementStack isEqual:oldElementStack])) {
      [textStorage addAttribute:NSForegroundColorAttributeName value:[thisElement color] range:attsRange];
      [textStorage addAttribute:@"DuxLanguageElementStack" value:elementStack range:attsRange];
    }
    
    // prepare for next element
    highlightIndex = NSMaxRange(attsRange);
    if (nextElement) {
      elementStack = [elementStack arrayByAddingObject:nextElement];
    } else {
      elementStack = [elementStack subarrayWithRange:NSMakeRange(0, elementStack.count - 1)];
    }
  }
  
  [textStorage endEditing];
  isHighlighting = NO;
  
  [[NSNotificationCenter defaultCenter] postNotificationName:@"DuxSyntaxHighlighterDidFinishHighlighting" object:self];
}

- (void)textStorageDidProcessEditing:(NSNotification *)notification
{
  NSTextStorage *storage = notification.object;
  [self updateHighlightingForStorage:storage];
}

- (DuxLanguage *)languageForRange:(NSRange)range ofTextStorage:(NSTextStorage *)textStorage
{
  NSArray *elementStack = [textStorage attribute:@"DuxLanguageElementStack" atIndex:MIN(range.location, textStorage.length - 1) effectiveRange:NULL];
  
  return [(DuxLanguageElement *)[elementStack lastObject] language];
}

- (DuxLanguageElement *)elementForRange:(NSRange)range ofTextStorage:(NSTextStorage *)textStorage
{
  NSArray *elementStack = [textStorage attribute:@"DuxLanguageElementStack" atIndex:MIN(range.location, textStorage.length - 1) effectiveRange:NULL];
  
  return (DuxLanguageElement *)[elementStack lastObject];
}

- (DuxLanguageElement *)elementAtIndex:(NSUInteger)location longestEffectiveRange:(NSRangePointer)range inTextStorage:(NSTextStorage *)textStorage
{
  NSArray *elementStack = [textStorage attribute:@"DuxLanguageElementStack" atIndex:location longestEffectiveRange:range inRange:NSMakeRange(0, textStorage.length)];
  
  return [elementStack lastObject];
}

- (BOOL)rangeIsComment:(NSRange)range inTextStorage:(NSTextStorage *)textStorage commentRange:(NSRangePointer)commentRange
{
  if (textStorage.length == 0)
    return NO;
  
  BOOL isFirst = YES;
  NSRange newCommentRange = NSMakeRange(0, 0);
  NSUInteger offset = range.location;
  while (offset <= NSMaxRange(range) && offset < textStorage.length) {
    NSRange effectiveRange;
    NSArray *languageStack = [textStorage attribute:@"DuxLanguageElementStack" atIndex:offset longestEffectiveRange:&effectiveRange inRange:NSMakeRange(0, textStorage.length)];
    
    // no language? not a comment then
    if (!languageStack || languageStack.count == 0)
      return NO;
    
    // is this item on the stack a comment?
    if (![[languageStack lastObject] isComment]) {
      // make sure the entire element isn't a newline
      if (effectiveRange.length == 1 && [textStorage.string characterAtIndex:effectiveRange.location] == '\n') {
        offset = NSMaxRange(effectiveRange);
        continue;
      }
      if (isFirst) {
        return NO;
      } else {
        break;
      }
    }
    
    if (isFirst) {
      newCommentRange.location = effectiveRange.location;
    }
    newCommentRange.length = NSMaxRange(effectiveRange) - newCommentRange.location;
    offset = NSMaxRange(effectiveRange);
    isFirst = NO;
  }
  
  commentRange->location = newCommentRange.location;
  commentRange->length = newCommentRange.length;
  return YES;
}

- (void)editorFontDidChange:(NSNotification *)notif
{
  baseAttributes = nil; // this will ensure base attributes are re-created next time they're used
}

- (void)editorTabWidthDidChange:(NSNotification *)notif
{
  baseAttributes = nil; // this will ensure base attributes are re-created next time they're used
}

@end
