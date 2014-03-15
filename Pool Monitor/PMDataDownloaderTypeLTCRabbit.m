//
//  PMDataDownloaderTypeLTCRabbit.m
//  Pool Monitor
//
//  Created by Jonathan Duss on 01.02.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

#import "PMDataDownloaderTypeLTCRabbit.h"


@interface PMDataDownloaderTypeLTCRabbit ()
@property (nonatomic) BOOL stopRequested;
@end



@implementation PMDataDownloaderTypeLTCRabbit


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
    NSURL *urlAddress1 = [NSURL URLWithString:url];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:urlAddress1];
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue currentQueue]completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if(_stopRequested == NO){
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
                  
                  //At the end, we notify the delegate:
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
            [_infoForTV addSectionWithName:@"General Information"];
            
            NSDictionary *userStatus = [dic valueForKey:@"getuserstatus"];

            
            if([[userStatus allKeys] containsObject:@"hashrate"]){
                [_infoForTV addLabel:@"Hashrate" inSection:0];
                NSString *infoString = [NSString stringWithFormat:@"%@",[userStatus valueForKey:@"hashrate"]];
                [_infoForTV addInfo:infoString inSection:0];
            }
            
            if([[userStatus allKeys] containsObject:@"sharerate"]){
                [_infoForTV addLabel:@"Sharerate" inSection:0];
                NSString *infoString = [NSString stringWithFormat:@"%@",[userStatus valueForKey:@"sharerate"]];
                [_infoForTV addInfo:infoString inSection:0];
            }
            
            if([[userStatus allKeys] containsObject:@"balance"]){
                [_infoForTV addLabel:@"Balance" inSection:0];
                NSString *infoString = [NSString stringWithFormat:@"%@",[userStatus valueForKey:@"balance"]];
                [_infoForTV addInfo:infoString inSection:0];
            }
            
        }
        else if([[dic allKeys] containsObject:@"getuserworkers"])
        {
            NSArray *workers = [dic valueForKey:@"getuserworkers"];
            
            NSUInteger currentSection = 1;
            
            for(NSDictionary *worker in workers)
            {
                
                if([[worker allKeys] containsObject:@"username"]){
                    [_infoForTV addSectionWithName:[@"Worker " stringByAppendingString:[worker valueForKey:@"username"]]];
                }
                else {
                    [_infoForTV addSectionWithName:[NSString stringWithFormat:@"Workers %d", currentSection]];
                }
                
                if([[worker allKeys] containsObject:@"hasrate"]){
                    [_infoForTV addLabel:@"Hashrate" inSection:currentSection];
                    NSString *infoString = [NSString stringWithFormat:@"%@",[worker valueForKey:@"hashrate"]];
                    [_infoForTV addInfo:infoString inSection:currentSection];
                }
                
                if([[worker allKeys] containsObject:@"active"]){
                    BOOL active =[[worker valueForKey:@"active"] intValue];
                    
                    [_infoForTV addLabel:@"Active ?" inSection:currentSection];
                    [_infoForTV addInfo:active ? @"YES" : @"NO" inSection:currentSection];
                }
                
                //go to next section
                currentSection++;
            }
            
        }
    }
    
    
}
@end
