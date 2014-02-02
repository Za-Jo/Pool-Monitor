//
//  PMInfoFormattedForTV.m
//  Pool Monitor
//
//  Created by Jonathan Duss on 31.01.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

#import "PMInfoFormattedForTV.h"


@interface PMInfoFormattedForTV()

@property (nonatomic, strong) NSMutableArray *infos;
@property (nonatomic, strong) NSMutableArray *labels;
@property (nonatomic, strong) NSMutableArray *sectionNames;


@end

@implementation PMInfoFormattedForTV

-(id)init
{
    self = [super init];
    _infos = [NSMutableArray array];
    _labels = [NSMutableArray array];
    _sectionNames = [NSMutableArray array];

    return self;
}


-(void)setLabel:(NSString *)label AtIndexPath:(NSIndexPath *) path
{
    NSMutableArray *labelsInSection = [_labels objectAtIndex:path.section];
    if(labelsInSection == nil){
        labelsInSection = [NSMutableArray array];
        [_labels insertObject:labelsInSection atIndex:path.section];
    }
    [labelsInSection insertObject:label atIndex:path.row];
}


//============================================================================
//============================================================================

-(void)setInfo:(NSString *)info AtIndexPath:(NSIndexPath *) path
{
    NSMutableArray *infosInSection = [_labels objectAtIndex:path.section];
    if(infosInSection == nil){
        infosInSection = [NSMutableArray array];
        [_labels insertObject:infosInSection atIndex:path.section];
    }
    [infosInSection insertObject:info atIndex:path.row];
}


//============================================================================
//============================================================================

-(void)addLabel:(NSString *)label inSection:(NSUInteger) section
{
    NSMutableArray *labelsInSection = [_labels objectAtIndex:section];
    if(labelsInSection == nil){
        labelsInSection = [NSMutableArray array];
        [_labels insertObject:labelsInSection atIndex:section];
    }
    [labelsInSection addObject:label];
}


//============================================================================
//============================================================================

-(void)addInfo:(NSString *)info inSection:(NSUInteger) section
{
    NSMutableArray *infosInSection = [_infos objectAtIndex:section];
    if(infosInSection == nil){
        infosInSection = [NSMutableArray array];
        [_infos insertObject:infosInSection atIndex:section];
    }
    [infosInSection addObject:info];
}


//============================================================================
//============================================================================

-(void)addSectionWithName:(NSString *)name
{
    [_sectionNames addObject:name];
    [_infos addObject:[NSMutableArray array]];
    [_labels addObject:[NSMutableArray array]];
}


//============================================================================
//============================================================================

-(NSString *)labelAtIndexPath:(NSIndexPath *) path
{
    return [[_labels objectAtIndex:path.section] objectAtIndex:path.row];
}


-(NSString *)infoAtIndexPath:(NSIndexPath *) path
{
    return [[_infos objectAtIndex:path.section] objectAtIndex:path.row];

}

-(NSString *)sectionNameAtIndex:(NSUInteger) index
{
    return [_sectionNames objectAtIndex:index];
}


-(NSUInteger)numberSection
{
    return [_sectionNames count];
}


-(NSUInteger)numberRowInSection:(NSUInteger)section
{
    NSMutableArray *array = [_infos objectAtIndex:section];
    return [array count];
}


@end
