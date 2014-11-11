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
#import "CVItemLongPress.h"
#import "CVItemTextField.h"

#import "MBProgressHUD.h"
#import "CVMapAnnotation.h"

@interface CVStopDetailTableViewController ()<MKMapViewDelegate,UIActionSheetDelegate,CCSignatureDrawViewDelegate,UITextFieldDelegate>
@property (nonatomic) NSArray *shipments;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *msgNavButton;
@property(nonatomic)CVUpdateButton *updateButton;
@property(nonatomic)UIButton *checkOutButton;
@property(nonatomic)CLLocation *location;


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
        _shipments = [stop.shipments allObjects];
        NSLog(@"Here are this stops shipments: %@", _shipments);
        _stop = stop;
        _mapView = [MKMapView new];
        [self addLocationToMapview];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self preparePulltoRefresh];
    [self.tableView setTableFooterView:[UIView new]];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleTap];
}


-(void)preparePulltoRefresh{
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(updateStopStatus:) forControlEvents:UIControlEventValueChanged];
    refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:_stop.actual_arrival ? NSLocalizedString(@"Already Checked in!", @"Already Checked in!") : NSLocalizedString(@"Release to Check-In", @"Release to Check-In")
                                                                    attributes:@{
                                                                                                                 NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                                                                 NSFontAttributeName:[UIFont systemFontOfSize:20]
                                                                                                                 }];
    
    CGRect frame = self.tableView.bounds;
    frame.origin.y = -frame.size.height;
    _refreshBackgroundView = [[UIView alloc]initWithFrame:frame];
    _refreshBackgroundView.backgroundColor = _stop.actual_arrival ? [UIColor flatDarkGreenColor]: [UIColor flatDarkBlueColor];
    [_refreshBackgroundView setTag:1];
    self.refreshControl = refreshControl;
    self.refreshControl.enabled = _stop.actual_arrival ? NO : YES;
    [self.tableView insertSubview:_refreshBackgroundView atIndex:0];
}

-(void)updateStopStatus:(id)sender{
    if (!self.stop.actual_arrival) {
        [self checkMeIn:sender];
    }else{
        [self.refreshControl endRefreshing];
    }
}



-(void)addLocationToMapview{

    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    [geocoder geocodeAddressDictionary:@{
                                         @"City":_stop.address.city,
                                         @"Street":_stop.address.address1 ?: @""
                                         }
                     completionHandler:^(NSArray *placemarks, NSError *error) {
                         
                         
                         if (error) {
                             UIAlertView *al = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Cannot find on map", nil) message:NSLocalizedString(@"Cannot find on map", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                             [al show];
                         }else{
                             CLPlacemark *placemark = [placemarks firstObject];
                             NSLog(@"Placemenars %@", placemark.location);
                             _location = placemark.location;
                             MKCoordinateRegion region;
                             MKCoordinateSpan span;
                             span.latitudeDelta = 0.005;
                             span.longitudeDelta = 0.005;
                             region.span = span;
                             region.center = _location.coordinate;
                             [_mapView setRegion:region animated:NO];
                             [self addAnnotationToMap:_location];
                         }
                     }];
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
    return (2+[_shipments count]);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;

}



//primary_reference_number

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 2, view.frame.size.width-20, 18)];

    [label setFont:[UIFont boldSystemFontOfSize:12]];
    [label setTextColor:UIColorFromRGB(0x3c6ba1)];
    
    if (section == 0) {
        [label setText:[NSString stringWithFormat:@"%@ %@", [self.stop.type isEqualToString:@"Pick"]? NSLocalizedString(@"CollectFrom", nil) : NSLocalizedString(@"DeliverTo", nil), [NSString stringWithUTF8String:[self.stop.location_name UTF8String]]]];
    }else if (section == 2){
        [label setText:NSLocalizedString(@"SpecialInst", @"SpecialInst")];
    } else{
        Shipment *shipment = _shipments[section-1];
        NSString *fullString = [NSString stringWithFormat:@"%@  %@",NSLocalizedString(@"CustomerRef", nil) , shipment.primary_reference_number];
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
   
    [cell.contentView.subviews enumerateObjectsUsingBlock: ^(UIView *subview, NSUInteger idx, BOOL *stop) {
        [subview removeFromSuperview];
    }];
    if ([indexPath section] == 0) {
        
        _mapView.frame = CGRectMake(10, 10, CGRectGetWidth(cell.bounds)-20, CGRectGetHeight(cell.bounds)-20);
        _mapView.layer.borderColor = [UIColor colorWithWhite:.7 alpha:.3].CGColor;
        _mapView.layer.borderWidth = 1;
        _mapView.delegate = self;

        
        UIView *containerView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_mapView.bounds)-60, CGRectGetWidth(_mapView.bounds), 60)];
        containerView.backgroundColor = [UIColor colorWithWhite:1 alpha:.6];
        containerView.layer.borderColor = [UIColor colorWithWhite:1 alpha:1].CGColor;
        containerView.layer.borderWidth = 3;
        
        self.updateButton = [CVUpdateButton buttonWithType:UIButtonTypeCustom];
        self.updateButton.frame = CGRectMake(CGRectGetWidth(_mapView.bounds), CGRectGetMaxY(_mapView.bounds), 40, 40);
        self.updateButton.backgroundColor = [UIColor flatBlueColor];
        self.updateButton.layer.cornerRadius = 5;
       
        Address *address = self.stop.address;
        
        UILabel *addressOneLabel = [[UILabel alloc]initWithFrame:CGRectMake(10,  5, CGRectGetWidth(containerView.bounds)-20, 20)];
        addressOneLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Street", @"Street"),address.address1] ?: @"";
        addressOneLabel.textColor = [UIColor flatDarkGreenColor];
        addressOneLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
        
        UILabel *cityLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 20, CGRectGetWidth(containerView.bounds)-20, 20)];
        cityLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"City", @"City"), [NSString stringWithUTF8String:[address.city UTF8String]]];
        cityLabel.textColor = [UIColor flatDarkGreenColor];
        cityLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
        
        
        UILabel *stateLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 35, 100, 20)];
        stateLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"County", nil), [NSString stringWithUTF8String:[address.state UTF8String]]];
        stateLabel.textColor = [UIColor flatDarkGreenColor];
        stateLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
        
        UILabel *zipLabel = [[UILabel alloc]initWithFrame:CGRectMake(110,  35, 200, 20)];
        zipLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"PostCode", nil),[NSString stringWithUTF8String:[address.zip UTF8String]]];
        zipLabel.textColor = [UIColor flatDarkGreenColor];
        zipLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];

        [containerView addSubview:zipLabel];
        [containerView addSubview:stateLabel];
        [containerView addSubview:cityLabel];
        [containerView addSubview:addressOneLabel];
   
        [_mapView addSubview:containerView];
        [_mapView addSubview:self.updateButton];

        [self addCheckOutButtonToView:_mapView];
        
        if (self.stop.actual_arrival) {
            [self addTimestampViewToView:self.mapView animated:NO];
        }
        if (self.stop.actual_arrival && self.stop.actual_departure) {
            [self addTimestampViewToView:self.mapView animated:NO];
            [self addCheckOutTimeStampeViewToView];
        }
        
        
        cell.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
        [cell.contentView addSubview:_mapView];
        
    }else if ([indexPath section] == 2){
        [_shipments enumerateObjectsUsingBlock:^(Shipment *shipment, NSUInteger idx, BOOL *stop) {
            UILabel *commentLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, idx*10+10, cell.frame.size.width - 40, 20)];
            commentLabel.textColor = UIColorFromRGB(0xc0392b);
            commentLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
            commentLabel.text = [shipment.comments length] ? shipment.comments : @"...";
            [cell.contentView addSubview:commentLabel];
        }];
    }else{
        
        Shipment *shipment = _shipments[indexPath.section-1];
        UIView *containerView = [[UIView alloc]initWithFrame:CGRectMake(10, 10, CGRectGetWidth(cell.bounds)-20, CGRectGetHeight(cell.bounds)-20)];
        UILabel *shipNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, CGRectGetWidth(containerView.bounds)-20, 20)];
        shipNumLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"CustomerRef", nil) , shipment.shipment_number];
        shipNumLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
        shipNumLabel.textColor = [UIColor colorWithWhite:.333 alpha:1];

        
        [[shipment.items allObjects]enumerateObjectsUsingBlock:^(Item *item, NSUInteger idx, BOOL *stop) {
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, (idx)*55, CGRectGetWidth(containerView.bounds), 50)];
            view.backgroundColor = item.finalized ? [UIColor flatDarkGreenColor] :[UIColor colorWithRed:60/255.0f green:107/255.0f blue:161/255.0f alpha:0.05f];
            view.layer.borderColor = [UIColor colorWithRed:60/255.0f green:107/255.0f blue:161/255.0f alpha:0.2f].CGColor;
            view.layer.borderWidth = 1;
            view.layer.cornerRadius = 3;
            
            
            NSString *productString =  item.product_description;
            
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 230, 30)];
            label.text = productString;
            label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
            label.textColor = item.finalized ? [UIColor whiteColor] : UIColorFromRGB(0x3c6ba1);
            
            CVItemTextField *qtyField  = [[CVItemTextField alloc]initWithFrame:CGRectMake(CGRectGetWidth(view.bounds)-60, 10, 50, 30)];
            qtyField.keyboardType = UIKeyboardTypeNumberPad;
            qtyField.text = [item.updated_pieces stringValue];
            qtyField.layer.borderColor = [UIColor whiteColor].CGColor;
            qtyField.textColor = item.finalized ? [UIColor whiteColor] : [UIColor flatDarkBlueColor];
            qtyField.backgroundColor = item.finalized ? [UIColor clearColor] : [UIColor colorWithWhite:1 alpha:.6];
            qtyField.layer.borderWidth = 1;
            qtyField.layer.cornerRadius = 3;
            qtyField.textAlignment = NSTextAlignmentCenter;
            qtyField.item = item;
            qtyField.delegate = self;
            
            CVItemLongPress *longPress = [[CVItemLongPress alloc]initWithTarget:self action:@selector(handleLongPressOnQtyField:)];
            longPress.item = item;
            [view addGestureRecognizer:longPress];
            [view addSubview:label];
            [view addSubview:qtyField];
            [containerView addSubview:view];
        }];
        [cell.contentView addSubview:containerView];
    }
    
    return cell;
}

-(void)handleLongPressOnQtyField: (CVItemLongPress*)gesture{
 
    
    if (gesture.state == UIGestureRecognizerStateBegan && _stop.actual_arrival && !_stop.actual_departure) {
            gesture.item.finalized = [NSNumber numberWithBool:![gesture.item.finalized boolValue]];
        if ([_stop isFinalizedShipment]) {
            [self checkMeOut];
        }
        for (UIView *subview in gesture.view.subviews) {
            if ([subview isKindOfClass:[UITextField class]]) {
                UITextField *textField = (UITextField*)subview;
                textField.textColor = [UIColor whiteColor];
                textField.backgroundColor = [UIColor clearColor];
            }else if([subview isKindOfClass:[UILabel class]]){
                UILabel *label = (UILabel*)subview;
                label.textColor = [UIColor whiteColor];
            }
        }
        
        
        POPSpringAnimation *colorAnim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBackgroundColor];
        colorAnim.toValue = (id)[UIColor flatDarkGreenColor].CGColor;
        colorAnim.springBounciness = 20;
        [gesture.view.layer pop_addAnimation:colorAnim forKey:@"color"];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Shipment *shipment = _shipments[indexPath.row];
    
    if ([indexPath section] == 0 ) {
        return 250;
    }
    return ([shipment.items count]*80);
}

#pragma mark -UIButton actions

-(void)handleSingleTap:(UIGestureRecognizer*)gesture{
    [self.view endEditing:YES];
}


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
    
    timestampLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"arrived at", nil),[df stringFromDate:self.stop.actual_arrival]];
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
    self.checkOutButton.frame = CGRectMake(10, CGRectGetMaxY(view.bounds), 40, 40);
    self.checkOutButton.backgroundColor = [UIColor flatBlueColor];
    self.checkOutButton.layer.cornerRadius = 5;
 
//    [self.checkOutButton addTarget:self action:@selector(checkMeOut:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:self.checkOutButton];
}
-(void)checkMeIn:(id)sender{
    if (!self.stop.actual_arrival) {
        
        NSString *titleString = [NSString stringWithFormat:@"%@ %@ ?",NSLocalizedString(@"CompleteStop", nil), self.stop.location_name];
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:titleString
                                                                 delegate:self
                                                        cancelButtonTitle:NSLocalizedString(@"Yes", nil)
                                                   destructiveButtonTitle:NSLocalizedString(@"No", nil)
                                                        otherButtonTitles:nil];
        [self.refreshControl endRefreshing];

        [actionSheet showInView:self.view];
    }
    
    
    
}
-(void)checkMeOut{
    if (self.stop.actual_arrival) {
        self.stop.actual_departure = [NSDate date];
        [self showSignatureView];
    }
}

#pragma mark UIAction sheet delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
    }else{
        self.stop.actual_arrival = [NSDate date];
            [self addTimestampViewToView:self.mapView animated:YES];
            [self.refreshControl endRefreshing];
            [self.refreshBackgroundView setBackgroundColor:[UIColor flatGreenColor]];
    }
}



#pragma mark show signature view AND save singature methods

-(void)showSignatureView{
    [self.refreshControl endRefreshing];
    [self.refreshControl removeFromSuperview];
    UITableViewCell *tvc = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

    CCSignatureDrawView *sv = [[CCSignatureDrawView alloc]initWithFrame:CGRectMake(0, 0, tvc.frame.size.width, tvc.frame.size.height) andQuantity:@"666"];
    sv.delegate = self;
    sv.alpha = 0;
    [tvc addSubview:sv];
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
    [UIView animateWithDuration:0.25f animations:^{
        view.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [view removeFromSuperview];

            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = NSLocalizedString(@"Saving Load", nil);
            NSString *pdfName = @"pod.pdf";

            [CCPDFWriter createPDFfromLoad:self.stop.load forStopType:self.stop.type saveToDocumentsWithFileName:pdfName];

        [[CVChepClient sharedClient]UploadProofOfDelivery:imageData andUpdateArrivalTime:_stop.actual_arrival andDepartureTime:_stop.actual_departure forStop:_stop.id onLoad:_stop.load.id completion:^(NSError *error) {
            if (error) {
                hud.labelText = NSLocalizedString(@"Saving Load", nil);
            }else{
                hud.labelText =  NSLocalizedString(@"Success", nil);
            }
            [hud hide:YES afterDelay:0.5];
            [self addCheckOutTimeStampeViewToView];
            [self.delegate saveChangesOnContext];
        }];
    }];
}

-(void)cancelSignatureView:(UIView *)signatureView{
    [signatureView removeFromSuperview];
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
    
    
    
    
    
    UIView *timestampView = [[UIView alloc]initWithFrame:CGRectMake(0, 29, CGRectGetWidth(self.mapView.bounds), 30)];
    timestampView.backgroundColor = [UIColor colorWithWhite:.99 alpha:.6];
    timestampView.layer.borderWidth = 2;
    timestampView.layer.borderColor = [UIColor whiteColor].CGColor;
    timestampView.alpha = 0;
    
    UILabel *timestampLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 0, CGRectGetWidth(timestampView.bounds), CGRectGetHeight(timestampView.bounds))];
    
    timestampLabel.text = [NSString stringWithFormat:@"Departed at: %@",[df stringFromDate:self.stop.actual_departure]];
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

#pragma mark - TextField Delegate Methods

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return !_stop.actual_departure ? YES : NO ;
}

-(void)textFieldDidEndEditing:(CVItemTextField *)textField{
    
    NSString *newValue = [textField text];
    textField.item.updated_pieces = [NSNumber numberWithInt:[newValue integerValue]];
    NSLog(@"Setting item value as: %@", newValue);
    [self.delegate saveChangesOnContext];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return  YES;
    
}

@end
