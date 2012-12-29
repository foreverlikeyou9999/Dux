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
#import "DuxPreferences.h"
#import "DuxProjectWindowController.h"

@implementation MyTextDocument

@synthesize editorWindow;
@synthesize textStorage;
@synthesize textView;
@synthesize syntaxtHighlighter;
@synthesize activeNewlineStyle;
@synthesize stringEncoding;

+ (void)initialize
{
  [super initialize];
}

- (id)init
{
    self = [super init];
    if (self) {
      stringEncoding = NSUTF8StringEncoding;
      textContentStorage = [[NSTextStorage alloc] initWithString:@"" attributes:@{NSFontAttributeName:[DuxPreferences editorFont]}];
      self.syntaxtHighlighter = [[DuxSyntaxHighlighter alloc] init];
      textContentStorage.delegate = self.syntaxtHighlighter;
      
      self.activeNewlineStyle = DuxNewlineUnix;
    }
    return self;
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)makeWindowControllers
{
  // find/create window controller
  DuxProjectWindowController *controller = [NSApp mainWindow].windowController;
  if (![controller isKindOfClass:[DuxProjectWindowController class]])
    controller = nil;
  
  if (!controller && [DuxProjectWindowController projectWindowControllers].count > 0) {
    controller = [[DuxProjectWindowController projectWindowControllers] objectAtIndex:0];
  }
  
  if (!controller) {
    controller = [DuxProjectWindowController newProjectWindowControllerWithRoot:[self.fileURL URLByDeletingLastPathComponent]];
  }
  
  // link ourself up as the window controller's current document (this will call [self loadIntoProjectWindow:] once the nib is ready)
  if (controller.document) {
    [controller.document removeWindowController:controller.document];
  }
  [self addWindowController:controller];
}

- (void)loadIntoProjectWindowController:(DuxProjectWindowController *)controller
{
  self.editorWindow = controller.editorWindow;
  self.textView = controller.textView;
  
  if (self.fileURL) {
    NSString *relativePath = self.fileURL.path;
    if (relativePath.length > controller.rootUrl.path.length && [controller.rootUrl.path isEqualToString:[relativePath substringToIndex:controller.rootUrl.path.length]]) {
      relativePath = [relativePath substringFromIndex:controller.rootUrl.path.length + 1];
    } else {
      relativePath = [relativePath stringByAbbreviatingWithTildeInPath];
    }
    controller.documentPathLabel.stringValue = relativePath;
  } else {
    controller.documentPathLabel.stringValue = [NSString stringWithFormat:@"(%@)", self.displayName];
  }
  
  // load ourselves into text view
  self.textView.textDocument = self;
  
  // load text into view
  self.textView.highlighter = self.syntaxtHighlighter;
  [self loadTextContentIntoStorage];
  
  
  // make sure scroll bars are good
  [self.textView.layoutManager ensureLayoutForTextContainer:self.textView.textContainer];
  
  // make text view the first responder
  [self.textView.window makeFirstResponder:self.textView];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentWindowDidBecomeKey:) name:NSWindowDidBecomeKeyNotification object:self.textView.window];
  
  // show encoding alert
  if (self.stringEncoding != NSUTF8StringEncoding) {
    dispatch_async(dispatch_get_main_queue(), ^{
      NSAlert *encodingWarningAlert = [[NSAlert alloc] init];
      encodingWarningAlert.alertStyle = NSCriticalAlertStyle;
      encodingWarningAlert.messageText = @"File could not be read as UTF-8";
      encodingWarningAlert.informativeText = @"Dux has guessed the encoding, but could be wrong. Please use the Editor -> Text Encoding menu to choose the correct encoding for this file.";
      [encodingWarningAlert addButtonWithTitle:@"Dismiss"];
      
      [encodingWarningAlert beginSheetModalForWindow:self.textView.window modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
    });
  }
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
  [self.textView breakUndoCoalescing];
  
  return [textContentStorage.string dataUsingEncoding:self.stringEncoding];
}

- (BOOL)writeToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
  if (self.fileContentsWatcher) {
    [self.fileContentsWatcher ignoreNewFileContents:[self dataOfType:typeName error:NULL]];
  }
  
  return [super writeToURL:absoluteURL ofType:typeName error:outError];
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
  NSStringEncoding encoding;
  NSString *textContentToLoad = [NSString stringWithUnknownData:data usedEncoding:&encoding];
  if (!textContentToLoad) {
    *outError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadUnknownError userInfo:nil];
    return NO;
  }
  self.stringEncoding = encoding;
  
  textContentStorage = [[NSTextStorage alloc] initWithString:textContentToLoad attributes:@{NSFontAttributeName:[DuxPreferences editorFont]}];
  
  
  // figure out what language to use
  for (Class language in [DuxLanguage registeredLanguages]) {
    if (![language isDefaultLanguageForURL:self.fileURL textContents:textContentToLoad])
      continue;
    
    [self.syntaxtHighlighter setBaseLanguage:[language sharedInstance] forTextStorage:textContentStorage];
    break;
  }
  
  // set activeNewlineStyle to the first newline in the document
  self.activeNewlineStyle = [textContentToLoad newlineStyleForFirstNewline];
  
  [self loadTextContentIntoStorage];
  
  return YES;
}

- (void)setFileURL:(NSURL *)url
{
  if (self.fileContentsWatcher) {
    self.fileContentsWatcher.url = url;
  } else {
    self.fileContentsWatcher = [[DuxFileContentsWatcher alloc] initWithURL:url delegate:self];
  }
  
  [super setFileURL:url];
}

- (NSString *)fileNameExtensionForType:(NSString *)typeName saveOperation:(NSSaveOperationType)saveOperation
{
  if (!self.fileURL)
    return @"txt";
  
  return self.fileURL.pathExtension;
}

- (void)loadTextContentIntoStorage
{
  // load contents into storage
  [self.textView setSelectedRange:NSMakeRange(0, 0)];
  [self.textView.textContainer.layoutManager replaceTextStorage:textContentStorage];
}

+ (BOOL)autosavesInPlace
{
  return YES;
}

- (void)documentWindowDidBecomeKey:(NSNotification *)notification
{
  // sometimes when this is called, the window hasn't *really* become key yet, and since we are only updating menu states it doesn't matter if it happens after a short delay
  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC);
  dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    [self updateSyntaxMenuStates];
    [self updateNewlineStyleMenuStates];
    [self updateLineEndingsInUseMenuItem];
    [self updateEncodingMenuItems];
  });
}

- (void)updateSyntaxMenuStates
{
  if ([[NSApp keyWindow].windowController document] != self)
    return;
  
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
  
  [self.syntaxtHighlighter setBaseLanguage:[languageClass sharedInstance] forTextStorage:textContentStorage];
  
  [self updateSyntaxMenuStates];
}

- (IBAction)setActiveNewlineStyleFromMenuItem:(NSMenuItem *)sender
{
  if ([[NSApp keyWindow].windowController document] != self)
    return;
  
  self.activeNewlineStyle = [sender tag];
  [self updateNewlineStyleMenuStates];
}

- (IBAction)convertToNewlineStyleFromMenuItem:(NSMenuItem *)sender
{
  DuxNewlineOptions newlineStyle = [sender tag];
  
  NSString *oldString = self.textView.string;
  NSString *newString = [oldString stringByReplacingNewlinesWithNewline:newlineStyle];
  
  self.textView.string = newString;
  
  self.activeNewlineStyle = newlineStyle;
  [self updateNewlineStyleMenuStates];
  [self updateLineEndingsInUseMenuItem];
}

- (IBAction)setActiveEncoding:(NSMenuItem *)sender
{
  NSStringEncoding newEncoding = sender.tag;
  if (newEncoding == self.stringEncoding) {
    NSBeep();
    return;
  }
  
  NSAlert *alert = [NSAlert alertWithMessageText:@"Do you want to convert the text to 'Arabic (Mac OS)'?" defaultButton:@"Convert" alternateButton:@"Reinterpret" otherButton:@"Cancel" informativeTextWithFormat:@"Choose 'Convert' if you want to change the contents of the file to be encoded as 'Western (Mac OS Roman)'.\n\nChoose 'Reinterpret' if you believe the file has been opened with an incorrect encoding and you want to reopen it as 'Western (Mac OS Roman)'."];
  [alert beginSheetModalForWindow:self.textView.window modalDelegate:self didEndSelector:@selector(setEncodingConvertOrReinterpretAlertDidEnd:returnCode:contextInfo:) contextInfo:(void *)newEncoding];
}

- (void)setEncodingConvertOrReinterpretAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
  NSStringEncoding newEncoding = (NSStringEncoding)contextInfo;
  
  if (returnCode == NSAlertOtherReturn) // cancel
    return;
  
  if ((int)returnCode == NSAlertDefaultReturn) { // convert
    BOOL success = [self convertContentToEncoding:newEncoding];
    if (!success) {
      dispatch_async(dispatch_get_main_queue(), ^{
        NSAlert *errorAlert = [NSAlert alertWithMessageText:@"Content could not be converted" defaultButton:@"Dismiss" alternateButton:nil otherButton:nil informativeTextWithFormat:@"This document could not be converted, because it cointains invalid characters for the specified encoding."];
        [errorAlert beginSheetModalForWindow:self.textView.window modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
      });
      return;
    }

  }
  
  if ((int)returnCode == NSAlertAlternateReturn) { // reinterpret
    BOOL success = [self reinterprateContentWithEncoding:newEncoding];
    if (!success) {
      dispatch_async(dispatch_get_main_queue(), ^{
        NSAlert *errorAlert = [NSAlert alertWithMessageText:@"Content could not be re-interpreted" defaultButton:@"Dismiss" alternateButton:nil otherButton:nil informativeTextWithFormat:@"This document could not be re-interpreted, because it cointains invalid characters for the specified encoding."];
        [errorAlert beginSheetModalForWindow:self.textView.window modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
      });
      return;
    }
  }
}

- (BOOL)convertContentToEncoding:(NSStringEncoding)newEncoding
{
  NSData *data = [textContentStorage.string dataUsingEncoding:newEncoding allowLossyConversion:NO];
  if (!data)
    return NO;
  
  NSString *newString = [[NSString alloc] initWithData:data encoding:newEncoding];
  if (!newString)
    return NO;

  self.stringEncoding = newEncoding;
  self.textView.string = newString;
  [self updateEncodingMenuItems];
  
  return YES;
}

- (BOOL)reinterprateContentWithEncoding:(NSStringEncoding)newEncoding
{ 
  // convert to NSData with current encoding
  NSData *data = [textContentStorage.string dataUsingEncoding:self.stringEncoding];
  
  // try to read with the new encoding
  NSString *newString = [[NSString alloc] initWithData:data encoding:newEncoding];
  if (!newString) {
    return NO;
  }
  
  // apply new string
  self.stringEncoding = newEncoding;
  self.textView.string = newString;
  [self updateEncodingMenuItems];
  
  return YES;
}

- (void)updateNewlineStyleMenuStates
{
  if ([[NSApp keyWindow].windowController document] != self)
    return;
  
  NSArray *menuItems = [[[NSApplication sharedApplication].mainMenu itemWithTitle:@"Editor"].submenu itemWithTitle:@"Line Endings"].submenu.itemArray;
  
  for (NSMenuItem *menuItem in menuItems) {
    if (menuItem.action != @selector(setActiveNewlineStyleFromMenuItem:))
      continue;
    
    menuItem.state = (menuItem.tag == self.activeNewlineStyle) ? NSOnState : NSOffState;
  }
}

- (void)updateLineEndingsInUseMenuItem
{
  if ([[NSApp keyWindow].windowController document] != self)
    return;
  
  NSMenuItem *menuItem = [[[[NSApplication sharedApplication].mainMenu itemWithTitle:@"Editor"].submenu itemWithTitle:@"Line Endings"].submenu itemAtIndex:0];
  
  menuItem.title = @"In use: Calculating...";
  NSString *stringForNewlineCalculation = [textContentStorage.string copy];
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
    DuxNewlineOptions newlineStyles = [stringForNewlineCalculation newlineStyles];
    
    dispatch_async(dispatch_get_main_queue(), ^{
      if ([[NSApp keyWindow].windowController document] != self)
        return;
    
      if (newlineStyles == 0) {
        menuItem.title = @"In use: N/A";
        return;
      }
      
      NSMutableArray *styleNames = [NSMutableArray array];
      if (newlineStyles & DuxNewlineUnix)
        [styleNames addObject:@"Mac OS X / UNIX"];
      if (newlineStyles & DuxNewlineWindows)
        [styleNames addObject:@"Windows"];
      if (newlineStyles & DuxNewlineClassicMac)
        [styleNames addObject:@"Mac OS Classic"];
      
      menuItem.title = [NSString stringWithFormat:@"In use: %@", [styleNames componentsJoinedByString:@", "]];
    });
  });
}

- (void)updateEncodingMenuItems
{
  if ([[NSApp keyWindow].windowController document] != self)
    return;
  
  NSArray *menuItems = [[[NSApplication sharedApplication].mainMenu itemWithTitle:@"Editor"].submenu itemWithTitle:@"Text Encoding"].submenu.itemArray;
  
  for (NSMenuItem *menuItem in menuItems) {
    if (menuItem.action != @selector(setActiveEncoding:))
      continue;
    
    menuItem.state = (menuItem.tag == self.stringEncoding) ? NSOnState : NSOffState;
  }
}

- (void)fileContentsDidChange:(DuxFileContentsWatcher *)watcher
{
  if ([self hasUnautosavedChanges]) {
    NSLog(@"recieved change event, but have unsaved changes");
    return;
  }
  
  // save old insertion point
  NSArray *selectedRanges = [self.textView selectedRanges];
  
  // revert file
  [self revertToContentsOfURL:self.fileURL ofType:self.fileType error:NULL];
  
  // read old insertion point
  [self.textView setSelectedRanges:selectedRanges];
}

- (void)canCloseDocumentWithDelegate:(id)delegate shouldCloseSelector:(SEL)shouldCloseSelector contextInfo:(void *)contextInfo
{
  // if we have no window controller, find it and add ourselves
  if (self.windowControllers.count == 0) {
    for (DuxProjectWindowController *controller in [DuxProjectWindowController projectWindowControllers]) {
      if ([controller.documents containsObject:self]) {
        if (controller.document) {
          [controller.document removeWindowController:controller];
        }
        [self addWindowController:controller];
        break;
      }
    }
  }
  
  [super canCloseDocumentWithDelegate:delegate shouldCloseSelector:shouldCloseSelector contextInfo:contextInfo];
}

@end
