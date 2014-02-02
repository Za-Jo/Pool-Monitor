//
//  PMDDFType1.m
//  Pool Monitor
//
//  Created by Jonathan Duss on 31.01.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

#import "PMDataDownloaderTypeMultipool.h"

@implementation PMDataDownloaderTypeMultipool

-(void)downloadData:(NSString *) url
{
    NSURL *urlAddress = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    _infoForTV = [[PMInfoFormattedForTV alloc] init];
    
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:urlAddress];
    [req setTimeoutInterval:60];
    
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue currentQueue]completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         
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
     }];

}

-(void)formatData:(NSData *)data
{
    NSError *error;
    _data = data;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    
    
    
    if(error){
        DLog(@"ERROR READING JSON");
        [_delegate dataNotDownloadedBecauseError:error];
    }
    else
    {
        
        //SECTION 1: general informations

        
        [_infoForTV addSectionWithName:@"General Informations"];
        
        //section 1: currencies now + hashrate
        NSDictionary *currencies = [NSDictionary dictionary];
        BOOL active = NO;
        
        if([[dic allKeys] containsObject:@"currency"])
        {
            currencies = [dic valueForKey:@"currency"];
            NSArray *allCurrenciesKeys = [currencies allKeys];
            
            for(NSString *key in allCurrenciesKeys)
            {
                if([[[currencies valueForKey:key] valueForKey:@"hashrate"] intValue] != 0){
                    [_infoForTV addLabel:[NSString stringWithFormat:@"Hashrate [%@]", key] inSection:0];
                    [_infoForTV addInfo:[[currencies valueForKey:key] valueForKey:@"hashrate"] inSection:0];
                    active = YES;
                }
            }
        }
        
        [_infoForTV addLabel:@"Active" inSection:0];
        [_infoForTV addInfo:active ? @"YES" : @"NO" inSection:0];
        
        
        if([[dic allKeys] containsObject:@"currency"])
        {
            currencies = [dic valueForKey:@"currency"];
            NSArray *allCurrenciesKeys = [currencies allKeys];
            
            for(NSString *key in allCurrenciesKeys)
            {
                NSString *amount = [NSString stringWithFormat: @"%.6f", [[[currencies valueForKey:key] valueForKey:@"confirmed_rewards"] floatValue] ];
                if([amount floatValue] > 0)
                {
                    [_infoForTV addLabel:key inSection:0];
                    [_infoForTV addInfo:amount inSection:0];
                }
            }
        }
    }

}

@end
