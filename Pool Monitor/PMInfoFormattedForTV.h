//
//  PMInfoFormattedForTV.h
//  Pool Monitor
//
//  Created by Jonathan Duss on 31.01.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PMInfoFormattedForTV : NSObject

-(NSString *)labelAtIndexPath:(NSIndexPath *) path;
-(NSString *)infoAtIndexPath:(NSIndexPath *) path;
-(NSString *)sectionNameAtIndex:(NSInteger) index;


-(void)setLabel:(NSString *)label AtIndexPath:(NSIndexPath *) path;
-(void)setInfo:(NSString *)info AtIndexPath:(NSIndexPath *) path;
-(void)setSectionName:(NSString *)name AtIndex:(NSInteger) index;


@end
