//
//  PMDataDownloaderProtocol.h
//  Pool Monitor
//
//  Created by Jonathan Duss on 31.01.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PMInfoFormattedForTV.h"




@protocol PMDataDownloaderDelegate <NSObject>

@required
-(void)dataDownloadedAndFormatted: (PMInfoFormattedForTV *) informations;
-(void)dataNotDownloadedBecauseError: (NSError *) error;

@end


@protocol PMDataDownloaderProtocol <NSObject>

@required
-(void)setDelegate:(id<PMDataDownloaderDelegate>) delegate;
-(void)downloadData:(NSString *) url;
-(void)cancel;
@end