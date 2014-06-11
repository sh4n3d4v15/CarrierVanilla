//
//  CVDetailViewController.h
//  CarrierVanilla
//
//  Created by shane davis on 06/06/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Stop.h"
@protocol stopChangeDelegate

-(void)saveChangesOnContext;

@end
@interface CVDetailViewController : UIViewController

@property (strong, nonatomic) Stop *stop;

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *shipment;
@property (weak, nonatomic) IBOutlet UILabel *item;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property(weak,nonatomic) id <stopChangeDelegate> delegate;
@end
