//
//  DuxProjectWindow.m
//  Dux
//
//  Created by Abhi Beckert on 2012-12-28.
//
//

#import "DuxProjectWindow.h"
#import "MyTextDocument.h"
#import "DuxProjectWindowController.h"

@implementation DuxProjectWindow

- (void)performClose:(id)sender
{
  DuxProjectWindowController *controller = self.windowController;
  
  NSArray *documentsToClose = [controller.documents copy];
  for (MyTextDocument *document in [documentsToClose reverseObjectEnumerator]) {

    if (document != controller.document) {
      [controller setDocument:document];
    }

    [document canCloseDocumentWithDelegate:self shouldCloseSelector:@selector(document:shouldClose:contextInfo:) contextInfo:NULL];

    if (controller.document == document) // document was dirty/unsaved. we must wait until the canClose delegate callback before continuing
      return;
  }

  if (controller.documents.count == 0) {
    [controller close];
  }

}

- (void)document:(NSDocument *)document shouldClose:(BOOL)shouldClose  contextInfo:(void  *)contextInfo
{
  if (!shouldClose) {
    return;
  }
    
  DuxProjectWindowController *controller = self.windowController;
  [controller.documents removeObject:document];
  
  [document removeWindowController:controller];
  [document close];

  if (controller.documents.count > 0) {
    [[controller.documents objectAtIndex:controller.documents.count - 1] addWindowController:controller];
    
    [self performClose:self]; // continue closing, until all documents are closed
  }
}

@end
