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
@synthesize lineWrappingButton;
@synthesize lineWrappingSizeTextField;

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
  
  self.showLineNumbersButton.state = [DuxPreferences showLineNumbers] ? NSOnState : NSOffState;
  self.showPageGuideButton.state = [DuxPreferences showPageGuide] ? NSOnState : NSOffState;
  self.pageGuidePositionTextField.integerValue = [DuxPreferences pageGuidePosition];
  
	[self.indentStylePopUpButton selectItemWithTag:(int)[DuxPreferences indentWithSpaces]];
	[self.tabWidthTextField setIntValue:(int)[DuxPreferences tabWidth]];
	[self.indentWidthTextField setIntValue:(int)[DuxPreferences indentWidth]];
  [self.tabKeyBehaviourPopUpButton selectItemWithTag:[DuxPreferences tabIndentBehaviour]];
  
  [showOtherInstancesOfSelectedSymbolButton setEnabled:NO];
  
  [lineWrappingButton setEnabled:NO];
  [lineWrappingSizeTextField setEnabled:NO];
}

- (IBAction)selectEditorFont:(id)sender
{
  [[NSFontManager sharedFontManager] setSelectedFont:[DuxPreferences editorFont] isMultiple:NO];
  [[NSFontManager sharedFontManager] orderFrontFontPanel:self];
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

- (void)changeFont:(id)sender
{
  NSFont *oldFont = [DuxPreferences editorFont];
  NSFont *newFont = [sender convertFont:oldFont];
  
  [DuxPreferences setEditorFont:newFont];
}

@end
