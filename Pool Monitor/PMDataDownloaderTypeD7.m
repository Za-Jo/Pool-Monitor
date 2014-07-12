//
//  PMDataDownloaderD7.m
//  Pool Monitor
//
//  Created by Jonathan Duss on 10.07.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

#import "PMDataDownloaderTypeD7.h"

@interface PMDataDownloaderTypeD7 ()
@property (nonatomic) BOOL stopRequested;
@property (nonatomic,strong) NSString *url;
@end


@implementation PMDataDownloaderTypeD7

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
    _url = url;
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
    
//        #warning load json from file for debug
//        NSLog(@"Warning: load json from file for debug");
//        NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"d7"ofType:@"json"];
//        _data = [NSData dataWithContentsOfFile:jsonPath];
    
    DLog(@"######################\n\n JSON = %@", [[NSString alloc] initWithData:_data encoding:NSStringEncodingConversionAllowLossy]);
    
    NSError *error;
    NSDictionary *allInfo = [NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingAllowFragments error:&error];
    NSDictionary *userInfo;
    
    //D7 contains general / user / other sections. Only want user
    if([_url rangeOfString:@"ppcoin.d7.lt"].location != NSNotFound )
    {
        if([[allInfo allKeys] containsObject:@"user"]){
            userInfo = [allInfo objectForKey:@"user"];
        }
    }
    
    
    NSUInteger currentSection = 0;
    
    if(error){
        DLog(@"ERROR READING JSON");
        [_delegate dataNotDownloadedBecauseError:error];
    }
    else
    {
        
        //SECTION 1: general informations
        [_infoForTV addSectionWithName:@"Your Information"];
        
        
        if([[userInfo allKeys] containsObject:@"hashrate"]){
            [_infoForTV addLabel:@"Hashrate" inSection:0];
            [_infoForTV addInfo:[userInfo valueForKey:@"hashrate"] inSection:0];
        }
        else if([[userInfo allKeys] containsObject:@"total_hashrate"]){
            [_infoForTV addLabel:@"Hashrate" inSection:0];
            [_infoForTV addInfo:[userInfo valueForKey:@"total_hashrate"] inSection:0];
        }
        
        if([[userInfo allKeys] containsObject:@"balance"]){
            [_infoForTV addLabel:@"Balance" inSection:0];
            [_infoForTV addInfo:[[userInfo valueForKey:@"balance"] stringValue] inSection:0];
        }
        else if([[userInfo allKeys] containsObject:@"confirmed_rewards"]){
            [_infoForTV addLabel:@"Balance" inSection:0];
            [_infoForTV addInfo:[userInfo valueForKey:@"confirmed_rewards"] inSection:0];
        }
        
        if([[userInfo allKeys] containsObject:@"active_workers"]){
            [_infoForTV addLabel:@"Active workers" inSection:0];
            [_infoForTV addInfo:[userInfo valueForKey:@"active_workers"] inSection:0];
        }
        
        //if SETTING_INFO_SHOWN_ADVANCED
        if([[[NSUserDefaults standardUserDefaults] stringForKey:SETTING_INFO_SHOWN_KEY] isEqualToString:SETTING_INFO_SHOWN_ADVANCED]){
            if([[userInfo allKeys] containsObject:@"roundestimate"]){
                [_infoForTV addLabel:@"Round estimate" inSection:0];
                [_infoForTV addInfo:[userInfo valueForKey:@"roundestimate"] inSection:0];
            }
            
            if([[userInfo allKeys] containsObject:@"unconfirmed_rewards"]){
                [_infoForTV addLabel:@"Unconfirmed rewards" inSection:0];
                [_infoForTV addInfo:[userInfo valueForKey:@"unconfirmed_rewards"] inSection:0];
            }
            
        }
        

        
        
        
        //POOL INFO
        if([[allInfo allKeys] containsObject:@"pool"]){
            if([[[NSUserDefaults standardUserDefaults] stringForKey:SETTING_INFO_SHOWN_KEY] isEqualToString:SETTING_INFO_SHOWN_ADVANCED]){
                NSDictionary *poolInfo = [allInfo valueForKey:@"pool"];
                
                //section name Pool information
                currentSection ++;
                [_infoForTV addSectionWithName:@"Pool Information"];

                if([[poolInfo allKeys] containsObject:@"difficulty"]){
                    [_infoForTV addLabel:@"Difficulty" inSection:currentSection];
                    [_infoForTV addInfo:[[poolInfo valueForKey:@"difficulty"] stringValue] inSection:currentSection];
                }
                
                
                if([[poolInfo allKeys] containsObject:@"roundduration"]){
                    [_infoForTV addLabel:@"Round duration" inSection:currentSection];
                    
                    
                    NSDate *start = [NSDate dateWithTimeIntervalSince1970:[[poolInfo valueForKey:@"roundduration"] intValue]];
                    NSDate *now = [NSDate date];
                    
                    NSTimeInterval dif = [now timeIntervalSinceDate:start];
                    
                    int roundDurationSec = dif;
                    
                    int hour = roundDurationSec / 3600.0;
                    roundDurationSec = roundDurationSec - hour * 3600;
                    
                    int minutes = roundDurationSec / 60.0;
                    roundDurationSec = roundDurationSec - minutes * 60;
                    
                    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
                    [nf setMinimumIntegerDigits:2];
                    NSString *duration = [NSString stringWithFormat:@"%dh%@", hour, [nf stringFromNumber:[NSNumber numberWithInt:minutes]]];
                    

                    
                    
                    [_infoForTV addInfo:duration inSection:currentSection];
                }
                
            }
        }
        
        
        
        
        //OTHER SECTION (dynamic)
        currentSection ++;
        if([[userInfo allKeys] containsObject:@"workers"]){
            NSArray *workers = [userInfo valueForKey:@"workers"];
            int nbWorkerAlive = 0;
            
            //enumerate over each workers
            for (NSDictionary *worker in workers) {
                
                if([[worker allKeys] containsObject:@"username"]){
                    [_infoForTV addSectionWithName:[@"Worker " stringByAppendingString:[worker objectForKey:@"username"]]];
                }
                else
                {
                    [_infoForTV addSectionWithName:@"Worker"];
                }
                
                
                if([[worker allKeys] containsObject:@"hashrate"]){
                    [_infoForTV addLabel:@"Hashrate" inSection:currentSection];
                    [_infoForTV addInfo:[worker valueForKey:@"hashrate"]inSection:currentSection];
                }
                
                if([[worker allKeys] containsObject:@"active"]){
                    if([[worker valueForKey:@"active"] intValue] == 0)
                    {
                        [_infoForTV addInfo:@"NO" inSection:currentSection];
                    }
                    else
                    {
                        [_infoForTV addInfo:@"YES" inSection:currentSection];
                        nbWorkerAlive ++;
                    }
  
                        [_infoForTV addLabel:@"Worker alive?" inSection:currentSection];
                    
                }
                
                //if SETTING_INFO_SHOWN_ADVANCED
                if([[[NSUserDefaults standardUserDefaults] stringForKey:SETTING_INFO_SHOWN_KEY] isEqualToString:SETTING_INFO_SHOWN_ADVANCED]){
                    
                    if([[worker allKeys] containsObject:@"rejects"]){
                        NSDictionary *rejects = [worker valueForKey:@"rejects"];
                        if([[rejects allKeys] containsObject:@"stale"]){
                            [_infoForTV addLabel:@"Stale" inSection:currentSection];
                            [_infoForTV addInfo:[[rejects valueForKey:@"stale"] stringValue] inSection:currentSection];
                        }
                    }
                    
                }
                
                currentSection ++;
            }
            
            
            //add info on nbWorkerAlive
            [_infoForTV addLabel:@"Workers alive" inSection:0];
            [_infoForTV addInfo:[NSString stringWithFormat:@"%d", nbWorkerAlive] inSection:0];
        }
        
        
    }
    
}
@end

