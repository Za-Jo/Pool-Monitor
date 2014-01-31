//
//  PMDataDownloaderFormatter.h
//  Pool Monitor
//
//  Created by Jonathan Duss on 29.01.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Pool.h"

@interface PMDataDownloaderFormatterManager : NSObject
- (void)reload;
-(void)loadData;
-(void)formatData:(NSData *)data;
@property (nonatomic, strong) NSMutableArray *arraySectionWithArrayInfo;
@property (nonatomic, strong) NSMutableArray *arraySectionName;
@property (nonatomic, strong) NSMutableArray *arraySectionWithArrayLabel;
@property (nonatomic, strong) Pool *pool;


@end
