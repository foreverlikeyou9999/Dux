//
//  DuxProjectWindowController.m
//  Dux
//
//  Created by Abhi Beckert on 2012-12-26.
//
//

#import "DuxProjectWindowController.h"
#import "MyTextDocument.h"
#import "MyOpenQuicklyController.h"
#import "DuxMultiFileSearchWindowController.h"

@interface DuxProjectWindowController ()

@property (nonatomic, strong) DuxMultiFileSearchWindowController *multiFileSearchWindowController;

@end

@implementation DuxProjectWindowController

static NSMutableArray *projects = nil;

+ (void)initialize
{
  projects = [NSMutableArray array];
}

+ (NSArray *)projectWindowControllers
{
  return [projects copy];
}

+ (DuxProjectWindowController *)newProjectWindowControllerWithRoot:(NSURL *)rootUrl
{
  DuxProjectWindowController *controller = [[DuxProjectWindowController alloc] initWithWindowNibName:@"MyTextDocument"];
  if (rootUrl)
    controller.rootUrl = rootUrl;
  
  [projects addObject:controller];
  
  return controller;
}

+ (void)closeProjectWindowController:(DuxProjectWindowController *)controller
{
  [projects removeObject:controller];
}

- (id)initWithWindow:(NSWindow *)window
{
  if (!(self = [super initWithWindow:window]))
    return nil;
  
  self.rootUrl = [NSURL fileURLWithPath:[@"~" stringByExpandingTildeInPath] isDirectory:YES];
  
  self.documents = [NSMutableArray array];
  
  return self;
}

- (void)windowDidLoad
{
  [super windowDidLoad];
  
  if (self.document) {
    [(MyTextDocument *)self.document loadIntoProjectWindowController:self documentView:self.documentView];
  }
  
   // seems to be a bug in IB that prevents custom views from being properly connected to their toolbar item
  self.historyToolbarItem.view = self.historyToolbarItemView;
  self.pathToolbarItem.view = self.pathToolbarItemView;
  
  [self reloadDocumentHistoryPopUp];
}

- (void)setDocument:(MyTextDocument *)document
{
  [super setDocument:document];
  
  // if we are clearing the document, do nothing else
  if (!document) {
    for (NSView *subview in self.documentView.subviews) {
      [subview removeFromSuperview];
    }
    return;
  }
  
  
  // add to the end of documents (or move it to the end if it's already there)
  if ([self.documents containsObject:document]) {
    [self.documents removeObject:document];
  }
  [self.documents addObject:document];
  
  
  
  // if window isn't lodaed yet, the rest must wait until after windowDidLoad
  if (!self.window)
    return;
  
  // reload history pull down
  [self reloadDocumentHistoryPopUp];
  
  // load the document
  for (NSView *subview in self.documentView.subviews) {
    [subview removeFromSuperview];
  }
  [document loadIntoProjectWindowController:self documentView:self.documentView];
}

- (void)reloadDocumentHistoryPopUp
{
  // remove all items but the first
  NSMenuItem *firstItem = [self.documentHistoryPopUp.menu itemAtIndex:0];
  [self.documentHistoryPopUp.menu removeAllItems];
  [self.documentHistoryPopUp.menu addItem:firstItem];
  
  for (MyTextDocument *document in self.documents.reverseObjectEnumerator) {
    NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:document.displayName action:NULL keyEquivalent:@""];
    
    [self.documentHistoryPopUp.menu addItem:menuItem];
  }
  
}

- (IBAction)loadDocumentFromHistoryPopUp:(NSPopUpButton *)sender
{
  NSUInteger index = sender.indexOfSelectedItem;
  index = self.documents.count - index;
  
  MyTextDocument *document = [self.documents objectAtIndex:index];
  if (self.document == document)
    return;
  
  [self.document removeWindowController:self];
  [document addWindowController:self];
}

- (IBAction)openQuickly:(id)sender
{
  if (!self.openQuicklyController) {
    [NSBundle loadNibNamed:@"OpenQuickly" owner:self];
  }
  self.openQuicklyController.searchUrl = self.rootUrl;
  
  [self.openQuicklyController showOpenQuicklyPanel];
}

- (IBAction)setProjectRoot:(id)sender
{
  NSOpenPanel *panel = [NSOpenPanel openPanel];
  panel.canChooseDirectories = YES;
  panel.canChooseFiles = NO;
  panel.allowsMultipleSelection = NO;
  panel.directoryURL = self.rootUrl;
  panel.prompt = @"Set";
  panel.message = @"Set Current Working Directory:";
  
  [panel beginSheetModalForWindow:self.editorWindow completionHandler:^(NSInteger result) {
    if (result == NSCancelButton)
      return;
    
    self.rootUrl = panel.URL;
    [self synchronizeWindowTitleWithDocumentName];
  }];
}

- (void)synchronizeWindowTitleWithDocumentName
{
  if (self.document)
    return [super synchronizeWindowTitleWithDocumentName];
  
  
  self.window.title = [self.rootUrl.path stringByAbbreviatingWithTildeInPath];
}

- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName
{
  return [NSString stringWithFormat:@"%@ — %@", displayName, [self.rootUrl.path stringByAbbreviatingWithTildeInPath]];
}

- (IBAction)newWindow:(id)sender
{
  DuxProjectWindowController *controller = [DuxProjectWindowController newProjectWindowControllerWithRoot:self.rootUrl];
  
  [controller showWindow:self];
}

- (IBAction)findInFiles:(id)sender
{
  if (!self.multiFileSearchWindowController) {
    self.multiFileSearchWindowController = [[DuxMultiFileSearchWindowController alloc] initWithWindowNibName:@"DuxMultiFileSearchWindowController"];
  }
  
  [self.multiFileSearchWindowController showWindowWithSearchPath:self.rootUrl.path];
}

// as far as I am aware, this is only called by the document architecture when quitting the app. in that case, if there is more than one
// document open we want to close the document.
- (void)close
{
  if (self.documents.count > 1) {
    MyTextDocument *document = self.document;

    [self.documents removeObject:document];
    [document removeWindowController:self];
    return;
  }
  
  [DuxProjectWindowController closeProjectWindowController:self];
  
  [super close];
}

// as far as I am aware, this is only called when the user clicks the close button or presses Cmd-W — and *after* the user has dealt with the
// first "dirty" document. so we close that document (assuming it is saved or the user has chosen not to save it) and then go through the rest
// of the documents checking if they are dirty and asking the user what to do. If none of them are dirty, we close the window.
- (BOOL)windowShouldClose:(id)sender
{
  if (sender != self.window)
    return YES;
  
  // if we have no document visible but there is at least one not visible, present that document now (should never happen but do it just to be safe)
  if (!self.document && self.documents.count > 0)
    [[self.documents objectAtIndex:self.documents.count - 1] addWindowController:self];
  
  // we need a reference to self to prevent ARC from deallocating us too early
  id selfRef = self;
  
  // close the current document, and then recursively move on to the next document
  if (self.document)
    [self closeAllDocumentsWithDocument:self.document shouldClose:YES contextInfo:NULL];
  
  // if all documents were closed, allow the window to close
  BOOL shouldClose = (self.documents.count == 0);
  
  selfRef = nil;
  return shouldClose;
}


- (void)closeAllDocumentsWithDocument:(NSDocument *)document shouldClose:(BOOL)shouldClose  contextInfo:(void  *)contextInfo
{
  // user cancelled the operation
  if (!shouldClose) {
    return;
  }
  
  // user dealt with the dirty document (or it wasn't dirty). close it now.
  [self.documents removeObject:document];
  [document removeWindowController:self];
  [document close];
  
  [self reloadDocumentHistoryPopUp];
  
  // start the process again with the next document (we recursively go through all documents)
  if (self.documents.count > 0) {
    MyTextDocument *document = [self.documents objectAtIndex:self.documents.count - 1];
    [document addWindowController:self];
    
    [document canCloseDocumentWithDelegate:self shouldCloseSelector:@selector(closeAllDocumentsWithDocument:shouldClose:contextInfo:) contextInfo:NULL];
    return;
  }
  
  // we got to the last document. close ourself now
  [self.window close];
  [DuxProjectWindowController closeProjectWindowController:self];
}

- (void)closeOneDocument:(NSDocument *)document shouldClose:(BOOL)shouldClose  contextInfo:(void  *)contextInfo
{
  // user cancelled the operation
  if (!shouldClose) {
    return;
  }
  
  // user dealt with the dirty document (or it wasn't dirty). close it now.
  [self.documents removeObject:document];
  [document removeWindowController:self];
  [document close];
  
  [self reloadDocumentHistoryPopUp];
  
  // open the next document in the list
  if (self.documents.count > 0) {
    MyTextDocument *document = [self.documents objectAtIndex:self.documents.count - 1];
    [document addWindowController:self];
  }
}

- (IBAction)closeDocument:(id)sender
{
  [self.document canCloseDocumentWithDelegate:self shouldCloseSelector:@selector(closeOneDocument:shouldClose:contextInfo:) contextInfo:NULL];
}

- (BOOL)validateMenuItem:(NSMenuItem *)item
{
  if (item.action == @selector(closeDocument:)) {
    if (self.document) {
      item.title = [NSString stringWithFormat:@"Close “%@”", [self.document displayName]];
      return YES;
    }
    
    item.title = @"Close Document";
    return NO;
  }
  
  return YES;
}

@end
