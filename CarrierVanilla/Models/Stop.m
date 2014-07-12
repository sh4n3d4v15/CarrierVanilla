//
//  Stop.m
//  CarrierVanilla
//
//  Created by shane davis on 27/06/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import "Stop.h"
#import "Address.h"
#import "Load.h"
#import "Loadnote.h"
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
@dynamic location_id;
@dynamic location_name;
@dynamic location_ref;
@dynamic pallets;
@dynamic pieces;
@dynamic planned_end;
@dynamic planned_start;
@dynamic signatureSnapshot;
@dynamic type;
@dynamic volume;
@dynamic weight;
@dynamic latitude;
@dynamic longitude;
@dynamic address;
@dynamic load;
@dynamic shipments;
@dynamic loadNotes;

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
