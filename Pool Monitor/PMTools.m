//
//  PMTools.m
//  Pool Monitor
//
//  Created by Jonathan Duss on 15.03.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

#import "PMTools.h"

@implementation PMTools


+(NSString *)stringWithLimitStrNumTo:(int)nbDecimals for:(NSString *)string
{
    double n = [string doubleValue];
    
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setMaximumFractionDigits:nbDecimals];
    [fmt setMinimumIntegerDigits:1];
    
    return [fmt stringFromNumber:[NSNumber numberWithDouble:n]];
}


@end
