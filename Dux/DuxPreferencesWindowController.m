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
}

- (void)editorFontDidChange:(NSNotification *)notif
{
  [self.fontTextField setStringValue:[NSString stringWithFormat:@"%@ - %0.1f", [DuxPreferences editorFont].displayName, [DuxPreferences editorFont].pointSize]];
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
