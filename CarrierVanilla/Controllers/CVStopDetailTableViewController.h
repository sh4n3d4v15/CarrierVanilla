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
@protocol stopChangeDelegate

-(void)saveChangesOnContext;

@end

@interface CVStopDetailTableViewController : UITableViewController<MKMapViewDelegate>
@property (strong, nonatomic) Stop *stop;
@property(weak,nonatomic) id <stopChangeDelegate> delegate;
@end
