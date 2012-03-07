//
//  DuxFontSelectorTextField.m
//  Dux
//
//  Created by Abhi Beckert on 2012-02-05.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import "DuxFontSelectorTextField.h"
#import "DuxPreferencesWindowController.h"
#import "DuxPreferences.h"

@implementation DuxFontSelectorTextField

@synthesize preferencesWindowController, chooseFontButton;

- (void)awakeFromNib
{
  [super awakeFromNib];
  
  chooseFontButton.target = self;
  chooseFontButton.action = @selector(chooseFontButtonAction:);
}

- (void)chooseFontButtonAction:(id)sender
{
  [self becomeFirstResponder];
  
  [[NSFontManager sharedFontManager] setSelectedFont:[DuxPreferences editorFont] isMultiple:NO];
  [[NSFontManager sharedFontManager] setTarget:self];
  [[NSFontManager sharedFontManager] orderFrontFontPanel:self];
  
  self.chooseFontButton.state = NSOnState;
}

- (void)textDidEndEditing:(NSNotification *)notification
{
  [[NSFontManager sharedFontManager] setTarget:nil];
  
  self.chooseFontButton.state = NSOffState;
}

- (BOOL)acceptsFirstResponder
{
  return YES;
}

- (void)changeFont:(id)sender
{
  NSFont *oldFont = [DuxPreferences editorFont];
  NSFont *newFont = [sender convertFont:oldFont];

  [DuxPreferences setEditorFont:newFont];
}

@end
