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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.shipmentCount +1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    }else if (section == self.shipmentCount){
        return 1;
    }
    return self.shipmentCount;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    if (section == 0) {
        return @"Stop info";
    }else if (section == self.shipmentCount){
        return @"Action Buttons";
    }
    
    return @"Shipment data";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCell" forIndexPath:indexPath];
        // Configure the cell...
    if ([indexPath section] == 0) {
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 20, 300, 20)];
        nameLabel.text = self.stop.location_name;
        nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
        
       
        //ADRESSS
        
        Address *address = self.stop.address;
        
        UILabel *addressOneLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 40, 200, 20)];
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
        
        MKMapView *mapView = [[MKMapView alloc]initWithFrame:CGRectMake(190, 10, CGRectGetHeight(cell.bounds)-20, CGRectGetHeight(cell.bounds)-20)];
        mapView.delegate = self;
        
        [cell addSubview:mapView];
        [cell addSubview:zipLabel];
        [cell addSubview:countryLabel];
        [cell addSubview:cityLabel];
        [cell addSubview:addressOneLabel];
        
        [cell addSubview:nameLabel];
        
        
    }else if ([indexPath section] == self.shipmentCount){
        UIButton *inButton = [UIButton buttonWithType:UIButtonTypeCustom];
        inButton.frame = CGRectMake(0, 0, CGRectGetWidth(cell.bounds)/3, CGRectGetHeight(cell.bounds));
        inButton.backgroundColor = [UIColor flatRedColor];
        [inButton setTitle:@"IN" forState:UIControlStateNormal];
        [inButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [inButton addTarget:self action:@selector(checkMeIn:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *outButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        outButton.frame = CGRectMake(CGRectGetWidth(cell.bounds)/1.5, 0, CGRectGetWidth(cell.bounds)/3, CGRectGetHeight(cell.bounds));
        outButton.backgroundColor = [UIColor flatGreenColor];
        [outButton setTitle:@"Out" forState:UIControlStateNormal];
        [outButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [outButton addTarget:self action:@selector(checkMeOut:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *messageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        messageButton.frame = CGRectMake(CGRectGetMaxX(outButton.bounds), 0, CGRectGetWidth(cell.bounds)/3, CGRectGetHeight(cell.bounds));
        messageButton.backgroundColor = [UIColor flatBlueColor];
        [messageButton setTitle:@"Note" forState:UIControlStateNormal];
        [messageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
   
        [cell addSubview:inButton];
        [cell addSubview:outButton];
        [cell addSubview:messageButton];
        
    }else{
        Shipment *shipment = [self.stop.shipments allObjects][indexPath.row];
        
        UILabel *shipNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 20, 180, 20)];
        shipNumLabel.text = shipment.shipment_number;
        
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
    }else if ([indexPath section] == self.shipmentCount){
        return 80;
    }
    return 100;
}

#pragma mark -UIButton actions

-(void)checkMeIn:(id)sender{
    NSLog(@"Check me in!!");
}

-(void)checkMeOut:(id)sender{
    NSLog(@"check me out!!");
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
