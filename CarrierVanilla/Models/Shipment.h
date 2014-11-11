//
//  Shipment.h
//  Chep Carrier QA
//
//  Created by shane davis on 07/11/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item, Stop;

@interface Shipment : NSManagedObject

@property (nonatomic, retain) NSString * comments;
@property (nonatomic, retain) NSString * primary_reference_number;
@property (nonatomic, retain) NSString * shipment_number;
@property (nonatomic, retain) NSSet *items;
@property (nonatomic, retain) NSSet *stops;
@end

@interface Shipment (CoreDataGeneratedAccessors)

- (void)addItemsObject:(Item *)value;
- (void)removeItemsObject:(Item *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

- (void)addStopsObject:(Stop *)value;
- (void)removeStopsObject:(Stop *)value;
- (void)addStops:(NSSet *)values;
- (void)removeStops:(NSSet *)values;

@end
