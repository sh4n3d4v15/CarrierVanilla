//
//  CVStopDetailTableViewController.m
//  CarrierVanilla
//
//  Created by shane davis on 13/06/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//
#import "TestFlight.h"
#import "CVShipmentView.h"

#import "CVStopDetailTableViewController.h"

#import "Address.h"
#import "Shipment.h"
#import "Item.h"
#import "Load.h"
#import "Pod.h"

#import "UIColor+MLPFLatColors.h"
#import "CCMessageViewController.h"
#import "CVChepClient.h"
#import "CVSignatureViewController.h"
#import "Pop.h"
#import "CVItemLongPress.h"
#import "CVItemTextField.h"
#import "MBProgressHUD.h"
#import "CVMapAnnotation.h"
#import "TOMSMorphingLabel.h"

#import "CVMultiPDFWriter.h"



@interface CVStopDetailTableViewController ()<MKMapViewDelegate,UIActionSheetDelegate,CCSignatureViewControllerDelegate,UITextFieldDelegate>
@property(nonatomic)NSArray *shipments;
@property(nonatomic)NSMutableArray *items;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *msgNavButton;
@end

@implementation CVStopDetailTableViewController


- (void)setStop:(Stop *)stop
{
    if (_stop != stop) {
        _shipments =  [stop.shipments allObjects];
        _items = [NSMutableArray new];
        _stop = stop;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView setTableFooterView:[UIView new]];
    _df = [NSDateFormatter new];
    [_df setDateFormat:@"HH:mm"];
}

-(void)viewDidAppear:(BOOL)animated{
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleTap];
    
    
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    [geocoder geocodeAddressDictionary:@{
                                         @"City":_stop.address.city,
                                         @"Zip":_stop.address.zip
                                         }
                     completionHandler:^(NSArray *placemarks, NSError *error) {
                         
                         if (error) {
                             UIAlertView *al = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Cannot find on map", nil) message:NSLocalizedString(@"Cannot find on map", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//                             [al show];
                         }else{
                             CLPlacemark *placemark = [placemarks objectAtIndex:0];
                             CLLocation *location = placemark.location;
                             MKCoordinateRegion region;
                             MKCoordinateSpan span;
                             span.latitudeDelta = 0.005;
                             span.longitudeDelta = 0.005;
                             region.span = span;
                             region.center = location.coordinate;
                             [_mapView setRegion:region animated:YES];
                             [self addAnnotationToMap:location];
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
    return ([_shipments count]+2);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;

}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 2, view.frame.size.width-20, 18)];

    [label setFont:[UIFont fontWithName:@"HelveticaNeue-light" size:12]];
    [label setTextColor:UIColorFromRGB(0x1070a9)];
    
    if (section == 0) {
        [label setText:[NSString stringWithFormat:@"%@ %@", [self.stop.type isEqualToString:@"Pick"]? NSLocalizedString(@"CollectFrom", nil) : NSLocalizedString(@"DeliverTo", nil), [NSString stringWithUTF8String:[self.stop.location_name UTF8String]]]];
    }else if (section == _shipments.count +1){
        return [UIView new];
    } else{

        Shipment *shipment = _shipments[section-1];//*************************************                                       PROBLEM for multistop loads!!!!
        
        NSString *fullString = [NSString stringWithFormat:@"%@  %@", NSLocalizedString(@"CustomerRef", nil),shipment.primary_reference_number];
        [label setText:fullString];
    }
    [view addSubview:label];
    [view setBackgroundColor:UIColorFromRGB(0xcddcec)];

    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Shipment *shipment = _shipments[indexPath.row];
    
    if ([indexPath section] == 0 ) {
        return 250;
    }
    else if ([indexPath section]== _shipments.count +1){
        return 100;
    }
    return (([shipment.items count]*70)+70);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCell" forIndexPath:indexPath];
    
    [cell.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        [subview removeFromSuperview];
    }];

    
    if ([indexPath section] == 0) {
        

        
        _mapView = [[MKMapView alloc]initWithFrame:CGRectMake(10, 10, CGRectGetWidth(cell.bounds)-20, CGRectGetHeight(cell.bounds)-20)];
        _mapView.delegate = self;
        _mapView.layer.borderColor = [UIColor colorWithWhite:.7 alpha:.3].CGColor;
        _mapView.layer.borderWidth = 1;
        
        UIView *containerView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_mapView.bounds)-60, CGRectGetWidth(_mapView.bounds), 60)];
        containerView.backgroundColor = [UIColor colorWithWhite:1 alpha:.95];
        containerView.layer.borderColor = [UIColor colorWithWhite:1 alpha:1].CGColor;
        containerView.layer.borderWidth = 3;
      
        Address *address = self.stop.address;
        
        // street
        UILabel *addressOneTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10,  5, 80, 20)];
        addressOneTitleLabel.text = NSLocalizedString(@"STREET", @"STREET");
        addressOneTitleLabel.textColor = UIColorFromRGB(0x1070a9);
        addressOneTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
        
        UILabel *addressOneLabel = [[UILabel alloc]initWithFrame:CGRectMake(90,  5, CGRectGetWidth(containerView.bounds)-20, 20)];
        addressOneLabel.text = [address.address1 length] ?  [NSString stringWithUTF8String:[address.address1 UTF8String]]:@"";
        addressOneLabel.textColor = UIColorFromRGB(0x1070a9);
        addressOneLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
        
        
        //city
        
        UILabel *cityTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 20, 80, 20)];
        cityTitleLabel.text = NSLocalizedString(@"City", @"City");
        cityTitleLabel.textColor = UIColorFromRGB(0x1070a9);
        cityTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
        
        
        UILabel *cityLabel = [[UILabel alloc]initWithFrame:CGRectMake(90, 20, CGRectGetWidth(containerView.bounds)-20, 20)];
        cityLabel.text = [address.city length] ?  [NSString stringWithUTF8String:[address.city UTF8String]] : @"";
        cityLabel.textColor = UIColorFromRGB(0x1070a9);
        cityLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
        
        //state
        
        UILabel *stateLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 35, 100, 20)];
        stateLabel.text = [address.state length] ?[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"County", nil),[NSString stringWithUTF8String:[address.state UTF8String]]] : @"";
        stateLabel.textColor = UIColorFromRGB(0x1070a9);
        stateLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
        
        //zip
        UILabel *zipTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10,  35, 80, 20)];
        zipTitleLabel.text = NSLocalizedString(@"PostCode", nil);
        zipTitleLabel.textColor = UIColorFromRGB(0x1070a9);
        zipTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
        
        
        UILabel *zipLabel = [[UILabel alloc]initWithFrame:CGRectMake(90, 35, 80, 20)];
        zipLabel.text = [address.zip length] ?  [NSString stringWithUTF8String:[address.zip UTF8String]] : @"";
        zipLabel.textColor = UIColorFromRGB(0x1070a9);
        zipLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];

        
        [containerView addSubview:addressOneTitleLabel];
        [containerView addSubview:cityTitleLabel];
        [containerView addSubview:zipTitleLabel];
        
        [containerView addSubview:zipLabel];
//        [containerView addSubview:stateLabel];
        [containerView addSubview:cityLabel];
        [containerView addSubview:addressOneLabel];
   
        [_mapView addSubview:containerView];
        cell.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
        [cell addSubview:_mapView];
        
    }else if ([indexPath section] ==  [_shipments count]+1){
        
        NSLog(@"I am gonna create the buttons, this is the index section %lu", (unsigned long)indexPath.section);
         NSLog(@"I am gonna create the buttons, this is the shipment count +1 %lu", (unsigned long)[_shipments count]+1);
        
        _checkInButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _checkInButton.frame = CGRectMake(0, 0, cell.frame.size.width/2, cell.frame.size.height);
        [_checkInButton setBackgroundColor:UIColorFromRGB(0x1070a9)];
        [_checkInButton addTarget:self action:@selector(checkMeIn:) forControlEvents:UIControlEventTouchUpInside];
        
        
        NSString *checkInLabelString = self.stop.actual_arrival ? [_df stringFromDate:self.stop.actual_arrival] : NSLocalizedString(@"Checkin button", nil);
        TOMSMorphingLabel *checkInLabel = [[TOMSMorphingLabel alloc]initWithFrame:_checkInButton.bounds];
        checkInLabel.text = checkInLabelString;
        checkInLabel.textAlignment = NSTextAlignmentCenter;
        checkInLabel.textColor = [UIColor whiteColor];
        checkInLabel.backgroundColor = [UIColor clearColor];
        [_checkInButton addSubview:checkInLabel];
        
        
        _checkOutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _checkOutButton.frame = CGRectMake(cell.frame.size.width/2, 0, cell.frame.size.width/2, cell.frame.size.height);
        [_checkOutButton setBackgroundColor:UIColorFromRGB(0x339e00)];
        [_checkOutButton addTarget:self action:@selector(checkMeOut:) forControlEvents:UIControlEventTouchUpInside];
        NSString *checkOutLabelString = self.stop.actual_departure ? [_df stringFromDate:self.stop.actual_departure] : NSLocalizedString(@"CompleteStop", nil);
        TOMSMorphingLabel *checkOutLabel = [[TOMSMorphingLabel alloc]initWithFrame:_checkOutButton.bounds];
        
        checkOutLabel.text = checkOutLabelString;
        checkOutLabel.textAlignment = NSTextAlignmentCenter;
        checkOutLabel.textColor = [UIColor whiteColor];
        checkOutLabel.backgroundColor = [UIColor clearColor];
        
        [_checkOutButton addSubview:checkOutLabel];

        [cell addSubview:_checkInButton];
        [cell addSubview:_checkOutButton];
        
    }else{

        Shipment *shipment = _shipments[indexPath.section-1];


        UIView *containerView = [[UIView alloc]initWithFrame:CGRectMake(10, 10, CGRectGetWidth(cell.bounds)-20, CGRectGetHeight(cell.bounds)-20)];
        
        UILabel *shipNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, CGRectGetWidth(containerView.bounds)-20, 20)];
        shipNumLabel.text = [NSString stringWithFormat:@"Customer Reference: %@", shipment.shipment_number];
        shipNumLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
        shipNumLabel.textColor = [UIColor colorWithWhite:.333 alpha:1];

        
        [[shipment.items allObjects]enumerateObjectsUsingBlock:^(Item *item, NSUInteger idx, BOOL *stop) {
            [_items addObject:item];
            CVShipmentView *shipmentView = [[CVShipmentView alloc]initWithFrame:CGRectMake(0, (idx)*55 , CGRectGetWidth(containerView.bounds), 50)];
            shipmentView.backgroundColor = [UIColor colorWithRed:60/255.0f green:107/255.0f blue:161/255.0f alpha:0.05f];
            shipmentView.layer.borderColor = [UIColor colorWithRed:60/255.0f green:107/255.0f blue:161/255.0f alpha:0.2f].CGColor;
            shipmentView.layer.borderWidth = 1;
            shipmentView.layer.cornerRadius = 3;
            
            
            shipmentView.desciptionLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 230, 30)];
            NSString *productString =  item.product_description;
            shipmentView.desciptionLabel.text = productString;
            shipmentView.desciptionLabel.font = [UIFont fontWithName:@"HelveticaNeue-light" size:14];
            shipmentView.desciptionLabel.textColor =  UIColorFromRGB(0x1070a9);
            
            CVItemTextField *qtyField  = [[CVItemTextField alloc]initWithFrame:CGRectMake(CGRectGetWidth(shipmentView.bounds)-60, 10, 50, 30)];
            qtyField.keyboardType = UIKeyboardTypeNumberPad;
            qtyField.text = [item.updated_pieces stringValue];
            qtyField.layer.borderColor = [UIColor whiteColor].CGColor;
            qtyField.textColor = UIColorFromRGB(0x1070a9);
            qtyField.font = [UIFont fontWithName:@"HelveticaNeue-light" size:13];
            qtyField.backgroundColor =  [UIColor colorWithWhite:1 alpha:.6];
            qtyField.layer.borderWidth = 1;
            qtyField.layer.cornerRadius = 3;
            qtyField.textAlignment = NSTextAlignmentCenter;
            qtyField.item = item;
            qtyField.delegate = self;
            
            [shipmentView addSubview:shipmentView.desciptionLabel];
            [shipmentView addSubview:qtyField];

            [containerView addSubview:shipmentView];
        }];
        
        UITextView *instructionsTextField = [[UITextView alloc]initWithFrame:CGRectMake(0, ([shipment.items count])*55, CGRectGetWidth(containerView.bounds), 80)];
        instructionsTextField.text = shipment.comments;
        instructionsTextField.editable = NO;
        instructionsTextField.layer.borderColor = [UIColor colorWithRed:60/255.0f green:107/255.0f blue:161/255.0f alpha:0.2f].CGColor;
        instructionsTextField.textColor = UIColorFromRGB(0x1070a9);
        instructionsTextField.textAlignment = NSTextAlignmentCenter;
        instructionsTextField.font = [UIFont fontWithName:@"HelveticaNeue-light" size:13];
        instructionsTextField.backgroundColor = [UIColor colorWithRed:215/255.0f green:0/255.0f blue:0/255.0f alpha:0.1f];
        instructionsTextField.layer.borderWidth = 1;
        instructionsTextField.layer.cornerRadius = 3;
        
        [containerView addSubview:instructionsTextField];
        [cell addSubview:containerView];
    }
    
    return cell;
}



#pragma mark -UIButton actions

-(void)handleSingleTap:(UIGestureRecognizer*)gesture{
    [self.view endEditing:YES];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showMessages"]) {
        CCMessageViewController *mvc = (CCMessageViewController*)segue.destinationViewController;
        [mvc setStop:self.stop];
    }else if ([segue.identifier isEqualToString:@"signatureView"]){
        CVSignatureViewController *svc = (CVSignatureViewController*)segue.destinationViewController;
        svc.delegate = self;
        svc.itemsArray = _items;
    }
}

-(void)updateButtonLabel: (UIButton*)button withText:(NSString*)title{
    [button.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        if ([subview isMemberOfClass:[TOMSMorphingLabel class]]) {
            TOMSMorphingLabel *tms = (TOMSMorphingLabel*)subview;
            tms.text = title;
        }
    }];
}
-(void)checkMeIn:(id)sender{
    if (!self.stop.actual_arrival) {
        [self showConfirmAlert];
    }
}

-(void)checkMeOut:(id)sender{
    NSLog(@"Checking out");
    if (self.stop.actual_arrival && !self.stop.actual_departure) {
        [self showConfirmAlert];
    }
}
-(void)reloadButtons{
    NSRange range = NSMakeRange(3, 1);
    NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.tableView reloadSections:section withRowAnimation:UITableViewRowAnimationFade];
}
#pragma mark UIAction sheet delegate

-(void)showConfirmAlert{
    NSString *titleString = [NSString stringWithFormat:@"%@ %@ ?", self.stop.actual_arrival? NSLocalizedString(@"CompleteStop", nil) : NSLocalizedString(@"CheckIn", nil), self.stop.location_name];
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:titleString
                                                                     delegate:self
                                                            cancelButtonTitle:NSLocalizedString(@"Yes", nil)
                                                       destructiveButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                            otherButtonTitles:nil];
            [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
       // [self reloadButtons];
    }else{
        if (!self.stop.actual_arrival && !self.stop.actual_departure) {
            self.stop.actual_arrival = [NSDate date];
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = NSLocalizedString(@"Saving Load", nil);
            
            
            [self updateButtonLabel:_checkInButton withText:[_df stringFromDate:_stop.actual_arrival]];
            [[CVChepClient sharedClient]updateStopArrival:_stop completion:^(NSError *error) {
                if(error) {
                    NSLog(@"Departure Error: %@", error);
                }else{
                    NSLog(@"update arrival time worked");
                    [hud removeFromSuperview];
                }
            }];
            
            

        }else{
            [self performSegueWithIdentifier:@"signatureView" sender:self];
        }
        
    }
}

#pragma mark Signature view delegate


-(void)cancelSignatureAndStopCompletion{
    
    [self updateButtonLabel:_checkOutButton withText:NSLocalizedString(@"CompleteStop", nil)];
}


#pragma mark Modify CCPDFWriter for multistop
-(void)signatureViewData:(NSData *)signatureData{
    self.stop.signatureSnapshot = signatureData;
    self.stop.actual_departure = [NSDate date];
    [self updateButtonLabel:_checkOutButton withText:[_df stringFromDate:_stop.actual_departure]];

    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"Saving Load", nil);
    
    if ([_stop.type isEqualToString:@"Drop"]) {
        [CVMultiPDFWriter createPDFfromStop:_stop];
        [[_stop.load.pods allObjects] enumerateObjectsUsingBlock:^(Pod *pod, NSUInteger idx, BOOL *stop) {
            
            if ([_stop.type isEqualToString:@"Drop"]) {
                NSLog(@"this is not the first pod");
                [[CVChepClient sharedClient]uploadPhoto:[NSData dataWithData:pod.data] ofType:@"pod" forStopId:_stop.id withLoadId:_stop.load.id withComment:pod.ref completion:^(NSDictionary *responseDic, NSError *error) {
                    NSLog(@"That worked");
                }];
                
                
            }
        }];
    }else{

    }
    
    [[CVChepClient sharedClient]updateStopDeparture:_stop completion:^(NSError *error) {
        if(error) {
            NSLog(@"Error: %@", error);
        }else{
            NSLog(@"update departure time worked");
            [hud removeFromSuperview];
        }
    }];
    
}

#pragma mark - TextField Delegate Methods

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return !_stop.actual_departure ? YES : NO ;
}

-(void)textFieldDidEndEditing:(CVItemTextField *)textField{
    
    NSString *newValue = [textField text];
    textField.item.updated_pieces = [NSNumber numberWithInt:[newValue intValue]];
    NSLog(@"Setting item value as: %@", newValue);
    [self.delegate saveChangesOnContext];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return  YES;
}

@end
