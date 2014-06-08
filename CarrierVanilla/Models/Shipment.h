//
//  Shipment.h
//  CarrierVanilla
//
//  Created by shane davis on 06/06/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item, Stop;

@interface Shipment : NSManagedObject

@property (nonatomic, retain) NSString * shipment_number;
@property (nonatomic, retain) NSString * comments;
@property (nonatomic, retain) Stop *stop;
@property (nonatomic, retain) NSSet *items;
@end

@interface Shipment (CoreDataGeneratedAccessors)

- (void)addItemsObject:(Item *)value;
- (void)removeItemsObject:(Item *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
