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
// document open we want to close the document and show the next one.
- (void)close
{
  if (self.documents.count > 1) {
    MyTextDocument *document = self.document;
    DuxProjectWindowController *selfRef = self; // create strong reference to self, to avoid being deallocated
    
    [self.documents removeObject:document];
    
    [document removeWindowController:self];
    
    [[self.documents objectAtIndex:self.documents.count - 1] addWindowController:self];
    
    selfRef = nil;
    return;
  }
  
  [super close];
}

// as far as I am aware, this is only called when the user clicks the close button with the mouse — and *after* the user has dealt with the
// first "dirty" document. so we close that document (assuming it is saved or the user has chosen not to save it) and then abort the close,
// but send performClose: to self.window.
- (BOOL)windowShouldClose:(id)sender
{
  if (sender != self.window)
    return YES;
  
  if (self.documents.count > 1) {
    MyTextDocument *document = self.document;
    DuxProjectWindowController *selfRef = self; // create strong reference to self, to avoid being deallocated
    
    [self.documents removeObject:document];
    
    [document removeWindowController:self];
    [document close];
    
    [[self.documents objectAtIndex:self.documents.count - 1] addWindowController:self];
    
    selfRef = nil;
    
    int64_t delayInSeconds = 0.001;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
      [self.window performClose:self];
    });
    
    return NO;
  }
  
  return YES;
}

@end
