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

- (id)initWithWindow:(NSWindow *)window
{
  if (!(self = [super initWithWindow:window]))
    return nil;
  
  self.rootUrl = [NSURL fileURLWithPath:[[NSUserDefaults standardUserDefaults] stringForKey:@"OpenQuicklySearchPath"] isDirectory:YES];
  if (!self.rootUrl) {
    self.rootUrl = [NSURL fileURLWithPath:[@"~" stringByExpandingTildeInPath] isDirectory:YES];
  }
  
  self.documents = [NSMutableArray array];
  
  return self;
}

- (void)windowDidLoad
{
  [super windowDidLoad];
  
  if (self.document) {
    [(MyTextDocument *)self.document loadIntoProjectWindowController:self];
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
  if (!document)
    return;
  
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

@end
