//
//  PMPoolTVC.m
//  Pool Monitor
//
//  Created by Jonathan Duss on 23.01.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

#import "PMPoolTVC.h"
#import "PMAppDelegate.h"
#import "Pool.h"
#import "PMPoolInfoTVC.h"

@interface PMPoolTVC ()
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultController;
@property (nonatomic, weak) NSManagedObjectContext *context;
@property (nonatomic, weak) Pool *editedPool;
@property (nonatomic, weak) PMAppDelegate *appDelegate;
@end

@implementation PMPoolTVC


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

//===================================================================================================
//===================================================================================================
- (void)viewDidLoad
{
    [super viewDidLoad];

    _appDelegate = [[UIApplication sharedApplication] delegate];
    _context = [_appDelegate managedObjectContext];
    [[self fetchedResultController] performFetch:nil];
    [self.tableView setAllowsSelectionDuringEditing:YES];
    [self.tableView setAllowsSelection:YES];
    
    self.navigationController.toolbarHidden = NO;


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [NSFetchedResultsController deleteCacheWithName:nil];
    _fetchedResultController.delegate = nil;
    _fetchedResultController = nil;
    // Dispose of any resources that can be recreated.
}


//===================================================================================================
//===================================================================================================
- (IBAction)editPoolsList:(id)sender {
    [self.tableView setEditing:![self.tableView isEditing] animated:YES];
}


//===================================================================================================
//===================================================================================================
- (IBAction)addPool:(id)sender {
    UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Add a pool" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
    [av setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    [[av textFieldAtIndex: 0] setPlaceholder:@"Name"];
    
    [[av textFieldAtIndex:1] setSecureTextEntry:NO];
    [[av textFieldAtIndex:1] setPlaceholder:@"API address"];
    
    [av show];
}

//===================================================================================================
//===================================================================================================
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(self.tableView.editing)
    {
        if(buttonIndex == 1)
        {
            _editedPool.name = [[alertView textFieldAtIndex:0] text];
            _editedPool.apiAddress = [[alertView textFieldAtIndex:1] text];
        }
        _editedPool = nil;
    }
    else
    {
        Pool *newPool = [NSEntityDescription insertNewObjectForEntityForName:@"Pool" inManagedObjectContext:_context];
        newPool.name = [[alertView textFieldAtIndex:0] text];
        newPool.apiAddress = [[alertView textFieldAtIndex:1] text];
    }
    [_appDelegate saveContext];
}





#pragma mark - FetchController

//===================================================================================================
//===================================================================================================
-(NSFetchedResultsController *)fetchedResultController
{
    if(!_fetchedResultController){
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Pool"];
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        [request setSortDescriptors:[NSArray arrayWithObject:descriptor]];
        
        _fetchedResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:_context sectionNameKeyPath:nil cacheName:nil ];
        [_fetchedResultController setDelegate:self];
    }
    
    return _fetchedResultController;
}






#pragma mark - Table view data source

//===================================================================================================
//===================================================================================================
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[_fetchedResultController sections] count];
}

//===================================================================================================
//===================================================================================================
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([[_fetchedResultController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    } else
        return 0;
}


//===================================================================================================
//===================================================================================================
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"poolCell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


//===================================================================================================
/*!Configure the cell*/
//===================================================================================================
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Pool *pool = (Pool *)[_fetchedResultController objectAtIndexPath:indexPath];
    [cell.textLabel setText:pool.name];
    [cell.textLabel sizeToFit];
}


//===================================================================================================
//===================================================================================================
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}



//===================================================================================================
//===================================================================================================
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [_context deleteObject:[_fetchedResultController objectAtIndexPath:indexPath]];
        [_appDelegate saveContext];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

//===================================================================================================
//===================================================================================================
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


//===================================================================================================
//===================================================================================================
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


//===================================================================================================
//===================================================================================================
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}


//===================================================================================================
//===================================================================================================
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.isEditing)
    {
        Pool *selectedPool = (Pool *)[_fetchedResultController objectAtIndexPath:indexPath];
        _editedPool = selectedPool;
        
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Edit pool" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
        [av setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
        [[av textFieldAtIndex: 0] setPlaceholder:@"Name"];
        [[av textFieldAtIndex:0] setText:selectedPool.name];
        
        [[av textFieldAtIndex:1] setSecureTextEntry:NO];
        [[av textFieldAtIndex:1] setPlaceholder:@"API address"];
        [[av textFieldAtIndex:1] setText:selectedPool.apiAddress];
        
        [av show];
        
    }
    else
    {
        
        Pool *selectedPool = (Pool *)[_fetchedResultController objectAtIndexPath:indexPath];
        DLog(@"selected: %@", selectedPool);
            [self performSegueWithIdentifier:@"segue show pool info" sender:selectedPool];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"segue show pool info"])
    {
        PMPoolInfoTVC *dest = segue.destinationViewController;
        dest.pool = sender;
    }
//    else if([segue.identifier isEqualToString:@"segue show pool info multipool"])
//    {
//        PMPoolInfoMultipoolTVC *dest = segue.destinationViewController;
//        dest.pool = sender;
//    }
//    else if([segue.identifier isEqualToString:@"segue show pool info other"])
//    {
//        PMPoolInfoOtherTVC *dest = segue.destinationViewController;
//        dest.pool = sender;
//    }
}




@end
