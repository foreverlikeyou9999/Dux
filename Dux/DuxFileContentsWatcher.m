//
//  DuxFileContentsWatcher.m
//  Dux
//
//  Created by Abhi Beckert on 2012-8-18.
//
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import "DuxFileContentsWatcher.h"
#import <CommonCrypto/CommonDigest.h>

@interface DuxFileContentsWatcher()

@property (nonatomic,readwrite) NSString *urlContentsHash;

- (void)registerKQueue;
- (void)deregisterKQueue;

- (NSString *)hashFromUrl:(NSURL *)url;
- (NSString *)hashFromData:(NSData *)data;

@end

@implementation DuxFileContentsWatcher

- (id)initWithURL:(NSURL *)url delegate:(id)delegate
{
  if (!(self = [super init]))
    return nil;
  
  _url = nil; // init as nil, because setter relies on this the first time it's called
  self.url = url;
  self.delegate = delegate;
  
  return self;
}

- (id)init
{
  return [self initWithURL:nil delegate:nil];
}

- (void)dealloc
{
  // make sure kqueue is deregistered
  if (_url)
    self.url = nil;
}

- (void)setUrl:(NSURL *)url
{
  if ([_url isEqual:url]) {
    return;
  }
  
  if (_url)
    [self deregisterKQueue];
  
  _url = [url copy];
  
  if (_url)
    [self registerKQueue];
}

- (void)registerKQueue
{
  // save a hash of the current file contents (so we can see if events actually resulted in a change)
  self.urlContentsHash = [self hashFromUrl:self.url];
  
  // setup file watch events
  int fildes = open([self.url.path cStringUsingEncoding:NSUTF8StringEncoding], O_RDONLY);
  
  dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE,fildes,
                                                    DISPATCH_VNODE_DELETE | DISPATCH_VNODE_WRITE | DISPATCH_VNODE_EXTEND | DISPATCH_VNODE_ATTRIB | DISPATCH_VNODE_LINK | DISPATCH_VNODE_RENAME | DISPATCH_VNODE_REVOKE,
                                                    queue);
  
  __block BOOL isFirst = YES;
  dispatch_source_set_event_handler(source, ^
  {
    if (isFirst) {
      isFirst = NO;
      return;
    }
    double delayInSeconds = 0.25;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
      NSString *newHash = [self hashFromUrl:self.url];
      
      if (![newHash isEqual:self.urlContentsHash]) {
        [self.delegate fileContentsDidChange:self];
        
        [self deregisterKQueue];
        [self registerKQueue];
      }
    });
  });
  
  dispatch_source_set_cancel_handler(source, ^(void) {
    close(fildes);
  });
  
  dispatch_resume(source);
}

- (void)deregisterKQueue
{
  dispatch_source_cancel(source);
}

- (NSString *)hashFromUrl:(NSURL *)url
{
  return [self hashFromData:[[NSData alloc] initWithContentsOfURL:self.url]];
}

- (NSString *)hashFromData:(NSData *)data
{
  unsigned char outputData[CC_MD5_DIGEST_LENGTH];
  
  CC_MD5([data bytes], (CC_LONG)data.length, outputData);
  
  NSMutableString *hash = [[NSMutableString alloc] init];
  for (NSUInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
    [hash appendFormat:@"%02x", outputData[i]];
  }
  
  return [hash copy];
}

- (void)ignoreNewFileContents:(NSData *)newContents
{
  self.urlContentsHash = [self hashFromData:newContents];
}

@end
