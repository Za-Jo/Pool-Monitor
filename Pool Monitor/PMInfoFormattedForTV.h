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
-(NSString *)sectionNameAtIndex:(NSUInteger) index;


-(void)addLabel:(NSString *)label inSection:(NSUInteger) section;
-(void)addInfo:(NSString *)info inSection:(NSUInteger) section;

-(void)setLabel:(NSString *)label AtIndexPath:(NSIndexPath *) path;
-(void)setInfo:(NSString *)info AtIndexPath:(NSIndexPath *) path;
-(void)addSectionWithName:(NSString *)name;

-(NSUInteger)numberSection;
-(NSUInteger)numberRowInSection:(NSUInteger)section;


@end
