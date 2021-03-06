//
//  PMPoolTVC.h
//  Pool Monitor
//
//  Created by Jonathan Duss on 23.01.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//


/*
 ================================================================================================================
PMPoolTVC
 ================================================================================================================
Manage the rootview: a TVC showing the pools added by the user
 ================================================================================================================
 */

#import <UIKit/UIKit.h>
#import "iAd/ADBannerView.h"

@interface PMPoolTVC : UIViewController <NSFetchedResultsControllerDelegate, UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource, ADBannerViewDelegate>

@end
