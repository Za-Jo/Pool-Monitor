//
//  PMPoolInfoTVC.m
//  Pool Monitor
//
//  Created by Jonathan Duss on 23.01.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

#import "PMPoolInfoTVC.h"
#import "MBProgressHUDOnTop.h"
#import "PMDataDownloaderManager.h"

@interface PMPoolInfoTVC ()
- (IBAction)reload:(id)sender;
-(void)loadData;
-(void)formatData:(NSData *)data;
@property (nonatomic, strong) MBProgressHUDOnTop *progressHUD;
@property (nonatomic, strong) PMInfoFormattedForTV *infoToShow;

@end

@implementation PMPoolInfoTVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = _pool.name;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)reload:(id)sender {
    [self loadData];
}

-(void)loadData
{
    _progressHUD = [[MBProgressHUDOnTop alloc] initOnTop];
    [_progressHUD setMode:MBProgressHUDModeIndeterminate];
    [_progressHUD setLabelText:@"Updating"];
    [_progressHUD setMinShowTime:1];
    [_progressHUD showProgressAnimationOnTop];
    [_progressHUD setRemoveFromSuperViewOnHide:YES];
    
    PMDataDownloaderManager *dm = [[PMDataDownloaderManager alloc] init];
    dm.delegate = self;
    [dm downloadData:_pool.apiAddress];
    _infoToShow = nil;
}



-(void)dataDownloadedAndFormatted:(PMInfoFormattedForTV *)informations
{
    _infoToShow = informations;
    [_progressHUD hideProgressAnimationOnTop];
    _progressHUD = nil;
    [self.tableView reloadData];
}


-(void)dataNotDownloadedBecauseError:(NSError *)error
{
    [_progressHUD hideProgressAnimationOnTop];
    [self.navigationController popToRootViewControllerAnimated:YES];
    _progressHUD = nil;
    
    [[[UIAlertView alloc] initWithTitle:@"Network error" message:@"Unable to get the informations due to a network error or due to a wrong api address" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
}

//-(void)loadData
//{
//    _progressHUD = [[MBProgressHUDOnTop alloc] initOnTop];
//    [_progressHUD setMode:MBProgressHUDModeIndeterminate];
//    [_progressHUD setLabelText:@"Updating"];
//    [_progressHUD setMinShowTime:1];
//    [_progressHUD showProgressAnimationOnTop];
//    [_progressHUD setRemoveFromSuperViewOnHide:YES];
//    
//    NSURL *url = [NSURL URLWithString:_pool.apiAddress];
//    
//    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
//    
//    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue currentQueue]completionHandler:^(NSURLResponse *response,
//                                                                                                          NSData *data,
//                                                                                                          NSError *error)
//     {
//         if ([data length] >0 && error == nil)
//         {
//             DLog(@"%@",[[NSString alloc] initWithData:data encoding:0]);
//             [self formatData:data];
//             // DO YOUR WORK HERE
//         }
//         else if ([data length] == 0 && error == nil)
//         {
//             DLog(@"Nothing was downloaded.");
//             [_progressHUD hideProgressAnimationOnTop];
//             _progressHUD = nil;
//             [[[UIAlertView alloc] initWithTitle:@"Network error" message:@"Unable to get the informations due to a network error or due to a wrong api address" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
//             [self.navigationController popViewControllerAnimated:YES];
//             
//         }
//         else if (error != nil){
//             DLog(@"Error = %@", error);
//             [_progressHUD hideProgressAnimationOnTop];
//             _progressHUD = nil;
//             [[[UIAlertView alloc] initWithTitle:@"Network error" message:@"Unable to get the informations due to a network error or due to a wrong api address" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
//             [self.navigationController popViewControllerAnimated:YES];
//         }
//
//         
//     }];
//}
//
//
//
//-(void)formatData:(NSData *)data
//{
//    NSError *error;
//    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
//    
//    _arraySectionName = [NSMutableArray array];
//    _arraySectionWithArrayInfo = [NSMutableArray array];
//    _arraySectionWithArrayLabel = [NSMutableArray array];
//    
//    if(error){
//        DLog(@"ERROR READING JSON");
//    }
//    else
//    {
//        //SECTION 1: general informations
//        NSMutableArray *infoSec1 = [NSMutableArray array];
//        NSMutableArray *labelSec1 = [NSMutableArray array];
//        
//        [infoSec1 addObject:_pool.name];
//        [labelSec1 addObject:@"Name"];
//        
//        
//        [_arraySectionName addObject:@"General Informations"];
//        
//        if([[dic allKeys] containsObject:@"hashrate"]){
//            [infoSec1 addObject:[dic valueForKey:@"hashrate"]];
//            [labelSec1 addObject:@"Hashrate"];
//        }
//        
//        if([[dic allKeys] containsObject:@"active_workers"]){
//            [infoSec1 addObject:[dic valueForKey:@"active_workers"]];
//            [labelSec1 addObject:@"Active workers"];
//        }
//        
//        if([[dic allKeys] containsObject:@"balance"]){
//            [infoSec1 addObject:[dic valueForKey:@"balance"]];
//            [labelSec1 addObject:@"Balance"];
//        }
//        else if([[dic allKeys] containsObject:@"confirmed_rewards"]){
//            [infoSec1 addObject:[dic valueForKey:@"confirmed_rewards"]];
//            [labelSec1 addObject:@"Balance"];
//        }
//        
//        [_arraySectionWithArrayInfo addObject:infoSec1];
//        [_arraySectionWithArrayLabel addObject:labelSec1];
//        
//        
//        //OTHER SECTION (dynamic)
//        NSDictionary *workers = [dic valueForKey:@"workers"];
//        NSArray *workersKeys = [workers allKeys];
//        
//        //enumerate over each workers
//        for (NSString *key in workersKeys) {
//            NSDictionary *worker = [workers valueForKey:key]; //current worker we are reading info
//            
//            NSMutableArray *workerInfoSec = [NSMutableArray array]; //formated info
//            NSMutableArray *workerLabelSec = [NSMutableArray array]; //formated info
//            
//            
//            
//            [_arraySectionName addObject:[@"Worker " stringByAppendingString:key]];
//            
//            if([[worker allKeys] containsObject:@"hashrate"]){
//                [workerInfoSec addObject:[worker valueForKey:@"hashrate"]];
//                [workerLabelSec addObject:@"Hashrate"];
//            }
//            
//            if([[worker allKeys] containsObject:@"alive"]){
//                if([[worker valueForKey:@"alive"] intValue] == 0)
//                    [workerInfoSec addObject:@"NO"];
//                else
//                    [workerInfoSec addObject:@"YES"];
//
//                [workerLabelSec addObject:@"Worker alive?"];
//            }
//            
//            if([[worker allKeys] containsObject:@"last_checkin"]){
//                [workerInfoSec addObject:[[worker valueForKey:@"last_checkin"] valueForKey:@"date"]];
//                [workerLabelSec addObject:@"Last Time alive"];
//            }
//            
//            [_arraySectionWithArrayInfo addObject:workerInfoSec];
//            [_arraySectionWithArrayLabel addObject:workerLabelSec];
//        }
//    }
//    
//    DLog(@"HIDE");
//    [self.tableView reloadData];
//    [_progressHUD hideProgressAnimationOnTop];
//    _progressHUD = nil;
//    
//}






#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_infoToShow numberSection];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [_infoToShow sectionNameAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DLog(@"number row in section %d: %d", section, [_infoToShow numberRowInSection:section]);
    return [_infoToShow numberRowInSection:section];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"info cell" forIndexPath:indexPath];
    
    // Configure the cell...
    UILabel *label = (UILabel *)[cell viewWithTag:1000];
    UILabel *info = (UILabel *)[cell viewWithTag:1001];
    
    [label setText:[NSString stringWithFormat:@"%@", [_infoToShow labelAtIndexPath:indexPath]]];
    [info setText:[NSString stringWithFormat:@"%@",[_infoToShow infoAtIndexPath:indexPath]]];
    
    
    return cell;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
