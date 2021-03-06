//
//  CVStopDetailTableViewController.h
//  CarrierVanilla
//
//  Created by shane davis on 13/06/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Stop.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol stopChangeDelegate

-(void)saveChangesOnContext;
-(void)rollbackChanges;

@end

@interface CVStopDetailTableViewController : UITableViewController
@property (strong, nonatomic) Stop *stop;
@property(weak,nonatomic) id <stopChangeDelegate> delegate;
@property(nonatomic)MKMapView *mapView;
@property(nonatomic)UIButton *checkInButton;
@property(nonatomic)UIButton *checkOutButton;

@property(nonatomic)NSDateFormatter *df;
@end
