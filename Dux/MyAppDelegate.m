//
//  MyAppDelegate.m
//  Dux
//
//  Created by Abhi Beckert on 2011-08-25.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import "MyAppDelegate.h"
#import "NSStringDuxAdditions.h"
#import "DuxPreferences.h"
#import "DuxPreferencesWindowController.h"
#import "DuxProjectWindowController.h"

@interface MyAppDelegate ()

@end

@implementation MyAppDelegate

+ (void)initialize
{
  [DuxPreferences registerDefaults];
}

- (id)init
{
  if (!(self = [super init]))
    return nil;
  
  return self;
}

- (IBAction)showPreferences:(id)sender
{
  [DuxPreferencesWindowController showPreferencesWindow];
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
  BOOL isDirectory;
  [[NSFileManager defaultManager] fileExistsAtPath:filename isDirectory:&isDirectory];
  
  if (isDirectory) {
    DuxProjectWindowController *controller = [DuxProjectWindowController newProjectWindowControllerWithRoot:[NSURL fileURLWithPath:filename]];
    
    [controller showWindow:self];
    
    return YES;
  }
  
  [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:[NSURL fileURLWithPath:filename] display:YES error:NULL];
  return YES;
}

- (IBAction)newWindow:(id)sender
{
  DuxProjectWindowController *controller = [DuxProjectWindowController newProjectWindowControllerWithRoot:nil];
  
  [controller showWindow:self];
}

- (IBAction)setProjectRoot:(id)sender
{
  DuxProjectWindowController *controller = [DuxProjectWindowController newProjectWindowControllerWithRoot:nil];
  
  [controller showWindow:self];
  
  [controller setProjectRoot:sender];
}

@end
