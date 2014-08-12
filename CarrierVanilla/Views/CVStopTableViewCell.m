//
//  CVStopTableViewCell.m
//  CarrierVanilla
//
//  Created by shane davis on 17/06/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import "CVStopTableViewCell.h"

@implementation CVStopTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
