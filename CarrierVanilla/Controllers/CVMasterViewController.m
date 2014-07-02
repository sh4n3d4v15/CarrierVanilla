//
//  CVMasterViewController.m
//  CarrierVanilla
//
//  Created by shane davis on 06/06/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import "CVMasterViewController.h"
#import "CVStopTableViewCell.h"

#import "CVStopDetailTableViewController.h"
#import "CCLoginViewController.h"
#import "CVChepClient.h"
#import "Stop.h"
#import "Load.h"
#import "Address.h"
#import "Ref.h"
#import "Shipment.h"
#import "Item.h"
#import <FBTweak.h>
#import <FBTweakInline.h>
#import "MBProgressHUD.h"

@interface CVMasterViewController ()<stopChangeDelegate,CCLoginViewDelegate,UIActionSheetDelegate>
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation CVMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    
    // Configure Refresh Control
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    
    // Configure View Controller
    [self setRefreshControl:refreshControl];
    
    self.navigationItem.leftBarButtonItem = nil;
    UISegmentedControl *statFilter = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Mon", @"Today", @"Wed", nil]];
                                      self.navigationItem.titleView = statFilter;
    statFilter.selectedSegmentIndex = 1;
    [statFilter setTitleTextAttributes:@{[UIFont fontWithName:@"HelveticaNeue" size:5.0]: NSFontAttributeName} forState:UIControlStateNormal];
    [statFilter addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];


     UIBarButtonItem *btn = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"menu.png"] style:UIBarButtonItemStylePlain
                                                          target:self action:@selector(showLogin:)];
    self.navigationItem.rightBarButtonItem = btn;
}

-(void)dateChanged:(id)sender{
    UISegmentedControl *segmentCtrl =  (UISegmentedControl*)sender;
    NSLog(@"The day changed to: %@", [segmentCtrl titleForSegmentAtIndex:[segmentCtrl selectedSegmentIndex]]);
    MBProgressHUD *hud =  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading";
    
    [self performSelector:@selector(removeHud:) withObject:hud afterDelay:2.0];
//    [[CVChepClient sharedClient]getStopsForVehicle:@"need a date method here!!" completion:^(NSArray *results, NSError *error) {
//        [self removeHud:hud];
//    }];
}



-(void)removeHud:(MBProgressHUD*)hud{
    [hud hide:YES afterDelay:1.0];
}

-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"View will appear fired");
    BOOL isUserLoggedIn = [[NSUserDefaults standardUserDefaults] boolForKey:@"userLoggedIn"];
    
    if( !isUserLoggedIn ){
        [self showLoginViewAnimated:NO];
    }else{
//        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        hud.labelText = @"Retrieving loads";
        [[CVChepClient sharedClient]getStopsForVehicle:@"goo" completion:^(NSArray *results, NSError *error) {
            if (error) {
//                hud.labelText = [error localizedDescription];
//                [self removeHud:hud];
            }else{
//                hud.labelText = @"Success";
//                [self removeHud:hud];
            }
        }];
    }
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];

}

-(void)refresh:(id)sender{
    NSLog(@"RERESH");
    [[CVChepClient sharedClient]getStopsForVehicle:@"" completion:^(NSArray *results, NSError *error) {
        if (error) {
            UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Problem refreshing" message:@"Sorry, we could not refresh the loads" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [av show];
        }
            [(UIRefreshControl*)sender endRefreshing];
    }];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}



-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    /* Create custom view to display section header... */
    UILabel *shipmentnumberlabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 2, 100, 18)];
    [shipmentnumberlabel setFont:[UIFont boldSystemFontOfSize:14]];
    [shipmentnumberlabel setText:[sectionInfo name]];
    [shipmentnumberlabel setTextColor:UIColorFromRGB(0x3c6ba1)];
    [view addSubview:shipmentnumberlabel];
    
    UIImageView *truckimageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 1, 18, 18)];
    [truckimageView setImage:[UIImage imageNamed:@"truck.png"]];
    [view addSubview:truckimageView];
    
    UIImageView *stopimageView = [[UIImageView alloc]initWithFrame:CGRectMake(120, 5, 14, 14)];
    [stopimageView setImage:[UIImage imageNamed:@"flag.png"]];
    [view addSubview:stopimageView];
    
    UILabel *stopCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(140, 2, 100, 18)];
    [stopCountLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [stopCountLabel setText:[NSString stringWithFormat:@"%i STOPS",[sectionInfo numberOfObjects]]];
    [stopCountLabel setTextColor:UIColorFromRGB(0x3c6ba1)];
    [view addSubview:stopCountLabel];
    
    
    view.backgroundColor = UIColorFromRGB(0xcddcec);
    return view;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CVStopTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}
//
//- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
//    if(cell.selectionStyle == UITableViewCellSelectionStyleNone){
//        return nil;
//    }
//    return indexPath;
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showStop"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Stop *selectedStop = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        CVStopDetailTableViewController *dvc = (CVStopDetailTableViewController*)[segue destinationViewController];
        [dvc setStop:selectedStop];
        dvc.delegate = self;
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Stop" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"load.load_number" ascending:YES];
    NSSortDescriptor *typeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"type" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor,typeSortDescriptor];
    
    
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"load.load_number" cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}


#pragma mark - Custom methods

-(void)showLoginViewAnimated:(BOOL)animated{
    CCLoginViewController *lvc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"loginView"];
    lvc.delegate = self;
    [self presentViewController:lvc animated:animated completion:nil];
}

#pragma mark  -  Delegate methods

-(void)userDidLoginWithDictionary:(NSDictionary *)userInfo{

}


-(void)saveChangesOnContext{
    NSError *error;
    [self.managedObjectContext save:&error];
    if (error) {
        NSLog(@"There was an error saving the context");
    }
}

-(void)rollbackChanges{
    [self.managedObjectContext rollback];
}
- (void)configureCell:(CVStopTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Stop *stop = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.locationNameLabel.text = [ NSString stringWithUTF8String:[stop.location_name cStringUsingEncoding:NSUTF8StringEncoding]];;
    cell.locationNameLabel.textColor = UIColorFromRGB(0x3c6ba1);
    cell.addressOneLabel.text = [ NSString stringWithUTF8String:[stop.address.address1 cStringUsingEncoding:NSUTF8StringEncoding]];
    cell.cityLabel.text = stop.address.city;
    cell.zipLabel.text = stop.address.zip;
    cell.typeLabel.text = stop.type;
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;

    if ([stop.type isEqualToString:@"Drop"]) {
        cell.imageView.image = stop.actual_departure ? [UIImage imageNamed:@"dropicondone1.png"] : [UIImage imageNamed:@"dropicon.png"];
    }else{
        cell.imageView.image = stop.actual_departure ? [UIImage imageNamed:@"pickicondone1.png"]: [UIImage imageNamed:@"pickicon.png"];
    }
    if (stop.actual_departure) {
        cell.imageView.alpha = .9;
    }
}

-(void)showLogin:(id)sender{
    NSLog(@"login button pressed");
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Switch vehicle or signout carrier" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Logout" otherButtonTitles: @"Switch Vehicle",nil, nil];
    [actionSheet showInView:self.view];
}

#pragma mark - UIAction Sheet Delegate Methods

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"button clicked on action sheet: %li", (long)buttonIndex);
    
    switch (buttonIndex) {
        case 0:
            [self logOutAsCarrier];
            [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"userLoggedIn"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [self showLoginViewAnimated:YES];
            break;
        case 1:
            [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"userLoggedIn"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [self showLoginViewAnimated:YES];
            break;
            
        default:
            break;
    }
    
    
}

-(void)logOutAsCarrier{
    [[NSUserDefaults standardUserDefaults]setValue:nil forKey:@"carrierID"];
}


#pragma mark throw away pdf methods



@end
