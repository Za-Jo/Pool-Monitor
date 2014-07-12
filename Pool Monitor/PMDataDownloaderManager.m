//
//  PMDataDownloaderFormatter.m
//  Pool Monitor
//
//  Created by Jonathan Duss on 29.01.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

#import "PMDataDownloaderManager.h"
#import "Pool.h"
#import "PMDataDownloaderTypeGuardian.h"
#import "PMDataDownloaderTypeLTCRabbit.h"
#import "PMDataDownloaderTypeMultipool.h"
#import "PMDataDownloaderTypeLitecoinPool.h"
#import "PMDataDownloaderTypeD7.h"
#import "PMDataDownloaderGeneral.h"


@interface PMDataDownloaderManager()

@property (nonatomic, strong) id<PMDataDownloaderProtocol> downloader;

@end

@implementation PMDataDownloaderManager

-(void)downloadData:(NSString *) url
{
    
    /*
     Different downloader according to different type of API
     
     General: for all that are not these particular ones
     
     D7: condition added in general
     */
    
    
    
    
    
    if(([url rangeOfString:@"guardian"].location != NSNotFound)
       || ([url rangeOfString:@"wemineltc"].location != NSNotFound) )
    {
        _downloader = [[PMDataDownloaderTypeGuardian alloc] init];
    }
    else if([url rangeOfString:@"multipool"].location != NSNotFound )
    {
        _downloader = [[PMDataDownloaderTypeMultipool alloc] init];
    }
    else if([url rangeOfString:@"www.litecoinpool.org"].location != NSNotFound)
    {
        _downloader = [[PMDataDownloaderTypeLitecoinPool alloc] init];
    }
    else if ([url rangeOfString:@"rabbit"].location != NSNotFound)
    {
        _downloader = [[PMDataDownloaderTypeLTCRabbit alloc] init];
    }
    else if ([url rangeOfString:@"ppcoin.d7.lt"].location != NSNotFound)
    {
        _downloader = [[PMDataDownloaderTypeD7 alloc] init];
    }
    else
    {
       
        _downloader = [[PMDataDownloaderGeneral alloc] init];
    }
    
    if(_downloader != nil){
        [_downloader setDelegate:self];
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

-(void)cancel
{
    [_downloader cancel];
}

@end
