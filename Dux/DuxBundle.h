//
//  DuxBundle.h
//  Dux
//
//  Created by Abhi Beckert on 2013-1-1.
//
//

#import <Foundation/Foundation.h>

@class DuxTextView;

@interface DuxBundle : NSObject

@property (readonly) NSString *displayName;
@property (readonly) NSURL *URL;
@property (readonly) NSMenuItem *menuItem;
@property (readonly) NSString *inputType;
@property (readonly) NSString *outputType;
@property (readonly) NSArray *tabTriggers;

+ (DuxBundle *)bundleForSender:(id)sender;
+ (NSArray *)allBundles;
+ (NSArray *)tabTriggerBundlesSortedByTriggerLength; // each item is a dictionary with values for @"trigger" and @"bundle"

+ (void)loadBundles; // begins a background thread to find and load new or updated bundles
+ (NSURL *)bundlesURL;

- (NSString *)runWithWorkingDirectory:(NSURL *)workingDirectoryURL currentFile:(NSURL *)currentFile editorView:(DuxTextView *)editorView;

@end

extern const NSString *DuxBundleTypeScript;
extern const NSString *DuxBundleTypeSnippet;
extern const NSString *DuxBundleInputTypeNone;
extern const NSString *DuxBundleInputTypeAlert;
extern const NSString *DuxBundleInputTypeDocumentContents;
extern const NSString *DuxBundleOutputTypeNone;
extern const NSString *DuxBundleOutputTypeInsertText;
extern const NSString *DuxBundleOutputTypeInsertSnippet;
extern const NSString *DuxBundleOutputTypeReplaceDocument;
extern const NSString *DuxBundleOutputTypeAlert;
