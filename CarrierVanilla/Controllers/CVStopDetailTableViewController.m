//
//  CVStopDetailTableViewController.m
//  CarrierVanilla
//
//  Created by shane davis on 13/06/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import "CVStopDetailTableViewController.h"
#import "Address.h"
#import "Shipment.h"
#import "Item.h"
#import "UIColor+MLPFLatColors.h"
#import "CCMessageViewController.h"
#import "CVChepClient.h"


@interface CVStopDetailTableViewController ()
@property(nonatomic)float shipmentCount;
@end

@implementation CVStopDetailTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setStop:(Stop *)stop
{
    if (_stop != stop) {
        NSArray *shipments = [stop.shipments allObjects];
        _shipmentCount =  [shipments count];
        NSLog(@"SHIPMENT COUNT::: %lu", (unsigned long)[shipments count]);
        CLGeocoder *geocoder = [[CLGeocoder alloc]init];
        [geocoder geocodeAddressString:@"M33 7TA" completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error) {
                NSLog(@"There was an error %@", error);
            }else{
                NSLog(@"Placemarks %@", placemarks);
                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                CLLocation *location = placemark.location;
                
                MKCoordinateRegion region;
                MKCoordinateSpan span;
                span.latitudeDelta = 0.005;
                span.longitudeDelta = 0.005;
                region.span = span;
                region.center = location.coordinate;
                
                [_mapView setRegion:region animated:YES];
            }
        }];
        _stop = stop;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSLog(@"STOP: %@", self.stop);
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewDidAppear:(BOOL)animated{
    if ([self.stop.actual_arrival length]) {
        self.checkInButton.enabled = NO;
    }
    if ([self.stop.actual_departure length]) {
        self.checkOutButton.enabled = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    }else if (section == 1){
        return self.shipmentCount;
    }
    return 1;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    if (section == 0) {
        return @"Stop info";
    }else if (section == 2){
        return @"Action Buttons";
    }
    
    return @"Shipment data";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCell" forIndexPath:indexPath];
        // Configure the cell...
    if ([indexPath section] == 0) {
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 20, 150, 20)];
        nameLabel.text = self.stop.location_name;
        nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
        
       
        //ADRESSS
        
        Address *address = self.stop.address;
        
        UILabel *addressOneLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 40, 150, 20)];
        addressOneLabel.text = address.address1;
        addressOneLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
        
        UILabel *cityLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 60, 100, 20)];
        cityLabel.text = address.city;
        cityLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        
        
        UILabel *countryLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 80, 100, 20)];
        countryLabel.text = address.country;
        countryLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        
        UILabel *zipLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 100, 100, 20)];
        zipLabel.text = address.zip;
        zipLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        

        _mapView = [[MKMapView alloc]initWithFrame:CGRectMake(190, 10, CGRectGetHeight(cell.bounds)-20, CGRectGetHeight(cell.bounds)-20)];
        _mapView.delegate = self;
        
        cell.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
        [cell addSubview:_mapView];
        [cell addSubview:zipLabel];
        [cell addSubview:countryLabel];
        [cell addSubview:cityLabel];
        [cell addSubview:addressOneLabel];
        
        [cell addSubview:nameLabel];
        
        
    }else if ([indexPath section] == 2){
        self.checkInButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.checkInButton.frame = CGRectMake(0, 0, CGRectGetWidth(cell.bounds)/3, CGRectGetHeight(cell.bounds));
        self.checkInButton.backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
        [self.checkInButton setTitle:@"IN" forState:UIControlStateNormal];
        [self.checkInButton setTitle:@"DONE" forState:UIControlStateDisabled];
        [self.checkInButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.checkInButton setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
         [self.checkInButton setBackgroundColor:[UIColor colorWithWhite:.8 alpha:1]];
        [self.checkInButton addTarget:self action:@selector(checkMeIn:) forControlEvents:UIControlEventTouchUpInside];
        
        self.checkOutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.checkOutButton.frame = CGRectMake(CGRectGetWidth(cell.bounds)/1.5, 0, CGRectGetWidth(cell.bounds)/3, CGRectGetHeight(cell.bounds));
        self.checkOutButton.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
        [self.checkOutButton setTitle:@"OUT" forState:UIControlStateNormal];
        [self.checkOutButton setTitle:@"DONE" forState:UIControlStateDisabled];
        [self.checkOutButton setBackgroundColor:[UIColor colorWithWhite:0.8 alpha:1]];
        [self.checkOutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.checkOutButton addTarget:self action:@selector(checkMeOut:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *messageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        messageButton.frame = CGRectMake(CGRectGetMaxX(self.checkOutButton.bounds), 0, CGRectGetWidth(cell.bounds)/3, CGRectGetHeight(cell.bounds));
        messageButton.backgroundColor = [UIColor flatBlueColor];
        [messageButton setTitle:@"NOTE" forState:UIControlStateNormal];
        [messageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [messageButton addTarget:self action:@selector(goToMessages:) forControlEvents:UIControlEventTouchUpInside];
   
        [cell addSubview:self.checkInButton];
        [cell addSubview:self.checkOutButton];
        [cell addSubview:messageButton];
        
    }else{
        Shipment *shipment = [self.stop.shipments allObjects][indexPath.row];
        
        UILabel *shipNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 20, 180, 20)];
        shipNumLabel.text = [NSString stringWithFormat:@"Ref: %@", shipment.shipment_number];
        UILabel *commentsLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 40, 180, 20)];
        commentsLabel.text = shipment.comments;
        shipNumLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        commentsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        [cell addSubview:shipNumLabel];
        [cell addSubview:commentsLabel];
        [[shipment.items allObjects]enumerateObjectsUsingBlock:^(Item *item, NSUInteger idx, BOOL *stop) {
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(cell.bounds)-120, (idx+1)*20, 150, 20)];
            NSString *productString = [NSString stringWithFormat:@"%@ pieces of %@", item.pieces, item.product_id];
            label.text = productString;
            label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
            [cell addSubview:label];
        }];
    }
    
    return cell;
}

- (UITableViewCell *)configueCellForShipments:(UITableViewCell*)cell{
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([indexPath section] == 0 ) {
        return 134;
    }else if ([indexPath section] == 1){
        return 120;
    }
    return 100;
}

#pragma mark -UIButton actions

-(void)checkMeIn:(id)sender{
    NSLog(@"Check me in!!");
    self.stop.actual_arrival = [NSString stringWithFormat:@"%@", [NSDate date]];

    NSString *titleString = [NSString stringWithFormat:@"Check in at %@ ?", self.stop.location_name];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:titleString
                                                             delegate:self
                                                    cancelButtonTitle:@"YES"
                                               destructiveButtonTitle:@"CANCEL"
                                                    otherButtonTitles:nil];
    [actionSheet showInView:self.view];
//    UIAlertView *alv = [[UIAlertView alloc]initWithTitle:@"Saved" message:@"Stop Updated" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel",nil];
//    [alv show];
    
}
//
-(void)checkMeOut:(id)sender{
    NSLog(@"check me out!!");
    self.stop.actual_departure = [NSString stringWithFormat:@"%@", [NSDate date]];
    
    NSString *dateString = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                          dateStyle:NSDateFormatterNoStyle
                                                          timeStyle:NSDateFormatterShortStyle];
    NSLog(@"%@",dateString);

    NSString *titleString = [NSString stringWithFormat:@"Check out from %@ ?", self.stop.location_name];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:titleString
                                                             delegate:self
                                                    cancelButtonTitle:@"YES"
                                               destructiveButtonTitle:@"CANCEL"
                                                    otherButtonTitles:nil];
    [actionSheet showInView:self.view];
}
-(void)goToMessages:(id)sender{
    CCMessageViewController *mvc = [[CCMessageViewController alloc]init];
    [mvc setStop:self.stop];
    [self.navigationController pushViewController:mvc animated:YES];
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        NSLog(@"Action was cancelled");

        [self.delegate rollbackChanges];
    }else{
        NSLog(@"Action was confirmed");
        [self.delegate saveChangesOnContext];
    }
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
