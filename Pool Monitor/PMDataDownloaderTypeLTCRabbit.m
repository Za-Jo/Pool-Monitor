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
    //get the apikey:
    NSString *pattern = @"(api_key=)(\\w+)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:NULL];
    
    NSTextCheckingResult *result = [regex firstMatchInString:url options:NSMatchingWithTransparentBounds range:NSMakeRange(0, [url length])];
    
    
    NSString *apikey = @"";
    
    if([result numberOfRanges] == 3){
        apikey = [url substringWithRange:[result rangeAtIndex:2]];
        
        DLog(@"API KEY: %@", apikey);
        
        NSString *correctURL = [NSString stringWithFormat:@"https://www.ltcrabbit.com/index.php?page=api&action=getappdata&appname=poolmonitor&appversion=1.2&api_key=%@", apikey];
        
        
        NSURL *urlAddress1 = [NSURL URLWithString:correctURL];
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:urlAddress1];
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
    else
    {
        [_delegate dataNotDownloadedBecauseError:[NSError errorWithDomain:@"Error when parsing the API KEY" code:1 userInfo:nil]];
    }
    
    
    
}

-(void)formatData:(NSData *)data
{
    _data = data;
    
//    _data = nil;
    
    DLog(@"######################\n\n%@", [[NSString alloc] initWithData:_data encoding:NSStringEncodingConversionAllowLossy]);


//    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"ok2"ofType:@"json"];
//    _data = [NSData dataWithContentsOfFile:jsonPath];
    
    
    
    NSError *error;
    NSDictionary *dicGlobal = [NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingAllowFragments error:&error];
    
    DLog(@"*********************************\n\n%@", [[NSString alloc] initWithData:_data encoding:NSStringEncodingConversionAllowLossy]);
    
    
    
    if(error){
        DLog(@"ERROR READING JSON");
        [_delegate dataNotDownloadedBecauseError:error];
    }
    else
    {
        //SECTION 1: general informations
        
        NSUInteger currentSection = 0;
        
        if([[dicGlobal allKeys] containsObject:@"getappdata"]){
            
            NSDictionary *dic = [dicGlobal valueForKey:@"getappdata"];
            
            
            if([[dic allKeys] containsObject:@"user"])
            {
                [_infoForTV addSectionWithName:@"General Information"];
                
                NSDictionary *userStatus = [dic valueForKey:@"user"];
                
                
                if([[userStatus allKeys] containsObject:@"hashrate_scrypt"]){
                    [_infoForTV addLabel:@"Hashrate scrypt" inSection:currentSection];
                    NSString *infoString = [NSString stringWithFormat:@"%@",[userStatus valueForKey:@"hashrate_scrypt"]];
                    [_infoForTV addInfo:infoString inSection:currentSection];
                }
                
                if([[userStatus allKeys] containsObject:@"hashrate_x11"]){
                    [_infoForTV addLabel:@"Hashrate X11" inSection:currentSection];
                    NSString *infoString = [NSString stringWithFormat:@"%@",[userStatus valueForKey:@"hashrate_x11"]];
                    [_infoForTV addInfo:infoString inSection:currentSection];
                }
                
                if([[userStatus allKeys] containsObject:@"balance"]){
                    [_infoForTV addLabel:@"Balance" inSection:currentSection];
                    NSString *infoString = [NSString stringWithFormat:@"%@",[userStatus valueForKey:@"balance"]];
                    [_infoForTV addInfo:infoString inSection:currentSection];
                }
                
                //show exchange in same section
                if([[dic allKeys] containsObject:@"ltc_exchange_rates"])
                {
                    
                    NSDictionary *exchange = [dic valueForKey:@"ltc_exchange_rates"];
                    
                    if([[exchange allKeys] containsObject:@"USD"]){
                        [_infoForTV addLabel:@"LTC-$" inSection:currentSection];
                        NSString *infoString = [NSString stringWithFormat:@"%@",[exchange valueForKey:@"USD"]];
                        [_infoForTV addInfo:infoString inSection:currentSection];
                    }
                    if([[exchange allKeys] containsObject:@"EUR"]){
                        [_infoForTV addLabel:@"LTC-€" inSection:currentSection];
                        NSString *infoString = [NSString stringWithFormat:@"%@",[exchange valueForKey:@"EUR"]];
                        [_infoForTV addInfo:infoString inSection:currentSection];
                    }
                    
                    
                    
                }
                
                currentSection++;
                
            }
            if([[dic allKeys] containsObject:@"worker"])
            {
                NSArray *workers = [dic valueForKey:@"worker"];
                
                for(NSDictionary *worker in workers)
                {
                    
                    if([[worker allKeys] containsObject:@"name"]){
                        [_infoForTV addSectionWithName:[@"Worker " stringByAppendingString:[worker valueForKey:@"name"]]];
                    }
                    else {
                        [_infoForTV addSectionWithName:[NSString stringWithFormat:@"Workers %lu", (unsigned long)currentSection]];
                    }
                    
                    if([[worker allKeys] containsObject:@"hashrate"]){
                        [_infoForTV addLabel:@"Hashrate" inSection:currentSection];
                        NSString *infoString = [NSString stringWithFormat:@"%@",[worker valueForKey:@"hashrate"]];
                        [_infoForTV addInfo:infoString inSection:currentSection];
                    }
                    
                    if([[worker allKeys] containsObject:@"algo"]){
                        [_infoForTV addLabel:@"Algorithm" inSection:currentSection];
                        NSString *infoString = [NSString stringWithFormat:@"%@",[worker valueForKey:@"algo"]];
                        [_infoForTV addInfo:infoString inSection:currentSection];
                    }
                    
                    if([[worker allKeys] containsObject:@"active"]){
                        BOOL active =[[worker valueForKey:@"active"] intValue];
                        
                        [_infoForTV addLabel:@"Active ?" inSection:currentSection];
                        [_infoForTV addInfo:active ? @"YES" : @"NO" inSection:currentSection];
                        if(active == false){
                            [_infoForTV removeSection:currentSection];
                            currentSection --;
                        }
                    }
                    
                    //go to next section
                    currentSection++;
                }
                
            }
        }
    }
    
    
}
@end
