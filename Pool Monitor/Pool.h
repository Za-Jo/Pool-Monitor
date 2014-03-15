//
//  Pool.h
//  Pool Monitor
//
//  Created by Jonathan Duss on 15.03.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Pool : NSManagedObject

@property (nonatomic, retain) NSString * apiAddress;
@property (nonatomic, retain) NSString * name;

@end
