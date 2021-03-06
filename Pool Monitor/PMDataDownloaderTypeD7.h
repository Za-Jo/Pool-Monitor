//
//  PMDataDownloaderD7.h
//  Pool Monitor
//
//  Created by Jonathan Duss on 10.07.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PMDataDownloaderProtocol.h"
#import "PMInfoFormattedForTV.h"


@interface PMDataDownloaderTypeD7 : NSObject <PMDataDownloaderProtocol>
@property (nonatomic, strong) id<PMDataDownloaderDelegate> delegate;
@property (nonatomic, strong) PMInfoFormattedForTV *infoForTV;
@property (nonatomic, strong) NSData *data;
@end