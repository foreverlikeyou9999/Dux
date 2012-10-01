//
//  DuxFileContentsWatcher.h
//  Dux
//
//  Created by Abhi Beckert on 2012-8-18.
//
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//


#import <Foundation/Foundation.h>

@class DuxFileContentsWatcher;

@protocol DuxFileContentsWatcherDelegate <NSObject>

@required
- (void)fileContentsDidChange:(DuxFileContentsWatcher *)watcher;

@end

@interface DuxFileContentsWatcher : NSObject
{
  NSURL *_url;
  dispatch_source_t source;
}

- (id)initWithURL:(NSURL *)url delegate:(id <DuxFileContentsWatcherDelegate>)delegate; // designated

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, weak) id <DuxFileContentsWatcherDelegate> delegate;

@end
