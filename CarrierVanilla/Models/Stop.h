//
//  Stop.h
//  CarrierVanilla
//
//  Created by shane davis on 18/06/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Address, Load, Shipment;

@interface Stop : NSManagedObject

@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSString * actual_arrival;
@property (nonatomic, retain) NSString * actual_departure;
@property (nonatomic, retain) NSData * departure_location;
@property (nonatomic, retain) NSString * eta;
@property (nonatomic, retain) NSString * href;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * location_id;
@property (nonatomic, retain) NSString * location_name;
@property (nonatomic, retain) NSString * location_ref;
@property (nonatomic, retain) NSNumber * pallets;
@property (nonatomic, retain) NSNumber * pieces;
@property (nonatomic, retain) NSString * planned_end;
@property (nonatomic, retain) NSString * planned_start;
@property (nonatomic, retain) NSData * signatureSnapshot;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * volume;
@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) Address *address;
@property (nonatomic, retain) Load *load;
@property (nonatomic, retain) NSSet *shipments;
@end

@interface Stop (CoreDataGeneratedAccessors)

- (void)addShipmentsObject:(Shipment *)value;
- (void)removeShipmentsObject:(Shipment *)value;
- (void)addShipments:(NSSet *)values;
- (void)removeShipments:(NSSet *)values;

@end
