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
#import "CCSignatureDrawView.h"
#import "CCPDFWriter.h"
#import "Pop.h"

#import "MBProgressHUD.h"


@interface CVStopDetailTableViewController ()<MKMapViewDelegate,UIActionSheetDelegate,CCSignatureDrawViewDelegate>
@property(nonatomic)float shipmentCount;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *msgNavButton;
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
    
    // Uncomment the following line to display an Ed    it button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewDidAppear:(BOOL)animated{
    if (self.stop.actual_arrival ) {
//        self.checkInButton.enabled = NO;
    }
    if (self.stop.actual_departure ) {
//        self.checkOutButton.enabled = NO;
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    }
    return self.shipmentCount;

}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 2, tableView.frame.size.width, 18)];

    [label setFont:[UIFont boldSystemFontOfSize:16]];
    [label setShadowColor:UIColorFromRGB(0x2c3e50)];
    [label setShadowOffset:CGSizeMake(0, 1)];
    [label setTextColor:[UIColor whiteColor]];
    
    if (section == 0) {
        [label setText:self.stop.location_name];
    }else{
        NSString *shipment = self.shipmentCount > 1 ? @"Shipments" : @"Shipment";
        NSString *fullString = [NSString stringWithFormat:@"%.f %@",self.shipmentCount, shipment];
        [label setText:fullString];
    }
    [view addSubview:label];
    [view setBackgroundColor:UIColorFromRGB(0x34495e)];

    return view;
}

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCell" forIndexPath:indexPath];
        // Configure the cell...
    if ([indexPath section] == 0) {
        
        _mapView = [[MKMapView alloc]initWithFrame:CGRectMake(10, 10, CGRectGetWidth(cell.bounds)-20, CGRectGetHeight(cell.bounds)-20)];
        _mapView.delegate = self;
        _mapView.layer.borderColor = [UIColor colorWithWhite:.7 alpha:.3].CGColor;
        _mapView.layer.borderWidth = 1;
        
        UIView *containerView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_mapView.bounds)-60, CGRectGetWidth(_mapView.bounds), 60)];
        containerView.backgroundColor = [UIColor colorWithWhite:1 alpha:.6];
        containerView.layer.borderColor = [UIColor colorWithWhite:1 alpha:1].CGColor;
        containerView.layer.borderWidth = 3;
        
        self.updateButton = [CVUpdateButton buttonWithType:UIButtonTypeCustom];
        self.updateButton.frame = CGRectMake(CGRectGetWidth(_mapView.bounds)-50, CGRectGetMaxY(_mapView.bounds)-50, 40, 40);
        self.updateButton.backgroundColor = [UIColor flatBlueColor];
        self.updateButton.layer.cornerRadius = 5;
        [self.updateButton addTarget:self action:@selector(checkMeIn:) forControlEvents:UIControlEventTouchUpInside];
        

        
        Address *address = self.stop.address;
        
        UILabel *addressOneLabel = [[UILabel alloc]initWithFrame:CGRectMake(10,  10, CGRectGetWidth(containerView.bounds)-90, 20)];
        addressOneLabel.text = address.address1;
        addressOneLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        
        UILabel *cityLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 30, 50, 20)];
        cityLabel.text = address.city;
        cityLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        
        
        UILabel *countryLabel = [[UILabel alloc]initWithFrame:CGRectMake(70, 30, 50, 20)];
        countryLabel.text = address.country;
        countryLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        
        UILabel *zipLabel = [[UILabel alloc]initWithFrame:CGRectMake(90,  30, 30, 20)];
        zipLabel.text = address.zip;
        zipLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        
        
        
        if (self.stop.actual_arrival) {
            [self addTimestampViewToView:self.mapView];
        }

//        [containerView addSubview:nameLabel];
        [containerView addSubview:zipLabel];
        [containerView addSubview:countryLabel];
        [containerView addSubview:cityLabel];
        [containerView addSubview:addressOneLabel];

        
   
        [_mapView addSubview:containerView];
        [_mapView addSubview:self.updateButton];

        cell.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
        [cell addSubview:_mapView];

        
        
    }else{
        Shipment *shipment = [self.stop.shipments allObjects][indexPath.row];
        
        UIView *containerView = [[UIView alloc]initWithFrame:CGRectMake(10, 10, CGRectGetWidth(cell.bounds)-20, CGRectGetHeight(cell.bounds)-20)];
        containerView.backgroundColor = [UIColor colorWithWhite:.995 alpha:.5];
        containerView.layer.borderColor = [UIColor colorWithWhite:.955 alpha:1].CGColor;
        containerView.layer.borderWidth = 1;
    
        
        UILabel *shipNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, CGRectGetWidth(containerView.bounds)-20, 20)];
        shipNumLabel.text = [NSString stringWithFormat:@"Customer Reference: %@", shipment.shipment_number];
        shipNumLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
        shipNumLabel.textColor = [UIColor colorWithWhite:.333 alpha:1];
        
        UILabel *commentsLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 28, CGRectGetWidth(containerView.bounds), 20)];
        commentsLabel.text = [NSString stringWithFormat:@"Instructions: %@", shipment.comments];
        commentsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
        commentsLabel.textColor = [UIColor colorWithWhite:.333 alpha:1];
        
        
        [containerView addSubview:shipNumLabel];
        [containerView addSubview:commentsLabel];
        
        [[shipment.items allObjects]enumerateObjectsUsingBlock:^(Item *item, NSUInteger idx, BOOL *stop) {
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(10, (idx+1)*35+28, CGRectGetWidth(containerView.bounds)-20, 30)];
//            view.backgroundColor = [UIColor colorWithWhite:1 alpha:.6];
//            view.layer.borderColor = [UIColor colorWithWhite:1 alpha:1].CGColor;
//            view.layer.borderWidth = 2;
            
            
            NSString *productString = [NSString stringWithFormat:@"%@ x %@ type pallets", item.pieces, item.product_id];
            
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, CGRectGetWidth(view.bounds), 20)];
            label.text = productString;
            label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
            label.textColor = [UIColor colorWithWhite:.333 alpha:1];

            [view addSubview:label];
            [containerView addSubview:view];
        }];
        [cell addSubview:containerView];
    }
    
    return cell;
}



- (UITableViewCell *)configueCellForShipments:(UITableViewCell*)cell{
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([indexPath section] == 0 ) {
        return 250;
    }
    return 200;
}

#pragma mark -UIButton actions

-(void)checkMeIn:(id)sender{
    NSLog(@"Check me in!!");
    
    if (self.stop.actual_arrival) {
        NSLog(@"Time to check out");
        NSString *titleString = [NSString stringWithFormat:@"Check OUT at %@ ?", self.stop.location_name];
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:titleString
                                                                 delegate:self
                                                        cancelButtonTitle:@"YES"
                                                   destructiveButtonTitle:@"CANCEL"
                                                        otherButtonTitles:nil];
        [actionSheet showInView:self.view];
           self.stop.actual_departure = [NSDate date];
    }else{
        NSLog(@"Checking in");
        NSString *titleString = [NSString stringWithFormat:@"Check IN at %@ ?", self.stop.location_name];
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:titleString
                                                                 delegate:self
                                                        cancelButtonTitle:@"YES"
                                                   destructiveButtonTitle:@"CANCEL"
                                                        otherButtonTitles:nil];
        [actionSheet showInView:self.view];
        self.stop.actual_arrival = [NSDate date];
    }
    


}

-(void)goToMessages:(id)sender{
    CCMessageViewController *mvc = [[CCMessageViewController alloc]init];
    [mvc setLoad:self.stop.load];
    [self.navigationController pushViewController:mvc animated:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showMessages"]) {
        CCMessageViewController *mvc = (CCMessageViewController*)segue.destinationViewController;
        [mvc setLoad:self.stop.load];
    }
}

-(void)addTimestampViewToView:(UIView*)view{
    
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"HH:mm:ss"];
    
    UIView *timestampView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.mapView.bounds), 30)];
    timestampView.backgroundColor = [UIColor colorWithWhite:.99 alpha:.5];
    timestampView.layer.borderWidth = 2;
    timestampView.layer.borderColor = [UIColor whiteColor].CGColor;
    timestampView.alpha = 0;
    
    UILabel *timestampLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 0, CGRectGetWidth(timestampView.bounds), CGRectGetHeight(timestampView.bounds))];
    
    timestampLabel.text = [NSString stringWithFormat:@"Arrived at %@",[df stringFromDate:self.stop.actual_arrival]];
    timestampLabel.textColor = [UIColor flatDarkGreenColor];
    
    [timestampView addSubview:timestampLabel];
    [view insertSubview:timestampView atIndex:1];
    
    POPBasicAnimation *anim = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anim.fromValue = @(0.0);
    anim.toValue = @(1.0);
    anim.duration = 0.5;
    
    POPBasicAnimation *boundsAnim = [POPBasicAnimation animationWithPropertyNamed:kPOPViewBounds];
    boundsAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    boundsAnim.toValue = [NSValue valueWithCGRect:timestampView.bounds];
    boundsAnim.fromValue = [NSValue valueWithCGRect:CGRectMake(0, 0, 0, 30)];
    
    [timestampView pop_addAnimation:boundsAnim forKey:@"bounds"];
    
    
    
    [timestampView pop_addAnimation:anim forKey:@"fade"];
}

#pragma mark UIAction sheet delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        NSLog(@"Action was cancelled");

        [self.delegate rollbackChanges];
    }else{
        if (self.stop.actual_arrival && !self.stop.actual_departure ) {
            
            CGRect largeFrame = CGRectInset(self.updateButton.layer.frame, 10, 10);
            POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBounds];
            anim.toValue = [NSValue valueWithCGRect:largeFrame];
            [anim setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
                [self.updateButton setTitle:@"1" forState:UIControlStateNormal];
                self.updateButton.titleLabel.font = [UIFont systemFontOfSize:8];
                
            }];
            
            POPSpringAnimation *colorAnim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBackgroundColor];
            colorAnim.toValue = (id)[UIColor colorWithRed:.1 green:.8 blue:.1 alpha:.5].CGColor;
            
            
            POPSpringAnimation *posAnim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPosition];
            posAnim.toValue = [NSValue valueWithCGPoint:CGPointMake(15, 15)];
            posAnim.springSpeed = 2;
            posAnim.springBounciness = 0;

            [self addTimestampViewToView:self.mapView];
            
            
            [self.updateButton.layer pop_addAnimation:anim forKey:@"grow"];
            [self.updateButton.layer pop_addAnimation:posAnim forKey:@"position"];
            [self.updateButton.layer pop_addAnimation:colorAnim forKey:@"color"];

        }else{

            
            [self showSignatureView];
        }

    }
}

#pragma mark show signature view AND save singature methods

-(void)showSignatureView{
    CCSignatureDrawView *sv = [[CCSignatureDrawView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) andQuantity:@"666"];
    sv.delegate = self;
    sv.alpha = 0;
    [self.view addSubview:sv];
    self.tableView.scrollEnabled = NO;
    [UIView animateWithDuration:0.5
                     animations:^{
                         sv.alpha = 1;
                     } completion:^(BOOL finished) {
                         NSLog(@"shown signature view");
                     }];
    
    
}

-(void)saveSignatureSnapshotAsData:(NSData *)imageData andSignatureBezier:(UIBezierPath*)signatureBezierPath updateQuantity:(NSString*)quantity andDismissView:(UIView *)view{
    self.stop.signatureSnapshot = imageData;
    NSLog(@"I saved the image data and will dismiss the view");
    [UIView animateWithDuration:0.25f animations:^{
        view.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Saving Load";
        //                self.signaturePic.image = [UIImage imageWithData:imageData];
        //        if ([self.stop.load isCompletedLoad]) {
        NSString *pdfName = @"pod.pdf";
        
        [CCPDFWriter createPDFfromLoad:self.stop.load saveToDocumentsWithFileName:pdfName];
        [[CVChepClient sharedClient]updateStopWithId:@"75135140"
                                             forLoad:self.stop.load.id
                                      withQuantities:@[@2] withActualArrival:[NSDate date]
                                 withActualDeparture:[NSDate date]
                                              andPod:imageData
                                          completion:^(NSDictionary *results, NSError *error) {
                                              if (error) {
                                                  NSLog(@"there was an error %@", error);
                                                  hud.labelText = @"Error saving";
                                              }else{
                                                  NSLog(@"successful update %@" , results);
                                                  hud.labelText = @"Success";
                                              }
                                              [hud hide:YES afterDelay:2.0];

                                          }];
        //        }
        [view removeFromSuperview];
    }];
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
