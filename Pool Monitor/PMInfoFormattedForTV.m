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


-(void)setInfo:(NSString *)info AtIndexPath:(NSIndexPath *) path
{
    NSMutableArray *infosInSection = [_labels objectAtIndex:path.section];
    if(infosInSection == nil){
        infosInSection = [NSMutableArray array];
        [_labels insertObject:infosInSection atIndex:path.section];
    }
    [infosInSection insertObject:info atIndex:path.row];
}


-(void)setSectionName:(NSString *)name AtIndex:(NSInteger) index
{
    [_sectionNames insertObject:name atIndex:index];
}


-(NSString *)labelAtIndexPath:(NSIndexPath *) path
{
    return [[_labels objectAtIndex:path.section] objectAtIndex:path.row];
}


-(NSString *)infoAtIndexPath:(NSIndexPath *) path
{
    return [[_infos objectAtIndex:path.section] objectAtIndex:path.row];

}

-(NSString *)sectionNameAtIndex:(NSInteger) index
{
    return [_sectionNames objectAtIndex:index];
}

@end
