#import <Foundation/Foundation.h>
#pragma once

typedef enum { REGULAR, SYMLINK, SOCKET, CHRDEV, BLKDEV, DIR, FIFO } EntryTypes;

@interface LAWArchiveEntry : NSObject
@property (nonatomic, readonly) NSInteger birthtime;
@property (nonatomic, readonly) gid_t gid;
@property (nonatomic, readonly) uid_t uid;
@property (nonatomic, readonly) NSString* hardlink;
@property (nonatomic, readonly) NSString* pathname;
@property (nonatomic, readonly) NSInteger size;
@property (nonatomic, readonly) NSString* symlink;
@end
