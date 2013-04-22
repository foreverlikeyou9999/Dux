//
//  DuxNavigatorFilesViewController.m
//  Dux
//
//  Created by Abhi Beckert on 2013-4-20.
//
//

#import "DuxNavigatorFilesViewController.h"
#import "DuxNavigatorFileCell.h"

#define COLUMNID_NAME			@"NameColumn" // Name for the file cell
#define kIconImageSize  16.0

@interface DuxNavigatorFilesViewController ()
{
  NSImage						*folderImage;
}

@property NSMutableSet *cachedUrls;
@property NSMutableSet *cacheQueuedUrls;
@property NSMutableDictionary *urlIsDirectoryCache;
@property NSMutableDictionary *urlChildUrlsCache;

@property NSOperationQueue *cacheQueue;

@end

@implementation DuxNavigatorFilesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  if (!(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    return nil;
  
  [self initCache];
  
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
  if (!(self = [super initWithCoder:aDecoder]))
    return nil;
  
  [self initCache];
  
  return self;
}

- (void)initCache
{
  self.urlIsDirectoryCache = @{}.mutableCopy;
  self.urlChildUrlsCache = @{}.mutableCopy;
  self.urlIsDirectoryCache = @{}.mutableCopy;
  self.cachedUrls = [[NSMutableSet alloc] init];
  self.cacheQueuedUrls = [[NSMutableSet alloc] init];
  
  self.cacheQueue = [[NSOperationQueue alloc] init];
  self.cacheQueue.maxConcurrentOperationCount = 1;
}

- (void)awakeFromNib
{
  [self initOutlineCells];
}

- (void)initOutlineCells
{
  NSTableColumn *tableColumn = [self.filesView tableColumnWithIdentifier:COLUMNID_NAME];
  DuxNavigatorFileCell *imageAndTextCell = [[DuxNavigatorFileCell alloc] init];
  [imageAndTextCell setEditable:YES];
  [tableColumn setDataCell:imageAndTextCell];

  folderImage = [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericFolderIcon)];
  [folderImage setSize:NSMakeSize(kIconImageSize, kIconImageSize)];
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
  // root?
  if (!item)
    item = self.rootURL;
  
  // nil item? root is sometimes nil
  if (!self.rootURL)
    return 0;
  
  // is it in the cache yet? if not add it to the chache
  if (![self.cachedUrls containsObject:item]) {
    BOOL didFillQuickly = [self cacheDidMiss:item giveCacheAChanceToFill:YES];
    if (!didFillQuickly)
      return 1;
  }
  
  return [[self.urlChildUrlsCache objectForKey:item] count];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
  // string? eg loading status
  if ([item isKindOfClass:[NSString class]])
    return NO;
  
  // assume it's a url
  NSURL *url = item;
  
  // check value
  NSNumber *isPackage = @NO;
  NSNumber *isDirectory = @NO;
  [url getResourceValue:&isPackage forKey:NSURLIsPackageKey error:NULL];
  [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];
  
  return (isDirectory.boolValue && !isPackage.boolValue);
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
  // root?
  if (!item)
    item = self.rootURL;
  
  // is it in the cache yet? if not add it
  if (![self.cachedUrls containsObject:item]) {
    [self cacheDidMiss:item giveCacheAChanceToFill:NO];
    return @"❔";
  }
  
  return [[self.urlChildUrlsCache objectForKey:item] objectAtIndex:index];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
  // string? eg loading status
  if ([item isKindOfClass:[NSString class]])
    return item;
  
  // assume it's a url
  NSURL *url = item;
  
  // return it
  return url.lastPathComponent;
}

- (NSCell *)outlineView:(NSOutlineView *)outlineView dataCellForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
	return [tableColumn dataCell];
}

- (void)outlineView:(NSOutlineView *)olv willDisplayCell:(NSCell*)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
		if ([self outlineView:olv isItemExpandable:item])
		{
      [(DuxNavigatorFileCell *)cell setImage:folderImage];
    }
    else {
      NSString *fileExtension = [(NSURL *)item pathExtension];
      [(DuxNavigatorFileCell *)cell setImage:[[NSWorkspace sharedWorkspace] iconForFileType:fileExtension]];
    }
}

- (void)setRootURL:(NSURL *)rootURL
{
  if ([rootURL isEqual:_rootURL])
    return;
  
  [self.cacheQueue setSuspended:YES];
  [self.cacheQueue cancelAllOperations];
  
  _rootURL = rootURL;
  
  self.urlIsDirectoryCache = @{}.mutableCopy;
  self.urlChildUrlsCache = @{}.mutableCopy;
  self.urlIsDirectoryCache = @{}.mutableCopy;
  self.cachedUrls = [[NSMutableSet alloc] init];
  
  [self.cacheQueue setSuspended:NO];
  
  [self.filesView reloadData];
}

- (BOOL)cacheDidMiss:(NSURL *)url giveCacheAChanceToFill:(BOOL)giveCacheAChance
{
  if ([self.cacheQueuedUrls containsObject:url])
    return NO;
  
  [self.cacheQueuedUrls addObject:url];
  
  __block BOOL isDone = NO;
  __block NSArray *childUrls = nil;
  
  
  [self.cacheQueue addOperationWithBlock:^{
    // make sure it isn't already cached (we often have a cache miss on the same URL many times)
    // get children, and sort them
    childUrls = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:url includingPropertiesForKeys:@[NSURLIsPackageKey, NSURLIsDirectoryKey] options:0 error:NULL];
    
    childUrls = [childUrls sortedArrayUsingComparator:^NSComparisonResult(NSURL *a, NSURL *b) {
      return [a.lastPathComponent compare:b.lastPathComponent options:NSNumericSearch];
    }];
    
    isDone = YES;
    
    // add to cache and update display
    dispatch_async(dispatch_get_main_queue(), ^{
      if ([self.cachedUrls containsObject:url])
        return;
      
      [self.cachedUrls addObject:url];
      [self.cacheQueuedUrls removeObject:url];
      [self.urlIsDirectoryCache setObject:[NSNumber numberWithBool:NO] forKey:url];
      [self.urlChildUrlsCache setObject:childUrls forKey:url];
      [self.urlIsDirectoryCache setObject:[NSNumber numberWithBool:NO] forKey:url];
      
      [self.filesView reloadData];
    });
  }];
  
  // wait up to 0.02 seconds for the cache to data to be fetched. check every 0.002 seconds if it's in the cache yet
  if (giveCacheAChance) {
    NSDate *startWait = [NSDate date];
    while (!isDone && [startWait timeIntervalSinceNow] > -0.02) {
      usleep(0.002 * 100);
    }
    
    if (isDone) {
      [self.cachedUrls addObject:url];
      [self.cacheQueuedUrls removeObject:url];
      [self.urlIsDirectoryCache setObject:[NSNumber numberWithBool:NO] forKey:url];
      [self.urlChildUrlsCache setObject:childUrls forKey:url];
      [self.urlIsDirectoryCache setObject:[NSNumber numberWithBool:NO] forKey:url];
      
      return YES;
    }
  }
  
  return NO;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
  NSIndexSet *selectedRows = [self.filesView selectedRowIndexes];
  
  // if we only selected one item, open it
  if (selectedRows.count == 1) {
    NSURL *selectedUrl = [self.filesView itemAtRow:selectedRows.firstIndex];
    
    NSNumber *isPackage = @NO;
    NSNumber *isDirectory = @NO;
    [selectedUrl getResourceValue:&isPackage forKey:NSURLIsPackageKey error:NULL];
    [selectedUrl getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];
    
    if (!isDirectory.boolValue && !isPackage.boolValue) {
      if (self.delegate && [self.delegate respondsToSelector:@selector(duxNavigatorDidSelectFile:)]) {
        [self.delegate duxNavigatorDidSelectFile:selectedUrl];
      }
    }
  }
}

@end
