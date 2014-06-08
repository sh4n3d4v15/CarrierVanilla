//
//  CVDetailViewController.h
//  CarrierVanilla
//
//  Created by shane davis on 06/06/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol stopChangeDelegate

-(void)saveChangesOnContext;

@end
@interface CVDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property(weak,nonatomic) id <stopChangeDelegate> delegate;
@end
