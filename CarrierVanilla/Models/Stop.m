//
//  Stop.m
//  Chep Carrier
//
//  Created by shane davis on 07/08/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import "Stop.h"
#import "Address.h"
#import "Load.h"
#import "Shipment.h"
#import "Item.h"


@implementation Stop

@dynamic active;
@dynamic actual_arrival;
@dynamic actual_departure;
@dynamic departure_location;
@dynamic eta;
@dynamic href;
@dynamic id;
@dynamic latitude;
@dynamic location_id;
@dynamic location_name;
@dynamic location_ref;
@dynamic longitude;
@dynamic pallets;
@dynamic pieces;
@dynamic planned_end;
@dynamic planned_start;
@dynamic signatureSnapshot;
@dynamic type;
@dynamic volume;
@dynamic weight;
@dynamic address;
@dynamic load;
@dynamic shipments;
-(BOOL)isFinalizedShipment{
    __block BOOL complete = YES;
    
    [[self.shipments allObjects]enumerateObjectsUsingBlock:^(Shipment *shipment, NSUInteger idx, BOOL *stop) {
        [[shipment.items allObjects]enumerateObjectsUsingBlock:^(Item *currentItem, NSUInteger idx, BOOL *stop) {
            if (!currentItem.finalized) {
                complete = NO;
            }
        }];
    }];
    
    return complete;
}
@end
