//
//  CVStopTableViewCell.h
//  CarrierVanilla
//
//  Created by shane davis on 17/06/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CVStopTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *locationNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressOneLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *zipLabel;

@end
