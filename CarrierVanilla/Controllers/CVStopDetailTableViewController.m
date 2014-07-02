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
#import "CVMapAnnotation.h"

@interface CVStopDetailTableViewController ()<MKMapViewDelegate,UIActionSheetDelegate,CCSignatureDrawViewDelegate>
@property(nonatomic)float shipmentCount;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *msgNavButton;
@property(nonatomic)CVUpdateButton *updateButton;
@property(nonatomic)UIButton *checkOutButton;

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
        

        _stop = stop;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self addCustomRefreshView];
    if(!self.stop.actual_departure){
          [self preparePulltoRefresh];
    }
 
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Ed    it button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


-(void)preparePulltoRefresh{
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(updateStopStatus:) forControlEvents:UIControlEventValueChanged];
    refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"Release to Check-In" attributes:@{
                                                                                                                 NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                                                                 NSFontAttributeName:[UIFont systemFontOfSize:20]
                                                                                                                 }];
    
    //creating view for extending background color
    CGRect frame = self.tableView.bounds;
    frame.origin.y = -frame.size.height;
    _refreshBackgroundView = [[UIView alloc]initWithFrame:frame];
    _refreshBackgroundView.backgroundColor = [UIColor flatBlueColor];
    [_refreshBackgroundView setTag:1];
    self.refreshControl = refreshControl;
    [self.tableView insertSubview:_refreshBackgroundView atIndex:0];
}
-(void)updateStopStatus:(id)sender{
    if (!self.stop.actual_arrival) {
        [self checkMeIn:sender];
    }else if(!self.stop.actual_departure){
        [self checkMeOut:sender];
    }
    
}

-(void)viewDidAppear:(BOOL)animated{
    
    if (![_stop.longitude doubleValue]) {
        
        CLGeocoder *geocoder = [[CLGeocoder alloc]init];
        [geocoder geocodeAddressDictionary:@{
                                             @"City":_stop.address.city,
                                             @"Zip":_stop.address.zip
                                             } completionHandler:^(NSArray *placemarks, NSError *error) {
                                                 
                                                 if (error) {
                                                     NSLog(@"There was an error %@", [error localizedDescription]);
                                                 }else{
                                                     NSLog(@"PLacemarks from dictionary %@", placemarks);
                                                     CLPlacemark *placemark = [placemarks objectAtIndex:0];
                                                     CLLocation *location = placemark.location;
                                                     
                                                     MKCoordinateRegion region;
                                                     MKCoordinateSpan span;
                                                     span.latitudeDelta = 0.005;
                                                     span.longitudeDelta = 0.005;
                                                     _stop.latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
                                                     _stop.longitude = [NSNumber numberWithDouble:location.coordinate.longitude];
                                                     [self.delegate saveChangesOnContext];
                                                     region.span = span;
                                                     region.center = location.coordinate;
                                                    [_mapView setRegion:region animated:YES];
                                                    [self addAnnotationToMap:location];
                                                 }
                                             }];
        
    }else{
        NSLog(@"else statement");
        
        MKCoordinateRegion region;
        MKCoordinateSpan span;
        span.latitudeDelta = 0.005;
        span.longitudeDelta = 0.005;
        
        CLLocation *location = [[CLLocation alloc]initWithLatitude:[_stop.latitude doubleValue] longitude:[_stop.longitude doubleValue]];
        NSLog(@"Location: %@", location);
        region.span = span;
        region.center = location.coordinate;
        [_mapView setRegion:region animated:NO];
        [self addAnnotationToMap:location];

    }
    
    
}

-(void)addAnnotationToMap:(CLLocation*)location{
    CVMapAnnotation *annotation = [[CVMapAnnotation alloc]init];
    annotation.coordinate = location.coordinate;
    annotation.title = self.stop.location_name;
    annotation.subtitle = self.stop.address.address1;
    [_mapView addAnnotation:annotation];
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

    [label setFont:[UIFont boldSystemFontOfSize:14]];
    [label setTextColor:UIColorFromRGB(0x3c6ba1)];
    
    if (section == 0) {
        [label setText:self.stop.location_name];
    }else{
        NSString *shipment = self.shipmentCount > 1 ? @"Shipments" : @"Shipment";
        NSString *fullString = [NSString stringWithFormat:@"%.f %@",self.shipmentCount, shipment];
        [label setText:fullString];
    }
    [view addSubview:label];
    [view setBackgroundColor:UIColorFromRGB(0xcddcec)];

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
        self.updateButton.frame = CGRectMake(CGRectGetWidth(_mapView.bounds), CGRectGetMaxY(_mapView.bounds), 40, 40);
        self.updateButton.backgroundColor = [UIColor flatBlueColor];
        self.updateButton.layer.cornerRadius = 5;
        [self.updateButton addTarget:self action:@selector(checkMeIn:) forControlEvents:UIControlEventTouchUpInside];
        

        
        Address *address = self.stop.address;
        
        UILabel *addressOneLabel = [[UILabel alloc]initWithFrame:CGRectMake(10,  10, CGRectGetWidth(containerView.bounds)-20, 20)];
        addressOneLabel.text = address.address1;
        addressOneLabel.textColor = [UIColor flatDarkGreenColor];
        addressOneLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        
        UILabel *cityLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 30, 120, 20)];
        cityLabel.text = address.city;
        cityLabel.textColor = [UIColor flatDarkGreenColor];
        cityLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        
        
        UILabel *countryLabel = [[UILabel alloc]initWithFrame:CGRectMake(120, 30, 60, 20)];
        countryLabel.text = address.country;
        countryLabel.textColor = [UIColor flatDarkGreenColor];
        countryLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        
        UILabel *zipLabel = [[UILabel alloc]initWithFrame:CGRectMake(180,  30, 60, 20)];
        zipLabel.text = address.zip;
        zipLabel.textColor = [UIColor flatDarkGreenColor];
        zipLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        
        


        [containerView addSubview:zipLabel];
        [containerView addSubview:countryLabel];
        [containerView addSubview:cityLabel];
        [containerView addSubview:addressOneLabel];

        
   
        [_mapView addSubview:containerView];
        [_mapView addSubview:self.updateButton];

        
        
        if (self.stop.actual_arrival) {
            [self addTimestampViewToView:self.mapView animated:NO];
            [self addCheckOutButtonToView:_mapView];
        }
        if (self.stop.actual_arrival && self.stop.actual_departure) {
            [self addTimestampViewToView:self.mapView animated:NO];
            [self addCheckOutTimeStampeViewToView];
        }
        
        
        cell.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
        [cell addSubview:_mapView];
        


        
        
    }else{
        Shipment *shipment = [self.stop.shipments allObjects][indexPath.row];
        
        UIView *containerView = [[UIView alloc]initWithFrame:CGRectMake(10, 10, CGRectGetWidth(cell.bounds)-20, CGRectGetHeight(cell.bounds)-20)];
//        containerView.backgroundColor = [UIColor colorWithRed:60/255.0f green:107/255.0f blue:161/255.0f alpha:0.1f];
//        containerView.layer.borderColor = [UIColor colorWithRed:60/255.0f green:107/255.0f blue:161/255.0f alpha:0.6f].CGColor;
//        containerView.layer.borderWidth = 1;
    
        
        UILabel *shipNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, CGRectGetWidth(containerView.bounds)-20, 20)];
        shipNumLabel.text = [NSString stringWithFormat:@"Customer Reference: %@", shipment.shipment_number];
        shipNumLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
        shipNumLabel.textColor = [UIColor colorWithWhite:.333 alpha:1];
        
        UILabel *commentsLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 28, CGRectGetWidth(containerView.bounds), 20)];
        commentsLabel.text = [NSString stringWithFormat:@"Instructions: %@", shipment.comments];
        commentsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
        commentsLabel.textColor = [UIColor colorWithWhite:.333 alpha:1];
        
        
//        [containerView addSubview:shipNumLabel];
//        [containerView addSubview:commentsLabel];
       
        
        [[shipment.items allObjects]enumerateObjectsUsingBlock:^(Item *item, NSUInteger idx, BOOL *stop) {
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, (idx)*55, CGRectGetWidth(containerView.bounds), 50)];
            view.backgroundColor = [UIColor colorWithRed:60/255.0f green:107/255.0f blue:161/255.0f alpha:0.05f];
            view.layer.borderColor = [UIColor colorWithRed:60/255.0f green:107/255.0f blue:161/255.0f alpha:0.2f].CGColor;
            view.layer.borderWidth = 1;
            view.layer.cornerRadius = 3;
            
            
            NSString *productString = [NSString stringWithFormat:@"%@ pallets", item.product_id];
            
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 200, 30)];
            label.text = productString;
            label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
            label.textColor = UIColorFromRGB(0x3c6ba1);
            
            UITextField *qtyField  = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetWidth(view.bounds)-60, 10, 50, 30)];
            qtyField.placeholder = [item.pieces stringValue];
            qtyField.clearsOnBeginEditing = YES;
            qtyField.layer.borderColor = [UIColor whiteColor].CGColor;
            qtyField.backgroundColor = [UIColor colorWithWhite:1 alpha:.6];
            qtyField.layer.borderWidth = 1;
            qtyField.layer.cornerRadius = 3;
            qtyField.textAlignment = NSTextAlignmentCenter;
            
            [view addSubview:label];
            [view addSubview:qtyField];
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



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showMessages"]) {
        CCMessageViewController *mvc = (CCMessageViewController*)segue.destinationViewController;
        [mvc setStop:self.stop];
    }
}

-(void)addTimestampViewToView:(UIView*)view animated:(BOOL)animated{
    
    
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"HH:mm:ss"];
    
    CGRect largeFrame = CGRectInset(self.updateButton.layer.frame, 10, 10);
    POPSpringAnimation *banim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBounds];
    banim.toValue = [NSValue valueWithCGRect:largeFrame];
    [banim setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        [self.updateButton setTitle:@"1" forState:UIControlStateNormal];
        self.updateButton.titleLabel.font = [UIFont systemFontOfSize:10];
        
    }];
    
    POPSpringAnimation *colorAnim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBackgroundColor];
    colorAnim.toValue = (id)[UIColor colorWithRed:.1 green:.8 blue:.1 alpha:1].CGColor;
    
    
    POPSpringAnimation *posAnim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPosition];
    posAnim.toValue = [NSValue valueWithCGPoint:CGPointMake(15, 15)];
    posAnim.springSpeed = 2;
    posAnim.springBounciness = 0;
    
    [self.updateButton.layer pop_addAnimation:banim forKey:@"grow"];
    [self.updateButton.layer pop_addAnimation:posAnim forKey:@"position"];
    [self.updateButton.layer pop_addAnimation:colorAnim forKey:@"color"];
    
    
    
    
    
    UIView *timestampView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.mapView.bounds), 30)];
    timestampView.backgroundColor = [UIColor colorWithWhite:.99 alpha:.6];
    timestampView.layer.borderWidth = 2;
    timestampView.layer.borderColor = [UIColor whiteColor].CGColor;
    timestampView.alpha = 0;
    
    UILabel *timestampLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 0, CGRectGetWidth(timestampView.bounds), CGRectGetHeight(timestampView.bounds))];
    
    timestampLabel.text = [NSString stringWithFormat:@"Arrived at %@",[df stringFromDate:self.stop.actual_arrival]];
    timestampLabel.textColor = [UIColor flatDarkGreenColor];
    
    [timestampView addSubview:timestampLabel];
    [view insertSubview:timestampView atIndex:2];
    
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

-(void)addCheckOutButtonToView:(UIView *)view{
    self.checkOutButton = [CVUpdateButton buttonWithType:UIButtonTypeCustom];
    self.checkOutButton.frame = CGRectMake(CGRectGetWidth(view.bounds), CGRectGetMaxY(view.bounds), 40, 40);
    self.checkOutButton.backgroundColor = [UIColor flatBlueColor];
    self.checkOutButton.layer.cornerRadius = 5;
 
    [self.checkOutButton addTarget:self action:@selector(checkMeOut:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:self.checkOutButton];
}
-(void)checkMeIn:(id)sender{
    NSLog(@"Check me in!!");
    
    if (!self.stop.actual_arrival) {
        
        NSLog(@"Checking in");
        NSString *titleString = [NSString stringWithFormat:@"Check in at %@ ?", self.stop.location_name];
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:titleString
                                                                 delegate:self
                                                        cancelButtonTitle:@"YES"
                                                   destructiveButtonTitle:@"CANCEL"
                                                        otherButtonTitles:nil];
        [self.refreshControl endRefreshing];

        [actionSheet showInView:self.view];
        //        self.stop.actual_arrival = [NSDate date];
        //[self addCheckOutButtonToView:_mapView];
    }
    
    
    
}
-(void)checkMeOut:(id)sender{
    NSLog(@"Checking out");
    if (self.stop.actual_arrival) {
        self.stop.actual_departure = [NSDate date];
        [self showSignatureView];
    }
}

#pragma mark UIAction sheet delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        NSLog(@"Action was cancelled");
    }else{
        self.stop.actual_arrival = [NSDate date];
            [self addTimestampViewToView:self.mapView animated:YES];
            [self.refreshControl endRefreshing];
            [self.refreshBackgroundView setBackgroundColor:[UIColor flatGreenColor]];
            self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"Release to Check-Out" attributes:@{
                                                                                                                                 NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                                                                                 NSFontAttributeName:[UIFont systemFontOfSize:20]
                                                                                                                                 }];
    }
}

#pragma mark show signature view AND save singature methods

-(void)showSignatureView{
    [self.refreshControl endRefreshing];
    [self.refreshControl removeFromSuperview];
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
                                          completion:^( NSError *error) {
                                              if (error) {
                                                  NSLog(@"there was an error %@", error);
                                                  hud.labelText = @"Error saving";
                                              }else{
                                                  hud.labelText = @"Success";
                                              }
                                              [hud hide:YES afterDelay:0.5];
                                              [self addCheckOutTimeStampeViewToView];
                                              [self.delegate saveChangesOnContext];
                                          }];
        //        }
    }];
}

-(void)addCheckOutTimeStampeViewToView{
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"HH:mm:ss"];
    
    CGRect largeFrame = CGRectInset(self.checkOutButton.layer.frame, 10, 10);
    POPSpringAnimation *banim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBounds];
    banim.toValue = [NSValue valueWithCGRect:largeFrame];
    [banim setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        [self.checkOutButton setTitle:@"2" forState:UIControlStateNormal];
        self.checkOutButton.titleLabel.font = [UIFont systemFontOfSize:10];
        
    }];
    
    POPSpringAnimation *colorAnim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBackgroundColor];
    colorAnim.toValue = (id)[UIColor flatBlueColor].CGColor;
    
    
    POPSpringAnimation *posAnim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPosition];
    posAnim.toValue = [NSValue valueWithCGPoint:CGPointMake(15, 45)];
    posAnim.springSpeed = 2;
    posAnim.springBounciness = 0;
    
    [self.checkOutButton.layer pop_addAnimation:banim forKey:@"grow"];
    [self.checkOutButton.layer pop_addAnimation:posAnim forKey:@"position"];
    [self.checkOutButton.layer pop_addAnimation:colorAnim forKey:@"color"];
    
    
    
    
    
    UIView *timestampView = [[UIView alloc]initWithFrame:CGRectMake(0, 30, CGRectGetWidth(self.mapView.bounds), 30)];
    timestampView.backgroundColor = [UIColor colorWithWhite:.99 alpha:.6];
    timestampView.layer.borderWidth = 2;
    timestampView.layer.borderColor = [UIColor whiteColor].CGColor;
    timestampView.alpha = 0;
    
    UILabel *timestampLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 0, CGRectGetWidth(timestampView.bounds), CGRectGetHeight(timestampView.bounds))];
    
    timestampLabel.text = [NSString stringWithFormat:@"Departed at %@",[df stringFromDate:self.stop.actual_departure]];
    timestampLabel.textColor = [UIColor flatBlueColor];
    
    [timestampView addSubview:timestampLabel];
    [self.mapView insertSubview:timestampView atIndex:2];
    
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
