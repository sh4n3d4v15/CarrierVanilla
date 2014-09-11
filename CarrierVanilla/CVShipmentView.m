//
//  CVShipmentView.m
//  Chep Carrier
//
//  Created by shane davis on 22/08/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import "CVShipmentView.h"
#import "UIColor+MLPFLatColors.h"
@implementation CVShipmentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeToRed:) name:@"changeToRedNotification" object:nil];
    }
    return self;
}

-(void)changeToRed:(NSNotification*)note{
    NSLog(@"Changing to red%@",note);
    self.backgroundColor = [UIColor colorWithRed:60/255.0f green:107/255.0f blue:161/255.0f alpha:0.05f];
    self.desciptionLabel.textColor = UIColorFromRGB(0xc0392b);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
