//
//  PMDDFType1.m
//  Pool Monitor
//
//  Created by Jonathan Duss on 31.01.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

#import "PMDataDownloaderTypeMultipool.h"

@interface PMDataDownloaderTypeMultipool ()
@property (nonatomic) BOOL stopRequested;
@end

@implementation PMDataDownloaderTypeMultipool


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
    
    NSURL *urlAddress = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    _infoForTV = [[PMInfoFormattedForTV alloc] init];
    
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:urlAddress];
    [req setTimeoutInterval:60];
    
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
    NSError *error;
    _data = data;
    
//#warning load json from file for debug
//    NSLog(@"Warning: load json from file for debug");
//    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"multi"ofType:@"json"];
//    _data = [NSData dataWithContentsOfFile:jsonPath];
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingAllowFragments error:&error];
    
    
    
    
    if(error){
        DLog(@"ERROR READING JSON");
        [_delegate dataNotDownloadedBecauseError:error];
    }
    else
    {
        
        //SECTION 1: general informations
        
        
        
        NSDictionary *currencies = [NSDictionary dictionary];
        
        int currentSection = 0;
        
        if([[dic allKeys] containsObject:@"currency"])
        {
            currencies = [dic valueForKey:@"currency"];
            NSArray *allCurrenciesKeys = [currencies allKeys];
            
            //hashrate section
            [_infoForTV addSectionWithName:@"Hashrate"];
            for(NSString *key in allCurrenciesKeys)
            {
                
                if([[[currencies valueForKey:key] valueForKey:@"hashrate"] intValue] != 0){
                    
                    [_infoForTV addLabel:[NSString stringWithFormat:@"%@", key] inSection:currentSection];
                    [_infoForTV addInfo:[[currencies valueForKey:key] valueForKey:@"hashrate"] inSection:currentSection];
                }
            }
            if([_infoForTV numberRowInSection:currentSection] < 1){
                [_infoForTV removeSection:currentSection];
                currentSection--;
            }
            
            
            //SECTION 2
            currentSection++;
            [_infoForTV addSectionWithName:@"Confirmed rewards"];
            for(NSString *key in allCurrenciesKeys)
            {
                NSString *amount = [NSString stringWithFormat: @"%.6f", [[[currencies valueForKey:key] valueForKey:@"confirmed_rewards"] floatValue] ];
                
                if([amount floatValue] > 0)
                {
                    [_infoForTV addLabel:key inSection:currentSection];
                    [_infoForTV addInfo:amount inSection:currentSection];
                }
            }
            if([_infoForTV numberRowInSection:currentSection] < 1){
                [_infoForTV removeSection:currentSection];
                currentSection--;
            }
            
            
            //SECTOIN 2.5
            currentSection++;
            [_infoForTV addSectionWithName:@"Workers hashrate"];
            if([[dic allKeys] containsObject:@"workers"]){
                NSDictionary *workersCurrencies = [dic valueForKey:@"workers"];
                
                for(NSString *key in [workersCurrencies allKeys]){
                    NSDictionary *workersForCurrency = [workersCurrencies valueForKey:key];
                    
                    for(NSString *worker in [workersForCurrency allKeys]){
                        NSDictionary *workerDic = [workersForCurrency valueForKey:worker];
                        int workerHashrate = [[workerDic valueForKey:@"hashrate"] intValue];
                        if(workerHashrate > 0){
                            NSString *label = [NSString stringWithFormat:@"%@ [%@]", worker, key];
                            [_infoForTV addLabel:label inSection:currentSection];
                            [_infoForTV addInfo:[NSString stringWithFormat:@"%d", workerHashrate] inSection:currentSection];
                        }
                    }
                    
                }
                
            }
            if([_infoForTV numberRowInSection:currentSection] < 1){
                [_infoForTV removeSection:currentSection];
                currentSection--;
            }
            
            
            
            
            if([[[NSUserDefaults standardUserDefaults] stringForKey:SETTING_INFO_SHOWN_KEY] isEqualToString:SETTING_INFO_SHOWN_ADVANCED]){
                
                //SECTION 3
                currentSection++;
                [_infoForTV addSectionWithName:@"Estimated rewards"];
                for(NSString *key in allCurrenciesKeys)
                {
                    NSString *estimatedRewards = [NSString stringWithFormat: @"%.6f", [[[currencies valueForKey:key] valueForKey:@"estimated_rewards"] floatValue] ];
                    if([estimatedRewards floatValue] > 0){
                        [_infoForTV addLabel:key inSection:currentSection];
                        [_infoForTV addInfo:estimatedRewards inSection:currentSection];
                    }
                }
                if([_infoForTV numberRowInSection:currentSection] < 1){
                    [_infoForTV removeSection:currentSection];
                    currentSection--;
                }
                
                
                //SECTOIN 4
                currentSection++;
                [_infoForTV addSectionWithName:@"Payout history"];
                for(NSString *key in allCurrenciesKeys)
                {
                    NSString *estimatedRewards = [NSString stringWithFormat: @"%.6f", [[[currencies valueForKey:key] valueForKey:@"payout_history"] floatValue] ];
                    if([estimatedRewards floatValue] > 0){
                        [_infoForTV addLabel:key inSection:currentSection];
                        [_infoForTV addInfo:estimatedRewards inSection:currentSection];
                    }
                }
                if([_infoForTV numberRowInSection:currentSection] < 1){
                    [_infoForTV removeSection:currentSection];
                    currentSection--;
                }
            }
            
            
        }
        
        
    }
    
}

@end
