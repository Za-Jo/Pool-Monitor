//
//  PMPoolInfoTVC.m
//  Pool Monitor
//
//  Created by Jonathan Duss on 23.01.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

#import "PMPoolInfoMultipoolTVC.h"
#import "MBProgressHUDOnTop.h"

@interface PMPoolInfoMultipoolTVC ()
- (IBAction)reload:(id)sender;
-(void)loadData;
-(void)formatData:(NSData *)data;
@property (nonatomic, strong) MBProgressHUDOnTop *progressHUD;
@property (nonatomic, strong) NSMutableArray *arraySectionWithArrayInfo;
@property (nonatomic, strong) NSMutableArray *arraySectionName;
@property (nonatomic, strong) NSMutableArray *arraySectionWithArrayLabel;

@end

@implementation PMPoolInfoMultipoolTVC

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
    
    NSURL *url = [NSURL URLWithString:[_pool.apiAddress stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setTimeoutInterval:60];
    
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue currentQueue]completionHandler:^(NSURLResponse *response,
                                                                                                          NSData *data,
                                                                                                          NSError *error)
     {
         
         if ([data length] >0 && error == nil)
         {
             DLog(@"%@",[[NSString alloc] initWithData:data encoding:0]);
             [self formatData:data];
             // DO YOUR WORK HERE
             
         }
         else if ([data length] == 0 && error == nil)
         {
             DLog(@"Nothing was downloaded.");
             [_progressHUD hideProgressAnimationOnTop];
             _progressHUD = nil;
             [[[UIAlertView alloc] initWithTitle:@"Network error" message:@"Unable to get the informations due to a network error or due to a wrong api address" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
             [self.navigationController popViewControllerAnimated:YES];
             
         }
         else if (error != nil){
             DLog(@"Error = %@", error);
             [_progressHUD hideProgressAnimationOnTop];
             _progressHUD = nil;
             [[[UIAlertView alloc] initWithTitle:@"Network error" message:@"Unable to get the informations due to a network error or due to a wrong api address" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
             [self.navigationController popViewControllerAnimated:YES];
         }
         
     }];
    

}



-(void)formatData:(NSData *)data
{
    NSError *error;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    _arraySectionName = [NSMutableArray array];
    _arraySectionWithArrayInfo = [NSMutableArray array];
    _arraySectionWithArrayLabel = [NSMutableArray array];
    

    
    if(error){
        DLog(@"ERROR READING JSON");
    }
    else
    {
        
        //SECTION 1: general informations
        NSMutableArray *infoSec1 = [NSMutableArray array];
        NSMutableArray *labelSec1 = [NSMutableArray array];
        
        [infoSec1 addObject:_pool.name];
        [labelSec1 addObject:@"Name"];
        
        
        [_arraySectionName addObject:@"General Informations"];
        
        //section 1: currencies now + hashrate
        NSDictionary *currencies = [NSDictionary dictionary];
        BOOL active = NO;
        
        if([[dic allKeys] containsObject:@"currency"])
        {
            currencies = [dic valueForKey:@"currency"];
            NSArray *allCurrenciesKeys = [currencies allKeys];
            
            for(NSString *key in allCurrenciesKeys)
            {
                if([[[currencies valueForKey:key] valueForKey:@"hashrate"] intValue] != 0){
                    [labelSec1 addObject:[NSString stringWithFormat:@"Hashrate [%@]", key]];
                    [infoSec1 addObject:[[currencies valueForKey:key] valueForKey:@"hashrate"]];
                    active = YES;
                }
            }
        }
        
        [labelSec1 addObject:@"Active?"];
        [infoSec1 addObject: active ? @"YES" : @"NO"];
        
        
        if([[dic allKeys] containsObject:@"currency"])
        {
            currencies = [dic valueForKey:@"currency"];
            NSArray *allCurrenciesKeys = [currencies allKeys];
            
            for(NSString *key in allCurrenciesKeys)
            {
                NSString *amount = [NSString stringWithFormat: @"%.6f", [[[currencies valueForKey:key] valueForKey:@"confirmed_rewards"] floatValue] ];
                if([amount floatValue] > 0.f)
                {
                    [labelSec1 addObject:key];
                    [infoSec1 addObject:amount];
                }
            }
        }
    
    
        [_arraySectionWithArrayInfo addObject:infoSec1];
        [_arraySectionWithArrayLabel addObject:labelSec1];
    }
    
        
    
    DLog(@"HIDE");
    [self.tableView reloadData];
    [_progressHUD hideProgressAnimationOnTop];
    _progressHUD = nil;
    
}

//#pragma mark NSURLConnection Delegate Methods
//
//- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
//    // A response has been received, this is where we initialize the instance var you created
//    // so that we can append data to it in the didReceiveData method
//    // Furthermore, this method is called each time there is a redirect so reinitializing it
//    // also serves to clear it
//    _responseData = [[NSMutableData alloc] init];
//}
//
//- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
//    // Append the new data to the instance variable you declared
//    [_responseData appendData:data];
//}
//
//- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
//                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
//    // Return nil to indicate not necessary to store a cached response for this connection
//    return nil;
//}
//
//- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
//    // The request is complete and data has been received
//    // You can parse the stuff in your instance variable now
//
//}
//
//- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
//    // The request has failed for some reason!
//    // Check the error var
//}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_arraySectionName count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [_arraySectionName objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_arraySectionWithArrayInfo objectAtIndex:section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"info cell" forIndexPath:indexPath];
    
    // Configure the cell...
    UILabel *label = [cell viewWithTag:1000];
    UILabel *info = [cell viewWithTag:1001];
    
    [label setText:[[_arraySectionWithArrayLabel objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
    [info setText:[NSString stringWithFormat:@"%@", [[_arraySectionWithArrayInfo objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]]];
    
    
    
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
