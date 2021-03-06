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
#import "GAI.h"
#import "GAIFields.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"

#define BUTTON_SHOW_MORE_LABEL @"Show more information"
#define BUTTON_SHOW_BASIC_LABEL @"Show basic information"


@interface PMPoolInfoTVC ()
- (IBAction)reload:(id)sender;
-(void)loadData;
@property (nonatomic, strong) MBProgressHUDOnTop *progressHUD;
@property (nonatomic, strong) PMInfoFormattedForTV *infoToShow;
@property (nonatomic, strong) PMDataDownloaderManager *dm;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *showDensityInformationButton;
-(void)updateButtonshowInformationDensity;

@end

@implementation PMPoolInfoTVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super init];
    //self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Google analytics stuff
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName
                                       value:@"Pool view"];
    
    // Send the screen view.
    [[GAI sharedInstance].defaultTracker
     send:[[GAIDictionaryBuilder createAppView] build]];
    _showDensityInformationButton.enabled = NO;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = _pool.name;
    self.navigationController.toolbarHidden = NO;
    [self updateButtonshowInformationDensity];

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


//###########################################################
- (IBAction)reload:(id)sender {
    [self loadData];
}

-(void)updateButtonshowInformationDensity
{
    if([[[NSUserDefaults standardUserDefaults] stringForKey:SETTING_INFO_SHOWN_KEY] isEqualToString:SETTING_INFO_SHOWN_BASIC])
    {
        _showDensityInformationButton.title = @"Show more information";

    }
    else
    {
        _showDensityInformationButton.title = @"Show less information";
    }
    
}


//###########################################################
- (IBAction)showInformationDentityPressed:(UIBarButtonItem *)sender {
    
    if([[[NSUserDefaults standardUserDefaults] stringForKey:SETTING_INFO_SHOWN_KEY] isEqualToString:SETTING_INFO_SHOWN_BASIC])
    {
        [[NSUserDefaults standardUserDefaults] setObject:SETTING_INFO_SHOWN_ADVANCED forKey:SETTING_INFO_SHOWN_KEY];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:SETTING_INFO_SHOWN_BASIC forKey:SETTING_INFO_SHOWN_KEY];
    }
    [self updateButtonshowInformationDensity];
    [self reload:nil];
}


//###########################################################
-(IBAction)handlePanGesture:(UIPanGestureRecognizer*)sender
{
    DLog(@"HEY HEY HEY");
    [_progressHUD hideProgressAnimationOnTop];
    _progressHUD = nil;
    [_dm cancel];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}


//###########################################################
-(void)loadData
{
    _progressHUD = [[MBProgressHUDOnTop alloc] initOnTop];
    [_progressHUD setMode:MBProgressHUDModeIndeterminate];
    [_progressHUD setLabelText:@"Updating"];
    [_progressHUD setDetailsLabelText:@"Touch to cancel"];
    [_progressHUD setMinShowTime:0.5];
    [_progressHUD showProgressAnimationOnTop];
    [_progressHUD setRemoveFromSuperViewOnHide:YES];
    
    _dm = [[PMDataDownloaderManager alloc] init];
    _dm.delegate = self;
    [_dm downloadData:_pool.apiAddress];
    _infoToShow = nil;
    
    [_progressHUD addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)]];
    
}



-(void)dataDownloadedAndFormatted:(PMInfoFormattedForTV *)informations
{
    _infoToShow = informations;
    [_progressHUD hideProgressAnimationOnTop];
    _progressHUD = nil;
    [self.tableView reloadData];
    _showDensityInformationButton.enabled = YES;
}


-(void)dataNotDownloadedBecauseError:(NSError *)error
{
    [_progressHUD hideProgressAnimationOnTop];
    [self.navigationController popToRootViewControllerAnimated:YES];
    _progressHUD = nil;
    

    
    if([_pool.apiAddress rangeOfString:@"multipool"].location != NSNotFound)
    {
            [[[UIAlertView alloc] initWithTitle:@"Network error" message:@"Please control the api address and your network. If this message appear again, this is certainly because multipool has some problems. =(" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    }
    else
    {
            [[[UIAlertView alloc] initWithTitle:@"Network error" message:@"Unable to get the informations due to a network error or due to a wrong api address" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    }
}




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
    DLog(@"number row in section %ld: %lu", (long)section, (unsigned long)[_infoToShow numberRowInSection:section]);
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
