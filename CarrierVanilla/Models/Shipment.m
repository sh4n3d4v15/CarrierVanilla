//
//  Shipment.m
//  
//
//  Created by shane davis on 02/07/2014.
//
//

#import "Shipment.h"
#import "Item.h"
#import "Stop.h"


@implementation Shipment

@dynamic comments;
@dynamic shipment_number;
@dynamic primary_reference_number;
@dynamic items;
@dynamic stop;

-(BOOL)isFinalizedShipment{
    __block BOOL complete = YES;
    
    [self.items enumerateObjectsUsingBlock:^(Item *currentItem, BOOL *stop) {
        if (!currentItem.finalized) {
            complete = NO;
        }
    }];
    return complete;
}


@end
