//
//  MyTextDocument.m
//  Dux
//
//  Created by Abhi Beckert on 2011-08-23.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import "MyTextDocument.h"

@implementation MyTextDocument

@synthesize textStorage;
@synthesize textView;
@synthesize syntaxtHighlighter;

+ (void)initialize
{
  [super initialize];
}

- (id)init
{
    self = [super init];
    if (self) {
      textContentToLoad = @"";
    }
    return self;
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString *)windowNibName
{
  // Override returning the nib file name of the document
  // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
  return @"MyTextDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
  [super windowControllerDidLoadNib:aController];
  
  // load text into view
  self.textStorage = self.textView.textStorage;
  self.syntaxtHighlighter = [[DuxSyntaxHighlighter alloc] init];
  self.textStorage.delegate = self.syntaxtHighlighter;
  self.textView.highlighter = self.syntaxtHighlighter;
  [self loadTextContentIntoStorage];
  
  
  
  // make sure scroll bars are good
  [self.textView.layoutManager ensureLayoutForTextContainer:self.textView.textContainer];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentWindowDidBecomeKey:) name:NSWindowDidBecomeKeyNotification object:self.textView.window];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
  return [self.textStorage.string dataUsingEncoding:NSUTF8StringEncoding];
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
  textContentToLoad = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  if (!textContentToLoad) textContentToLoad = [[NSString alloc] initWithData:data encoding:NSUnicodeStringEncoding];
  if (!textContentToLoad) textContentToLoad = [[NSString alloc] initWithData:data encoding:NSWindowsCP1252StringEncoding];    /* WinLatin1 */
  if (!textContentToLoad) textContentToLoad = [[NSString alloc] initWithData:data encoding:NSMacOSRomanStringEncoding];
  if (!textContentToLoad) textContentToLoad = [[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding];
  if (!textContentToLoad) textContentToLoad = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
  if (!textContentToLoad) {
    *outError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadUnknownError userInfo:nil];
    return NO;
  }
  
  [self loadTextContentIntoStorage];
  
  return YES;
}

- (NSString *)fileNameExtensionForType:(NSString *)typeName saveOperation:(NSSaveOperationType)saveOperation
{
  if (!self.fileURL)
    return @"txt";
  
  return self.fileURL.pathExtension;
}

- (void)loadTextContentIntoStorage
{
  if (!self.textStorage || !textContentToLoad)
    return;
  
  // load contents into storage
  [self.textStorage beginEditing];
  [self.textStorage replaceCharactersInRange:NSMakeRange(0, self.textStorage.length) withString:textContentToLoad];
  NSDictionary *attributes = [NSDictionary dictionaryWithObject:[NSFont fontWithName:@"Menlo" size:13] forKey:NSFontAttributeName];
  [self.textStorage setAttributes:attributes range:NSMakeRange(0, self.textStorage.length)];
  [self.textStorage endEditing];
  
  // free up memory
  textContentToLoad = nil;
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (void)documentWindowDidBecomeKey:(NSNotification *)notification
{
  [self updateSyntaxMenuStates];
}

- (void)updateSyntaxMenuStates
{
  NSString *languageClassName = NSStringFromClass([self.syntaxtHighlighter.baseLanguage class]);
  
  NSArray *editorMenuIems = [[[[[NSApplication sharedApplication] mainMenu] itemWithTitle:@"Editor"] submenu] itemArray];
  for (NSMenuItem *menuItem in editorMenuIems) {
    if ([menuItem class] != [DuxLanguageMenuItem class])
      continue;
    
    [menuItem setState:[[menuItem valueForKey:@"duxLanguageClassName"] isEqual:languageClassName] ? NSOnState : NSOffState];
  }
}

- (IBAction)setDuxLanguage:(id)sender
{
  Class languageClass = NSClassFromString([sender valueForKey:@"duxLanguageClassName"]);
  
  [self.syntaxtHighlighter setBaseLanguage:[languageClass sharedInstance] forTextStorage:self.textStorage];
  
  [self updateSyntaxMenuStates];
}

@end
