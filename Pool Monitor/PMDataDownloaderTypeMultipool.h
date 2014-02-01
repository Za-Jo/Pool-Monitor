//
//  PMDDFType1.h
//  Pool Monitor
//
//  Created by Jonathan Duss on 31.01.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PMDataDownloaderProtocol.h"
#import "PMInfoFormattedForTV.h"

@interface PMDataDownloaderTypeMultipool : NSObject <PMDataDownloaderProtocol>

@property (nonatomic, strong) id<PMDataDownloaderDelegate> delegate;
@property (nonatomic, strong) PMInfoFormattedForTV *infoForTV;
@property (nonatomic, strong) NSData *data;

@end
