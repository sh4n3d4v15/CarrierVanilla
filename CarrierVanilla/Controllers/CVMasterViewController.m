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

    
    _timeWindowformatter = [[NSDateFormatter alloc]init];
    [_timeWindowformatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [_timeWindowformatter setDateFormat:@"HH:mm"];
    
    

    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
    
    self.navigationItem.leftBarButtonItem = nil;
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
}



-(void)removeHud:(MBProgressHUD*)hud{
    [hud hide:YES afterDelay:1.0];
}

//-(void)viewWillAppear:(BOOL)animated{
//    NSLog(@"View will appear fired");
//    BOOL isUserLoggedIn = [[NSUserDefaults standardUserDefaults] boolForKey:@"userLoggedIn"];
//    
//    if( !isUserLoggedIn ){
//        [self showLoginViewAnimated:NO];
//    }else{
//       // [self refresh:nil];
//    }
//    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
//
//}

-(void)refresh:(id)sender{
    NSDictionary *userinfo = [[NSUserDefaults standardUserDefaults]objectForKey:@"userinfo"];
    [[CVChepClient sharedClient]getStopsForUser:userinfo completion:^(NSString *responseMessage, NSError *error) {
        if (error) {
            UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Problem refreshing" message:responseMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [av show];
        }
            [(UIRefreshControl*)sender endRefreshing];
    }];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}



-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    __block BOOL complete = YES;
     [[sectionInfo objects]enumerateObjectsUsingBlock:^(Stop *_stop, NSUInteger idx, BOOL *stop) {
        if (!_stop.actual_departure) {
            complete = NO;
            *stop = YES;
        }
    }];
    
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    
    UIImageView *truckimageView = [[UIImageView alloc]initWithFrame:CGRectMake(17, 1, 18, 18)];
    [truckimageView setImage:[UIImage imageNamed: @"truck.png"]];
    [view addSubview:truckimageView];
    UILabel *shipmentnumberlabel = [[UILabel alloc] initWithFrame:CGRectMake(44, 2, 100, 18)];
    [shipmentnumberlabel setFont:[UIFont boldSystemFontOfSize:14]];
    [shipmentnumberlabel setText:[sectionInfo name]];
    [shipmentnumberlabel setTextColor: UIColorFromRGB(0x3c6ba1)];
    [view addSubview:shipmentnumberlabel];

    
    UIImageView *stopimageView = [[UIImageView alloc]initWithFrame:CGRectMake(135, 5, 14, 14)];
    [stopimageView setImage:[UIImage imageNamed:@"flag.png"]];
    [view addSubview:stopimageView];
    UILabel *stopCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(159, 2, 100, 18)];
    [stopCountLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [stopCountLabel setText:[NSString stringWithFormat:@"%lu %@",(unsigned long)[sectionInfo numberOfObjects],NSLocalizedString(@"Stops", nil)]  ];
    [stopCountLabel setTextColor:UIColorFromRGB(0x3c6ba1)];
    [view addSubview:stopCountLabel];
    
    
//    UIImageView *networkimageView = [[UIImageView alloc]initWithFrame:CGRectMake(243, 5, 14, 14)];
//    [networkimageView setImage:[UIImage imageNamed:@"network.png"]];
//    [view addSubview:networkimageView];
    
    NSString *driver = [NSString stringWithFormat:@"# %@",[[[sectionInfo objects]firstObject]valueForKeyPath:@"load.driver"]];
    UILabel *statusLabel = [[UILabel alloc]initWithFrame:CGRectMake(265, 2, 80, 18)];
    [statusLabel setText:driver];
    [statusLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [statusLabel setTextColor: UIColorFromRGB(0x3c6ba1)];
    
    
    [view addSubview:statusLabel];
    
    
    view.backgroundColor =  UIColorFromRGB(0xcddcec);
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


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

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

-(void)getLoadsForDifferentDate{

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type == %@",@"Pick"];
    [self.fetchedResultsController.fetchRequest setPredicate:predicate];
    NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {

	}else{
        NSLog(@"i did the request");
       [self.tableView reloadData];
    }
   
}
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
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"load.load_number" ascending:YES];
    NSSortDescriptor *typeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"type" ascending:NO];
    NSSortDescriptor *driverSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"load.driver" ascending:YES];
    NSArray *sortDescriptors = @[driverSortDescriptor,typeSortDescriptor];
    
    
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"load.load_number" cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {

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

-(void)userDidLoginWithDictionary:(NSDictionary *)userInfo completion:(void (^)(NSError *, NSString *))completion{
    _userinfo = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"userinfo"];
    [[CVChepClient sharedClient]getStopsForUser:userInfo completion:^(NSString *responseMessage, NSError *error) {
        completion(error,responseMessage);
    }];
}


-(void)saveChangesOnContext{
    NSError *error;
    [self.managedObjectContext save:&error];
    if (error) {
    }
}

-(void)rollbackChanges{
    [self.managedObjectContext rollback];
}
- (void)configureCell:(CVStopTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Stop *stop = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.locationNameLabel.text = [ NSString stringWithUTF8String:[stop.location_name UTF8String]];;
    cell.locationNameLabel.textColor = UIColorFromRGB(0x3c6ba1);
    cell.addressOneLabel.text = [stop.address.address1 length] ? [NSString stringWithUTF8String:[stop.address.address1 UTF8String]] : @"";
    cell.cityLabel.text = [stop.address.city length] ? [NSString stringWithUTF8String:[stop.address.city UTF8String]] : @"";
    cell.zipLabel.text = [stop.address.zip length] ? [NSString stringWithUTF8String:[stop.address.zip UTF8String]] : @"";
    cell.typeLabel.text = [NSString stringWithUTF8String:[stop.type UTF8String]];
    cell.timeWindowLabel.text = [NSString stringWithFormat:@"%@ - %@",[_timeWindowformatter stringFromDate:stop.planned_start],[_timeWindowformatter stringFromDate:stop.planned_end]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;

    if ([stop.type isEqualToString:@"Drop"]) {
        cell.imageView.image = stop.actual_departure ? [UIImage imageNamed:@"dropicondone1.png"] : [UIImage imageNamed:@"dropicon.png"];
    }else{
        cell.imageView.image = stop.actual_departure ? [UIImage imageNamed:@"pickicondone1.png"]: [UIImage imageNamed:@"pickicon.png"];
    }
    if (stop.actual_departure) {
       // cell.imageView.alpha = .9;
    }
}

-(void)showLogin:(id)sender{
    NSLog(@"login button pressed");
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:NSLocalizedString(@"Logout", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Logout", nil) otherButtonTitles:nil];
    [actionSheet showInView:self.view];
}

#pragma mark - UIAction Sheet Delegate Methods

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSLog(@"Button index: %i", buttonIndex);
    if (buttonIndex == 0) {
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"userLoggedIn"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [self showLoginViewAnimated:YES];
    }
}

-(void)logOutAsCarrier{
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"userinfo"];
}

@end
