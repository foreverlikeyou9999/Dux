//
//  DuxPreferencesWindowController.m
//  Dux
//
//  Created by Abhi Beckert on 2011-12-01.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import "DuxPreferencesWindowController.h"
#import "DuxPreferences.h"

@interface DuxPreferencesWindowController ()

- (void)editorFontDidChange:(NSNotification *)notif;

@end

@implementation DuxPreferencesWindowController

@synthesize windowToolbar;
@synthesize editorSectionView;
@synthesize colorsSectionView;

// editor section
@synthesize fontTextField;
@synthesize showLineNumbersButton;
@synthesize showPageGuideButton;
@synthesize pageGuidePositionTextField;
@synthesize showOtherInstancesOfSelectedSymbolButton;
@synthesize indentStylePopUpButton;
@synthesize tabWidthTextField;
@synthesize indentWidthTextField;
@synthesize tabKeyBehaviourPopUpButton;

+ (void)showPreferencesWindow
{
  static DuxPreferencesWindowController *prefsController = nil;
  
  if (!prefsController) {
    prefsController = [[DuxPreferencesWindowController alloc] initWithWindowNibName:@"PreferencesWindow"];
  }
  
  [prefsController showWindow:self];
}

- (id)initWithWindow:(NSWindow *)window
{
  self = [super initWithWindow:window];
  if (self) {
    // Initialization code here.
  }
  
  return self;
}

- (void)awakeFromNib
{
  [super awakeFromNib];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editorFontDidChange:) name:DuxPreferencesEditorFontDidChangeNotification object:nil];
  [self editorFontDidChange:nil];
  
  self.showLineNumbersButton.state = [DuxPreferences showLineNumbers] ? NSOnState : NSOffState;
  self.showPageGuideButton.state = [DuxPreferences showPageGuide] ? NSOnState : NSOffState;
  self.pageGuidePositionTextField.integerValue = [DuxPreferences pageGuidePosition];
	self.showOtherInstancesOfSelectedSymbolButton.state = [DuxPreferences showOtherInstancesOfSelectedSymbol] ? NSOnState : NSOffState;
  
	[self.indentStylePopUpButton selectItemWithTag:(int)[DuxPreferences indentWithSpaces]];
	[self.tabWidthTextField setIntValue:(int)[DuxPreferences tabWidth]];
	[self.indentWidthTextField setIntValue:(int)[DuxPreferences indentWidth]];
  [self.tabKeyBehaviourPopUpButton selectItemWithTag:[DuxPreferences tabIndentBehaviour]];
  
  NSString *sectionIdentifier = [[NSUserDefaults standardUserDefaults] stringForKey:@"PreferencesSelectedSection"];
  if (!sectionIdentifier)
    sectionIdentifier = @"editor";
  [self showSection:sectionIdentifier animate:NO];
}

- (void)editorFontDidChange:(NSNotification *)notif
{
  [self.fontTextField setStringValue:[NSString stringWithFormat:@"%@ - %0.1f", [DuxPreferences editorFont].displayName, [DuxPreferences editorFont].pointSize]];
}

- (void)showSection:(NSString *)sectionIdentifier animate:(BOOL)animate
{
  // figure out which view to show
  NSDictionary *sectionViewsByIdentifier = [NSDictionary dictionaryWithObjectsAndKeys:editorSectionView, @"editor", colorsSectionView, @"colors", nil];
  NSView *sectionView = [sectionViewsByIdentifier objectForKey:sectionIdentifier];
  
  // we need to calculate the height of the window's toolbar
  float windowHeightWithoutToolbar = [NSWindow frameRectForContentRect:(NSRect){{0,0}, [self.window.contentView frame].size} styleMask:NSTitledWindowMask].size.height;
  float toolbarHeight = self.window.frame.size.height - windowHeightWithoutToolbar;
  
  // hide other views, and show this one
  for (NSView *subview in [self.window.contentView subviews]) {
    [subview removeFromSuperview];
  }
  [self.window.contentView addSubview:sectionView];
  
  // figure out what the new window frame needs to be
  NSRect newFrame = [NSWindow frameRectForContentRect:(NSRect){{0,0}, sectionView.frame.size} styleMask:NSTitledWindowMask];
  newFrame.size.height += toolbarHeight;
  
  newFrame.origin.x = self.window.frame.origin.x;
  newFrame.origin.y = self.window.frame.origin.y + (self.window.frame.size.height - newFrame.size.height);
  
  // apply the new frame
  [self.window setFrame:newFrame display:YES animate:animate];
  
  // save the new identifier
  [self.windowToolbar setSelectedItemIdentifier:sectionIdentifier];
  [[NSUserDefaults standardUserDefaults] setObject:sectionIdentifier forKey:@"PreferencesSelectedSection"];
}

- (IBAction)showEditorSection:(id)sender
{
  [self showSection:@"editor" animate:YES];
}

- (IBAction)showColorsSection:(id)sender
{
  [self showSection:@"colors" animate:YES];
}

- (IBAction)setShowLineNumbers:(id)sender
{
  [DuxPreferences setShowLineNumbers:self.showLineNumbersButton.state == NSOnState];
}

- (IBAction)setShowPageGuide:(id)sender
{
  [DuxPreferences setShowPageGuide:self.showPageGuideButton.state == NSOnState];
}

- (IBAction)setPageGuidePosition:(id)sender
{
  [DuxPreferences setPageGuidePosition:self.pageGuidePositionTextField.integerValue];
}

- (IBAction)setTabIndentBehaviour:(id)sender
{
  [DuxPreferences setTabIndentBehaviour:self.tabKeyBehaviourPopUpButton.selectedTag];
}

- (IBAction)setIndentWithSpaces:(id)sender
{
	[DuxPreferences setIndentWithSpaces:(BOOL)self.indentStylePopUpButton.selectedTag];
}

- (IBAction)setTabWidth:(id)sender
{
	[DuxPreferences setTabWidth:(NSUInteger)self.tabWidthTextField.intValue];
}

- (IBAction)setIndentWidth:(id)sender
{
	[DuxPreferences setIndentWidth:(NSUInteger)self.indentWidthTextField.intValue];
}

- (IBAction)setShowOtherInstancesOfSelectedSymbol:(id)sender
{
	[DuxPreferences setShowOtherInstancesOfSelectedSymbol:self.showOtherInstancesOfSelectedSymbolButton.state == NSOnState];
}

@end
