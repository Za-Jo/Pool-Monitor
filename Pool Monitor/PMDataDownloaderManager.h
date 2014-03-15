//
//  PMDataDownloaderFormatter.h
//  Pool Monitor
//
//  Created by Jonathan Duss on 29.01.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Pool.h"
#import "PMDataDownloaderProtocol.h"
#import "PMDataDownloaderTypeGuardian.h"
#import "PMDataDownloaderTypeLTCRabbit.h"
#import "PMDataDownloaderTypeMultipool.h"
#import "PMDataDownloaderTypeLitecoinPool.h"


@interface PMDataDownloaderManager : NSObject <PMDataDownloaderDelegate>
-(void)downloadData:(NSString *) url;
@property (nonatomic, strong) id<PMDataDownloaderDelegate> delegate;
-(void)cancel;

@end
