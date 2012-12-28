//
//  DuxDocumentController.m
//  Dux
//
//  Created by Abhi Beckert on 2012-12-29.
//
//

#import "DuxDocumentController.h"
#import "MyTextDocument.h"
#import "DuxProjectWindowController.h"

@implementation DuxDocumentController

// according to documentation this shouldbe called when quiting with multiple unsaved documents... but it doesn't seem to happen as of OS X 10.8
//- (void)closeAllDocumentsWithDelegate:(id)delegate didCloseAllSelector:(SEL)didCloseAllSelector contextInfo:(void *)contextInfo
//{
//  NSInvocation *didCloseAllInvocation = [NSInvocation invocationWithMethodSignature:[delegate methodSignatureForSelector:didCloseAllSelector]];
//  [didCloseAllInvocation setTarget:delegate];
//  [didCloseAllInvocation setSelector:didCloseAllSelector];
//  
//  for (DuxProjectWindowController *controller in [DuxProjectWindowController projectWindowControllers]) {
//    NSArray *documentsToClose = [controller.documents copy];
//    for (MyTextDocument *document in [documentsToClose reverseObjectEnumerator]) {
//      
//      if (document != controller.document) {
//        [controller setDocument:document];
//      }
//      
//      
//      id contextInfo = @{@"controller": controller, @"closeAllInvocation":didCloseAllInvocation};
//      [document canCloseDocumentWithDelegate:self shouldCloseSelector:@selector(document:shouldClose:contextInfo:) contextInfo:&contextInfo];
//      
//      if (controller.document == document) // document was dirty/unsaved. we must wait until the canClose delegate callback before continuing
//        return;
//    }
//  }
//  
//  // if we get here, either all documents were "clean" or we did not have any open documents
//  id selfInstance = self;
//  BOOL didCloseAll = YES;
//  [didCloseAllInvocation setArgument:&selfInstance atIndex:0];
//  [didCloseAllInvocation setArgument:&didCloseAll atIndex:1];
//  [didCloseAllInvocation setArgument:contextInfo atIndex:2];
//  
//    // - (void)documentController:(NSDocumentController *)docController  didCloseAll: (BOOL)didCloseAll contextInfo:(void *)contextInfo
//}
//
//- (void)document:(NSDocument *)document shouldClose:(BOOL)shouldClose  contextInfo:(void  *)contextInfo
//{
//  if (!shouldClose) {
//    
//    return;
//  }
//  
////  DuxProjectWindowController *controller = self.windowController;
////  [controller.documents removeObject:document];
////  
////  [document removeWindowController:controller];
////  [document close];
////  
////  if (controller.documents.count > 0) {
////    [[controller.documents objectAtIndex:controller.documents.count - 1] addWindowController:controller];
////    
////    [self performClose:self]; // continue closing, until all documents are closed
////  }
//}

@end
