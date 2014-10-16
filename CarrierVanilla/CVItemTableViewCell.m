//
//  CVItemTableViewCell.m
//  Chep Carrier
//
//  Created by shane davis on 24/08/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import "CVItemTableViewCell.h"

@implementation CVItemTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self addStyleToView:self.textLabel];
        
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    
    UIView *containerView = [[UIView alloc]initWithFrame:CGRectMake(0, 10, self.bounds.size.width, 50)];
    
    [self addStyleToView:containerView];
    [self.contentView addSubview:containerView];
    

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)addStyleToView:(UIView*)view{
    
    self.backgroundColor = [UIColor clearColor];
    view.backgroundColor = [UIColor colorWithRed:60/255.0f green:107/255.0f blue:161/255.0f alpha:0.05f];
    view.layer.borderColor = [UIColor colorWithRed:60/255.0f green:107/255.0f blue:161/255.0f alpha:0.2f].CGColor;
    view.layer.borderWidth = 1;
    view.layer.cornerRadius = 3;
    
    _productLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, view.bounds.size.width-10, view.bounds.size.height)];
    _productLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
    _productLabel.textColor =  UIColorFromRGB(0x1070a9);
    
    [view addSubview:_productLabel];
}

@end
