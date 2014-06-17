//
//  CCMessageViewController.h
//  ChepCarrier
//
//  Created by shane davis on 02/06/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import "SOMessagingViewController.h"
#import "Stop.h"

@interface CCMessageViewController : SOMessagingViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property(nonatomic)Stop *stop;
@end
