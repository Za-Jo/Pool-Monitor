//
//  PMDataDownloaderGeneral.m
//  Pool Monitor
//
//  Created by Jonathan Duss on 16.03.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

#import "PMDataDownloaderGeneral.h"

@interface PMDataDownloaderGeneral ()
@property (nonatomic) BOOL stopRequested;
@property (nonatomic,strong) NSString *url;
@end


@implementation PMDataDownloaderGeneral

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
    
//#warning load json from file for debug
//    NSLog(@"Warning: load json from file for debug");
//    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"fixxru"ofType:@"json"];
//    _data = [NSData dataWithContentsOfFile:jsonPath];
    
    DLog(@"######################\n\n JSON = %@", [[NSString alloc] initWithData:_data encoding:NSStringEncodingConversionAllowLossy]);
    
    NSError *error;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingAllowFragments error:&error];
    
    
    
    NSUInteger currentSection = 0;
    
    if(error){
        DLog(@"ERROR READING JSON");
        [_delegate dataNotDownloadedBecauseError:error];
    }
    else
    {
        
        //2 standard API. Firts does NOT contain getuserstatus
        if([[dic allKeys] containsObject:@"getuserstatus"] == false){
            
            //SECTION 1: general informations
            [_infoForTV addSectionWithName:@"User Information"];
            
            
            if([[dic allKeys] containsObject:@"hashrate"]){
                [_infoForTV addLabel:@"Hashrate" inSection:0];
                [_infoForTV addInfo:[dic valueForKey:@"hashrate"] inSection:0];
            }
            else if([[dic allKeys] containsObject:@"total_hashrate"]){
                [_infoForTV addLabel:@"Hashrate" inSection:0];
                [_infoForTV addInfo:[dic valueForKey:@"total_hashrate"] inSection:0];
            }
            
            if([[dic allKeys] containsObject:@"balance"]){
                [_infoForTV addLabel:@"Balance" inSection:0];
                [_infoForTV addInfo:[[dic valueForKey:@"balance"] stringValue] inSection:0];
            }
            else if([[dic allKeys] containsObject:@"confirmed_rewards"]){
                [_infoForTV addLabel:@"Balance" inSection:0];
                [_infoForTV addInfo:[dic valueForKey:@"confirmed_rewards"] inSection:0];
            }
            
            
            if([[dic allKeys] containsObject:@"active_workers"]){
                [_infoForTV addLabel:@"Active workers" inSection:0];
                [_infoForTV addInfo:[dic valueForKey:@"active_workers"] inSection:0];
            }
            
            
            
            if([[[NSUserDefaults standardUserDefaults] stringForKey:SETTING_INFO_SHOWN_KEY] isEqualToString:SETTING_INFO_SHOWN_ADVANCED]){
                if([[dic allKeys] containsObject:@"roundestimate"]){
                    [_infoForTV addLabel:@"Round estimate" inSection:0];
                    [_infoForTV addInfo:[dic valueForKey:@"roundestimate"] inSection:0];
                }
                
                if([[dic allKeys] containsObject:@"unconfirmed_rewards"]){
                    [_infoForTV addLabel:@"Unconfirmed rewards" inSection:0];
                    [_infoForTV addInfo:[dic valueForKey:@"unconfirmed_rewards"] inSection:0];
                }
                
                if([[dic allKeys] containsObject:@"round_estimate"]){
                    [_infoForTV addLabel:@"Round estimate" inSection:0];
                    [_infoForTV addInfo:[dic valueForKey:@"round_estimate"] inSection:0];
                }
                
            }
            
            
            //increase currentSection
            currentSection ++;
            
            //OTHER SECTION (dynamic)
            NSDictionary *workers = [dic valueForKey:@"workers"];
            NSArray *workersKeys = [workers allKeys];
            
            //enumerate over each workers
            int nbWorkerAlive = 0;
            
            for (NSString *key in workersKeys) {
                NSDictionary *worker = [workers valueForKey:key]; //current worker we are reading info
                
                
                [_infoForTV addSectionWithName:[@"Worker " stringByAppendingString:key]];
                
                if([[worker allKeys] containsObject:@"hashrate"]){
                    [_infoForTV addLabel:@"Hashrate" inSection:currentSection];
                    [_infoForTV addInfo:[worker valueForKey:@"hashrate"]inSection:currentSection];
                }
                
                if([[worker allKeys] containsObject:@"alive"]){
                    if([[worker valueForKey:@"alive"] intValue] == 0)
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
                
                if([[worker allKeys] containsObject:@"last_checkin"]){
                    [_infoForTV addInfo:[[worker valueForKey:@"last_checkin"] valueForKey:@"date"] inSection:currentSection];
                    [_infoForTV addLabel:@"Last time alive" inSection:currentSection];
                }
                
                currentSection ++;
            }
            
            //NB worker alive
            [_infoForTV addLabel:@"Workers alive" inSection:0];
            [_infoForTV addInfo:[NSString stringWithFormat:@"%d", nbWorkerAlive] inSection:0];
            
            
        }
        //IF FAIL THIS IS THE OTHER REPRESENTATION
        else {
            //mean, it fails before. So remove it.
            
            NSDictionary *dicGet = [dic valueForKey:@"getuserstatus"];
            DLog(@"%@", dicGet);
            DLog(@"%@", [dicGet allKeys]);
            
            if([[dicGet allKeys] containsObject:@"data"]){
                NSDictionary *dicData = [dicGet valueForKey:@"data"];
                
                if([[dicData allKeys] containsObject:@"hashrate"]){
                    [_infoForTV addSectionWithName:@"Information"];
                    [_infoForTV addLabel:@"Hashrate" inSection:0];
                    [_infoForTV addInfo:[dicData valueForKey:@"hashrate"] inSection:0];
                }
            }
            else if ([[dicGet allKeys] containsObject:@"hashrate"])
            {
                [_infoForTV addSectionWithName:@"Information"];
                [_infoForTV addLabel:@"Hashrate" inSection:0];
                [_infoForTV addInfo:[dicGet valueForKey:@"hashrate"] inSection:0];
            }
        }
        
    }
    
}
@end

