//
//  CVItemLongPress.h
//  CarrierVanilla
//
//  Created by shane davis on 06/07/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"
@interface CVItemLongPress : UILongPressGestureRecognizer
@property(nonatomic)Item  *item;
@end
