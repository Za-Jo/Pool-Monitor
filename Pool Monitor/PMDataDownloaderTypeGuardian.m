//
//  PMDataDownloaderTypeGuardian.m
//  Pool Monitor
//
//  Created by Jonathan Duss on 01.02.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

#import "PMDataDownloaderTypeGuardian.h"

@implementation PMDataDownloaderTypeGuardian

-(void)downloadData:(NSString *) url
{
    
    NSURL *urlAddress = [NSURL URLWithString:url];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:urlAddress];
    
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue currentQueue]completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if ([data length] >0 && error == nil)
         {
             DLog(@"%@",[[NSString alloc] initWithData:data encoding:0]);
             [self formatData:data];
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
    _data = data;
    NSError *error;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    
    if(error){
        DLog(@"ERROR READING JSON");
        [_delegate dataNotDownloadedBecauseError:error];
    }
    else
    {
        //SECTION 1: general informations
        [_infoForTV setSectionName:@"General Informations" AtIndex:0];
        
        
        if([[dic allKeys] containsObject:@"hashrate"]){
            [_infoForTV setLabel:@"Hashrate" inSection:0];
            [_infoForTV setInfo:[[dic valueForKey:@"hashrate"] string] inSection:0];
        }
        
        if([[dic allKeys] containsObject:@"active_workers"]){
            [_infoForTV setLabel:@"Active workers" inSection:0];
            [_infoForTV setInfo:[[dic valueForKey:@"active_workers"] string] inSection:0];
        }
        
        if([[dic allKeys] containsObject:@"balance"]){
            [_infoForTV setLabel:@"Balance" inSection:0];
            [_infoForTV setInfo:[[dic valueForKey:@"balance"] string] inSection:0];
        }
        else if([[dic allKeys] containsObject:@"confirmed_rewards"]){
            [_infoForTV setLabel:@"Balance" inSection:0];
            [_infoForTV setInfo:[[dic valueForKey:@"confirmed_rewards"] string] inSection:0];
        }
        
        
        
        //OTHER SECTION (dynamic)
        NSDictionary *workers = [dic valueForKey:@"workers"];
        NSArray *workersKeys = [workers allKeys];
        NSUInteger currentSection = 1;
        
        //enumerate over each workers
        for (NSString *key in workersKeys) {
            NSDictionary *worker = [workers valueForKey:key]; //current worker we are reading info
            
            
            [_infoForTV setSectionName:[@"Worker " stringByAppendingString:key] AtIndex:currentSection];
            
            if([[worker allKeys] containsObject:@"hashrate"]){
                [_infoForTV setLabel:@"Hashrate" inSection:currentSection];
                [_infoForTV setInfo:[[worker valueForKey:@"hashrate"] string] inSection:0];
            }
            
            if([[worker allKeys] containsObject:@"alive"]){
                if([[worker valueForKey:@"alive"] intValue] == 0)
                [_infoForTV setInfo:@"NO" inSection:currentSection];
                else
                    [_infoForTV setInfo:@"YES" inSection:currentSection];
                
                [_infoForTV setLabel:@"Worker alive?" inSection:currentSection];

            }
            
            if([[worker allKeys] containsObject:@"last_checkin"]){
                [_infoForTV setInfo:[[[worker valueForKey:@"last_checkin"] valueForKey:@"date"] string] inSection:currentSection];
                [_infoForTV setLabel:@"Last time alive" inSection:currentSection];
            }
            
            currentSection ++;
        }
    }
    
}
@end
