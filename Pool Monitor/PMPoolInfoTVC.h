//
//  PMPoolInfoTVC.h
//  Pool Monitor
//
//  Created by Jonathan Duss on 23.01.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pool.h"
#import "PMInfoFormattedForTV.h"
#import "PMDataDownloaderProtocol.h"


@interface PMPoolInfoTVC : UITableViewController <NSURLConnectionDelegate, PMDataDownloaderDelegate>
@property (nonatomic, strong) Pool *pool;
@end
