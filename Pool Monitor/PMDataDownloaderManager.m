//
//  PMDataDownloaderFormatter.m
//  Pool Monitor
//
//  Created by Jonathan Duss on 29.01.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

#import "PMDataDownloaderManager.h"
#import "Pool.h"

@interface PMDataDownloaderManager()

@property (nonatomic, strong) id<PMDataDownloaderProtocol> downloader;

@end

@implementation PMDataDownloaderManager

-(void)downloadData:(NSString *) url
{
    
    if(([url rangeOfString:@"guardian"].location != NSNotFound)
       || ([url rangeOfString:@"wemineltc"].location != NSNotFound) )
    {
        _downloader = [[PMDataDownloaderTypeGuardian alloc] init];
        [(PMDataDownloaderTypeGuardian*)_downloader setDelegate:self];
        [_downloader downloadData:url];
    }
    else if([url rangeOfString:@"multipool"].location != NSNotFound)
    {
        _downloader = [[PMDataDownloaderTypeMultipool alloc] init];
        [(PMDataDownloaderTypeMultipool*)_downloader setDelegate:self];
        [_downloader downloadData:url];
    }
    else
    {
        _downloader = [[PMDataDownloaderTypeLTCRabbit alloc] init];
        [(PMDataDownloaderTypeLTCRabbit*)_downloader setDelegate:self];
        [_downloader downloadData:url];
    }

}


-(void)dataDownloadedAndFormatted: (PMInfoFormattedForTV *) informations
{
    [_delegate dataDownloadedAndFormatted:informations];
}


-(void)dataNotDownloadedBecauseError: (NSError *) error
{
    [_delegate dataNotDownloadedBecauseError:error];
}

@end
