//
//  PMDataDownloaderFormatter.m
//  Pool Monitor
//
//  Created by Jonathan Duss on 29.01.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

#import "PMDataDownloaderFormatterManager.h"
#import "Pool.h"

@implementation PMDataDownloaderFormatterManager

-(void)loadData
{
   
    if(([_pool.apiAddress rangeOfString:@"guardian"].location != NSNotFound)
       || ([_pool.apiAddress rangeOfString:@"wemineltc"].location != NSNotFound) )
    {
        
    }
    else if([_pool.apiAddress rangeOfString:@"multipool"].location != NSNotFound)
    {
        
    }
    else
    {
        //Generalbn
    }

}



-(void)formatData:(NSData *)data
{
    NSError *error;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    _arraySectionName = [NSMutableArray array];
    _arraySectionWithArrayInfo = [NSMutableArray array];
    _arraySectionWithArrayLabel = [NSMutableArray array];
    
    if(error){
        DLog(@"ERROR READING JSON");
    }
    else
    {
        //SECTION 1: general informations
        NSMutableArray *infoSec1 = [NSMutableArray array];
        NSMutableArray *labelSec1 = [NSMutableArray array];
        
        [infoSec1 addObject:_pool.name];
        [labelSec1 addObject:@"Name"];
        
        
        [_arraySectionName addObject:@"General Informations"];
        
        if([[dic allKeys] containsObject:@"hashrate"]){
            [infoSec1 addObject:[dic valueForKey:@"hashrate"]];
            [labelSec1 addObject:@"Hashrate"];
        }
        
        if([[dic allKeys] containsObject:@"active_workers"]){
            [infoSec1 addObject:[dic valueForKey:@"active_workers"]];
            [labelSec1 addObject:@"Active workers"];
        }
        
        if([[dic allKeys] containsObject:@"balance"]){
            [infoSec1 addObject:[dic valueForKey:@"balance"]];
            [labelSec1 addObject:@"Balance"];
        }
        else if([[dic allKeys] containsObject:@"confirmed_rewards"]){
            [infoSec1 addObject:[dic valueForKey:@"confirmed_rewards"]];
            [labelSec1 addObject:@"Balance"];
        }
        
        [_arraySectionWithArrayInfo addObject:infoSec1];
        [_arraySectionWithArrayLabel addObject:labelSec1];
        
        
        //OTHER SECTION (dynamic)
        NSDictionary *workers = [dic valueForKey:@"workers"];
        NSArray *workersKeys = [workers allKeys];
        
        //enumerate over each workers
        for (NSString *key in workersKeys) {
            NSDictionary *worker = [workers valueForKey:key]; //current worker we are reading info
            
            NSMutableArray *workerInfoSec = [NSMutableArray array]; //formated info
            NSMutableArray *workerLabelSec = [NSMutableArray array]; //formated info
            
            
            
            [_arraySectionName addObject:[@"Worker " stringByAppendingString:key]];
            
            if([[worker allKeys] containsObject:@"hashrate"]){
                [workerInfoSec addObject:[worker valueForKey:@"hashrate"]];
                [workerLabelSec addObject:@"Hashrate"];
            }
            
            if([[worker allKeys] containsObject:@"alive"]){
                if([[worker valueForKey:@"alive"] intValue] == 0)
                    [workerInfoSec addObject:@"NO"];
                else
                    [workerInfoSec addObject:@"YES"];
                
                [workerLabelSec addObject:@"Worker alive?"];
            }
            
            if([[worker allKeys] containsObject:@"last_checkin"]){
                [workerInfoSec addObject:[[worker valueForKey:@"last_checkin"] valueForKey:@"date"]];
                [workerLabelSec addObject:@"Last Time alive"];
            }
            
            [_arraySectionWithArrayInfo addObject:workerInfoSec];
            [_arraySectionWithArrayLabel addObject:workerLabelSec];
        }
    }
    
    DLog(@"HIDE");
    [self.tableView reloadData];
    [_progressHUD hideProgressAnimationOnTop];
    _progressHUD = nil;
    
}


@end
