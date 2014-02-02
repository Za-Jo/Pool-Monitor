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
    _infoForTV = [[PMInfoFormattedForTV alloc] init];

    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:urlAddress];
    
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
        [_infoForTV addSectionWithName:@"General Informations"];
        
        
        if([[dic allKeys] containsObject:@"hashrate"]){
            [_infoForTV addLabel:@"Hashrate" inSection:0];
            [_infoForTV addInfo:[dic valueForKey:@"hashrate"] inSection:0];
        }
        
        if([[dic allKeys] containsObject:@"active_workers"]){
            [_infoForTV addLabel:@"Active workers" inSection:0];
            [_infoForTV addInfo:[dic valueForKey:@"active_workers"] inSection:0];
        }
        
        if([[dic allKeys] containsObject:@"balance"]){
            [_infoForTV addLabel:@"Balance" inSection:0];
            [_infoForTV addInfo:[[dic valueForKey:@"balance"] stringValue] inSection:0];
        }
        else if([[dic allKeys] containsObject:@"confirmed_rewards"]){
            [_infoForTV addLabel:@"Balance" inSection:0];
            [_infoForTV addInfo:[dic valueForKey:@"confirmed_rewards"] inSection:0];
        }
        
        
        
        //OTHER SECTION (dynamic)
        NSDictionary *workers = [dic valueForKey:@"workers"];
        NSArray *workersKeys = [workers allKeys];
        NSUInteger currentSection = 1;
        
        //enumerate over each workers
        for (NSString *key in workersKeys) {
            NSDictionary *worker = [workers valueForKey:key]; //current worker we are reading info
            
            
            [_infoForTV addSectionWithName:[@"Worker " stringByAppendingString:key]];
            
            if([[worker allKeys] containsObject:@"hashrate"]){
                [_infoForTV addLabel:@"Hashrate" inSection:currentSection];
                [_infoForTV addInfo:[worker valueForKey:@"hashrate"]inSection:currentSection];
            }
            
            if([[worker allKeys] containsObject:@"alive"]){
                if([[worker valueForKey:@"alive"] intValue] == 0)
                    [_infoForTV addInfo:@"NO" inSection:currentSection];
                else
                    [_infoForTV addInfo:@"YES" inSection:currentSection];
                
                [_infoForTV addLabel:@"Worker alive?" inSection:currentSection];

            }
            
            if([[worker allKeys] containsObject:@"last_checkin"]){
                [_infoForTV addInfo:[[worker valueForKey:@"last_checkin"] valueForKey:@"date"] inSection:currentSection];
                [_infoForTV addLabel:@"Last time alive" inSection:currentSection];
            }
            
            currentSection ++;
        }
        
    }
    
}
@end
