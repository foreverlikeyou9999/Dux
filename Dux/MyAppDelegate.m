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
#import "DuxMultiFileSearchWindowController.h"

@interface MyAppDelegate ()

@property (nonatomic, strong) DuxMultiFileSearchWindowController *multiFileSearchWindowController;

@end

@implementation MyAppDelegate
@synthesize openQuicklyController;

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

- (IBAction)openQuickly:(id)sender
{
  if (!openQuicklyController) {
    [NSBundle loadNibNamed:@"OpenQuickly" owner:self];
  }
  
  [self.openQuicklyController showOpenQuicklyPanel];
}

- (IBAction)findInFiles:(id)sender
{
  if (!self.multiFileSearchWindowController) {
    self.multiFileSearchWindowController = [[DuxMultiFileSearchWindowController alloc] initWithWindowNibName:@"DuxMultiFileSearchWindowController"];
  }
  
  [self.multiFileSearchWindowController showWindow:self];
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
    if (!openQuicklyController) {
      [NSBundle loadNibNamed:@"OpenQuickly" owner:self];
    }
    
    self.openQuicklyController.searchPath = filename;
    [[NSUserDefaults standardUserDefaults] setValue:filename forKey:@"OpenQuicklySearchPath"];
    [self.openQuicklyController showOpenQuicklyPanel];
    
    return YES;
  }
  
  [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:[NSURL fileURLWithPath:filename] display:YES error:NULL];
  return YES;
}

@end
