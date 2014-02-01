//
//  PMDataDownloaderTypeLTCRabbit.m
//  Pool Monitor
//
//  Created by Jonathan Duss on 01.02.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

#import "PMDataDownloaderTypeLTCRabbit.h"

@implementation PMDataDownloaderTypeLTCRabbit

-(void)downloadData:(NSString *) url
{
    NSURL *urlAddress1 = [NSURL URLWithString:url];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:urlAddress1];
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
         
         
         
         //SECOND REQUEST: WORKER INFO
         NSURL *urlAddress2 = [NSURL URLWithString:[url stringByReplacingOccurrencesOfString:@"getuserstatus" withString:@"getuserworkers"]];
         
         NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:urlAddress2];
         
         [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue currentQueue]completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
          {
              
              if ([data length] >0 && error == nil)
              {
                  DLog(@"%@",[[NSString alloc] initWithData:data encoding:0]);
                  [self formatData:data];
                  // DO YOUR WORK HERE
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
        
        if([[dic allKeys] containsObject:@"getuserstatus"])
        {
            [_infoForTV setSectionName:@"General Infos" AtIndex:0];
            
            NSDictionary *userStatus = [dic valueForKey:@"getuserstatus"];

            
            if([[userStatus allKeys] containsObject:@"hashrate"]){
                [_infoForTV setLabel:@"Hashrate" inSection:0];
                [_infoForTV setInfo:[[userStatus valueForKey:@"hashrate"] string] inSection:0];
            }
            
            if([[userStatus allKeys] containsObject:@"sharerate"]){
                [_infoForTV setLabel:@"Sharerate" inSection:0];
                [_infoForTV setInfo:[[userStatus valueForKey:@"sharerate"] string] inSection:0];
            }
            
            if([[userStatus allKeys] containsObject:@"balance"]){
                [_infoForTV setLabel:@"Balance" inSection:0];
                [_infoForTV setInfo:[[userStatus valueForKey:@"balance"] string] inSection:0];
            }
            
        }
        else if([[dic allKeys] containsObject:@"getuserworkers"])
        {
            NSArray *workers = [dic valueForKey:@"getuserworkers"];
            
            NSUInteger currentSection = 1;
            
            for(NSDictionary *worker in workers)
            {
                
                
                if([[worker allKeys] containsObject:@"username"]){
                    [_infoForTV setSectionName:[@"Worker " stringByAppendingString:[worker valueForKey:@"username"]] AtIndex:currentSection];
                }
                else {
                    [_infoForTV setSectionName:[NSString stringWithFormat:@"Workers %d", currentSection] AtIndex:currentSection];
                }
                
                if([[worker allKeys] containsObject:@"hasrate"]){
                    [_infoForTV setLabel:@"Hashrate" inSection:1];
                    [_infoForTV setInfo:[[worker valueForKey:@"hashrate"] string] inSection:1];
                }
                
                if([[worker allKeys] containsObject:@"active"]){
                    BOOL active =[[worker valueForKey:@"active"] intValue];
                    
                    [_infoForTV setLabel:@"Active ?" inSection:currentSection];
                    [_infoForTV setInfo:active ? @"YES" : @"NO" inSection:1];
                }
                
                //go to next section
                currentSection++;
            }
            
        }
    }
    
    
}
@end
