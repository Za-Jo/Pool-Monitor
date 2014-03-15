//
//  PMDataDownloaderTypeLitecoinPool.m
//  Pool Monitor
//
//  Created by Jonathan Duss on 15.03.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PMDataDownloaderProtocol.h"
#import "PMInfoFormattedForTV.h"
#import "PMDataDownloaderTypeLitecoinPool.h"
#import "PMTools.h"

@interface PMDataDownloaderTypeLitecoinPool ()
@property (nonatomic) BOOL stopRequested;
@end


@implementation PMDataDownloaderTypeLitecoinPool

-(id)init
{
    self = [super init];
    _infoForTV = [[PMInfoFormattedForTV alloc] init];
    _stopRequested = NO;
    return self;
}

-(void)cancel
{
    _delegate = nil;
    _stopRequested = YES;
}

-(void)downloadData:(NSString *) url
{
    
    NSURL *urlAddress = [NSURL URLWithString:url];
    _infoForTV = [[PMInfoFormattedForTV alloc] init];
    
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:urlAddress];
    
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue currentQueue]completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if(_stopRequested == NO){
             if ([data length] >0 && error == nil)
             {
                 DLog(@"%@",[[NSString alloc] initWithData:data encoding:0]);
                 [self formatData:data];
                 [_delegate dataDownloadedAndFormatted:_infoForTV];
             }
             else if ([data length] == 0 && error == nil)
             {
                 DLog(@"Nothing was downloaded.");
                 [_delegate dataNotDownloadedBecauseError:[NSError errorWithDomain:@"NO DATA" code:1 userInfo:nil]];
             }
             else if (error != nil){
                 DLog(@"Error = %@", error);
                 [_delegate dataNotDownloadedBecauseError:error];
             }
         }
     }];
}

-(void)formatData:(NSData *)data
{
    _data = data;
    NSError *error;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    
    if(error){
        DLog(@"ERROR READING JSON");
        [_delegate dataNotDownloadedBecauseError:error];
    }
    else
    {
        NSUInteger currentSection = 0;
        
        //SECTION 1: general informations
        [_infoForTV addSectionWithName:@"General Information"];
        
        NSDictionary *userinfo = [dic valueForKey:@"user"];
        
        if(userinfo != nil){
        
            if([[userinfo allKeys] containsObject:@"hash_rate"]){
                [_infoForTV addLabel:@"Hashrate" inSection:currentSection];
                [_infoForTV addInfo:[userinfo valueForKey:@"hash_rate"] inSection:currentSection];
            }

            if([[userinfo allKeys] containsObject:@"unpaid_rewards"]){
                [_infoForTV addLabel:@"Balance [LTC]" inSection:currentSection];
                NSString *val = [PMTools stringWithLimitStrNumTo:4 for:[userinfo valueForKey:@"unpaid_rewards"]];
                [_infoForTV addInfo:val inSection:currentSection];
            }
        }
        
        
        //SECTION 2: network informations
        currentSection++;
        [_infoForTV addSectionWithName:@"Litecoin network Information"];
        NSDictionary *netInfo = [dic valueForKey:@"network"];
        if(netInfo != nil){
            
            if([[netInfo allKeys] containsObject:@"difficulty"]){
                [_infoForTV addLabel:@"Difficulty" inSection:currentSection];
                NSString *val = [PMTools stringWithLimitStrNumTo:0 for:[netInfo valueForKey:@"difficulty"]];
                [_infoForTV addInfo:val inSection:currentSection];
            }
            
            if([[netInfo allKeys] containsObject:@"next_difficulty"]){
                [_infoForTV addLabel:@"Next difficulty" inSection:currentSection];
                NSString *val = [PMTools stringWithLimitStrNumTo:0 for:[netInfo valueForKey:@"next_difficulty"]];
                [_infoForTV addInfo:val inSection:currentSection];
            }

        }
        

        //SECTION 2: Market
        currentSection++;
        [_infoForTV addSectionWithName:@"Market"];
        NSDictionary *marketInfo = [dic valueForKey:@"market"];
        
        if(marketInfo != nil){
            if([[marketInfo allKeys] containsObject:@"ltc_btc"]){
                [_infoForTV addLabel:@"LTC - BTC" inSection:currentSection];
                NSString *val = [PMTools stringWithLimitStrNumTo:6 for:[marketInfo valueForKey:@"ltc_btc"]];
                [_infoForTV addInfo:val inSection:currentSection];
            }
            
            if([[marketInfo allKeys] containsObject:@"btc_usd"]){
                [_infoForTV addLabel:@"BTC - USD" inSection:currentSection];
                NSString *val = [PMTools stringWithLimitStrNumTo:2 for:[marketInfo valueForKey:@"btc_usd"]];
                [_infoForTV addInfo:val inSection:currentSection];
            }
            if([[marketInfo allKeys] containsObject:@"ltc_usd"]){
                [_infoForTV addLabel:@"LTC - USD" inSection:currentSection];
                NSString *val = [PMTools stringWithLimitStrNumTo:2 for:[marketInfo valueForKey:@"ltc_usd"]];
                [_infoForTV addInfo:val inSection:currentSection];
            }
            
            if([[marketInfo allKeys] containsObject:@"ltc_eur"]){
                [_infoForTV addLabel:@"LTC - €" inSection:currentSection];
                [_infoForTV addInfo:[marketInfo valueForKey:@"ltc_eur"] inSection:currentSection];
            }
            
        }
        
        
        
        //OTHER SECTION (dynamic)
        NSDictionary *workers = [dic valueForKey:@"workers"];
        NSArray *workersKeys = [workers allKeys];
        NSUInteger nbWorker = 0;
        
        currentSection++;
        
        //enumerate over each workers
        for (NSString *key in workersKeys) {
            NSDictionary *worker = [workers valueForKey:key]; //current worker we are reading info
            
            
            [_infoForTV addSectionWithName:[@"Worker " stringByAppendingString:key]];
            
            if([[worker allKeys] containsObject:@"hash_rate"]){
                [_infoForTV addLabel:@"Hashrate" inSection:currentSection];
                [_infoForTV addInfo:[worker valueForKey:@"hash_rate"]inSection:currentSection];
            }
            
            if([[worker allKeys] containsObject:@"hash_rate_24h"]){
                [_infoForTV addLabel:@"Hashrate (24h average)" inSection:currentSection];
                [_infoForTV addInfo:[worker valueForKey:@"hash_rate_24h"]inSection:currentSection];
                
                if([[worker valueForKey:@"hash_rate_24h"] integerValue] > 0){
                    nbWorker++;
                }
            }
            currentSection ++;
        }
        
        if(userinfo != nil){
                [_infoForTV addLabel:@"Active workers" inSection:0];
                [_infoForTV addInfo:[NSString stringWithFormat:@"%lu", (unsigned long)nbWorker] inSection:0];
        }
        
    }
    
}
@end

