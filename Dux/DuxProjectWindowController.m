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

@interface DuxProjectWindowController ()

@end

@implementation DuxProjectWindowController

static NSMutableArray *projects = nil;

+ (void)initialize
{
  projects = [NSMutableArray array];
}

+ (DuxProjectWindowController *)newProjectWindowControllerWithRoot:(NSURL *)rootUrl
{
  DuxProjectWindowController *controller = [[DuxProjectWindowController alloc] initWithWindowNibName:@"MyTextDocument"];
  if (rootUrl)
    controller.rootUrl = rootUrl;
  
  [projects addObject:controller];
  
  return controller;
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
    [(MyTextDocument *)self.document loadIntoProjectWindowController:self];
    [self.textView.enclosingScrollView setHidden:NO];
  } else {
    [self.textView.enclosingScrollView setHidden:YES];
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
    [self.textView.enclosingScrollView setHidden:YES];
    return;
  }
  [self.textView.enclosingScrollView setHidden:NO];
  
  
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
  [document loadIntoProjectWindowController:self];
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
  
  [self setDocument:document];
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

@end
