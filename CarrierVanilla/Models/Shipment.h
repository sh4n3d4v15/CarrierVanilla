//
//  Shipment.h
//  
//
//  Created by shane davis on 02/07/2014.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item, Stop;

@interface Shipment : NSManagedObject

@property (nonatomic, retain) NSString * comments;
@property (nonatomic, retain) NSString * shipment_number;
@property (nonatomic, retain) NSString * primary_reference_number;
@property (nonatomic, retain) NSSet *items;
@property (nonatomic, retain) Stop *stop;
@end

@interface Shipment (CoreDataGeneratedAccessors)

- (void)addItemsObject:(Item *)value;
- (void)removeItemsObject:(Item *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;
-(BOOL)isFinalizedShipment;
@end
