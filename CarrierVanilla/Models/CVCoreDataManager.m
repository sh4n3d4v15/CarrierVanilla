//
//  MLCoreDataManager.m
//  MobileLogistics
//
//  Created by shane davis on 28/10/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import "CVCoreDataManager.h"
#import "Load.h"
#import "Stop.h"
#import "Shipment.h"
#import "Item.h"
#import "Address.h"
#import "Ref.h"
#import "Pod.h"

#define SET_IF_NOT_NULL(TARGET, VAL) if (VAL != [NSNull null]) { TARGET = VAL; }
@implementation CVCoreDataManager

+ (CVCoreDataManager *)sharedClient {
	static CVCoreDataManager *_sharedClient = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
	    _sharedClient = [[CVCoreDataManager alloc] init];
	});
	_sharedClient.dateFormatter = [[NSDateFormatter alloc]init];
	[_sharedClient.dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
	[_sharedClient.dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];

	return _sharedClient;
}

- (NSArray *)allLoads {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Load" inManagedObjectContext:_managedObjectContext];
	[fetchRequest setEntity:entity];

	NSError *error;
	NSArray *loads = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];

	return loads;
}

- (void)deleteAllCompletedLocalCompletedAndDeassignedLoads:(NSArray *)networkResults  {
    
    
	NSArray *loadIdsArray = [networkResults valueForKey:@"load_number"];
	NSArray *loads = [self allLoads];

	for (Load *load in loads) {
		if ([load isCompletedLoad]) {
			[_managedObjectContext deleteObject:load];
		}
		else if (![loadIdsArray containsObject:load.load_number]) {
			[_managedObjectContext deleteObject:load];
		}
	}

	NSError *error;
	if (![_managedObjectContext save:&error]) {
		NSLog(@"Error deleting - error:%@", error);
	}
}

- (void)importArrayOfStopsIntoCoreData:(NSArray *)resultsArray {
	[self deleteAllCompletedLocalCompletedAndDeassignedLoads:resultsArray];


	NSString *predicateString = [NSString stringWithFormat:@"load_number == $LOAD_NUMBER"];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];

	[resultsArray enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
	    NSDictionary *variables = @{ @"LOAD_NUMBER": [obj valueForKey:@"load_number"] };
	    NSPredicate *localPredicate = [predicate predicateWithSubstitutionVariables:variables];
	    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Load"];
	    NSError *error;
	    [fetchRequest setPredicate:localPredicate];
	    NSArray *foundLoads = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];

	    if (![foundLoads count]) {
	        Load *load = [NSEntityDescription insertNewObjectForEntityForName:@"Load" inManagedObjectContext:_managedObjectContext];
	        SET_IF_NOT_NULL(load.id, [obj valueForKey:@"id"]);
	        SET_IF_NOT_NULL(load.load_number, [obj valueForKey:@"load_number"]);
	        SET_IF_NOT_NULL(load.status, [obj valueForKey:@"status"]);
	        NSString *driver = [obj valueForKey:@"driver"];
	        load.driver = driver ? : @"?";

	        NSArray *stops = [obj objectForKey:@"stops"];

	        [stops enumerateObjectsUsingBlock: ^(id stopobj, NSUInteger idx, BOOL *stop) {
	            Stop *_stop = [NSEntityDescription insertNewObjectForEntityForName:@"Stop" inManagedObjectContext:_managedObjectContext];
	            //            [_stop setValuesForKeysWithDictionary:stopobj];
	            SET_IF_NOT_NULL(_stop.location_name, [stopobj valueForKey:@"location_name"]);
	            SET_IF_NOT_NULL(_stop.id, [stopobj valueForKey:@"id"]);
	            SET_IF_NOT_NULL(_stop.location_id, [stopobj valueForKey:@"location_id"]);
	            SET_IF_NOT_NULL(_stop.location_ref, [stopobj valueForKey:@"location_ref"]);
	            SET_IF_NOT_NULL(_stop.type, [stopobj valueForKey:@"type"]);
	            ///do we get values returned without dates?

	            NSString *startdatestring = [[stopobj valueForKey:@"planned_start"] substringWithRange:NSMakeRange(0, [[stopobj valueForKey:@"planned_start"] length] - 0)];
	            NSString *enddatestring = [[stopobj valueForKey:@"planned_end"] substringWithRange:NSMakeRange(0, [[stopobj valueForKey:@"planned_end"] length] - 0)];
	            _stop.planned_start =  [_dateFormatter dateFromString:startdatestring];
	            _stop.planned_end =  [_dateFormatter dateFromString:enddatestring];

	            SET_IF_NOT_NULL(_stop.weight, [stopobj valueForKey:@"weight"]);
	            SET_IF_NOT_NULL(_stop.pallets, [stopobj valueForKey:@"pallets"]);
	            SET_IF_NOT_NULL(_stop.pieces, [stopobj valueForKey:@"pieces"]);

	            _stop.actual_arrival =  [_dateFormatter dateFromString:[[stopobj valueForKey:@"actual_arrival"] substringWithRange:NSMakeRange(0, [[stopobj valueForKey:@"actual_arrival"] length] - 6)]] ? : Nil;
	            _stop.actual_departure =  [_dateFormatter dateFromString:[[stopobj valueForKey:@"actual_departure"] substringWithRange:NSMakeRange(0, [[stopobj valueForKey:@"actual_departure"] length] - 6)]] ? : Nil;


	            Address *address = [NSEntityDescription insertNewObjectForEntityForName:@"Address" inManagedObjectContext:_managedObjectContext];
	            SET_IF_NOT_NULL(address.address1, [stopobj valueForKeyPath:@"address.address1"]);
	            SET_IF_NOT_NULL(address.city, [stopobj valueForKeyPath:@"address.city"]);
	            SET_IF_NOT_NULL(address.state, [stopobj valueForKeyPath:@"address.state"]);
	            SET_IF_NOT_NULL(address.zip, [stopobj valueForKeyPath:@"address.zip"])
	            SET_IF_NOT_NULL(address.country, [stopobj valueForKeyPath:@"address.country"]);
	            _stop.address = address;

	            NSArray *shipments = [stopobj valueForKey:@"shipments"];

	            [shipments enumerateObjectsUsingBlock: ^(id shipmentObj, NSUInteger idx, BOOL *stop) {
	                Shipment *shipment = [NSEntityDescription insertNewObjectForEntityForName:@"Shipment" inManagedObjectContext:_managedObjectContext];
	                SET_IF_NOT_NULL(shipment.shipment_number,  shipmentObj[@"shipment_number"]);
	                SET_IF_NOT_NULL(shipment.comments, shipmentObj[@"comments"]);
	                SET_IF_NOT_NULL(shipment.primary_reference_number, shipmentObj[@"primary_reference_number"]);

	                NSArray *items = [shipmentObj valueForKey:@"items"];
	                [items enumerateObjectsUsingBlock: ^(id itemObj, NSUInteger idx, BOOL *stop) {
	                    Item *item = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:_managedObjectContext];
	                    SET_IF_NOT_NULL(item.line, [itemObj valueForKey:@"line"]);
	                    SET_IF_NOT_NULL(item.product_id,  [itemObj valueForKey:@"product_id"]);
	                    SET_IF_NOT_NULL(item.product_description, [itemObj valueForKey:@"product_description"]);
	                    SET_IF_NOT_NULL(item.commodity, [itemObj valueForKey:@"commodity"]);
	                    SET_IF_NOT_NULL(item.weight, [itemObj valueForKey:@"weight"]);
	                    SET_IF_NOT_NULL(item.volume, [itemObj valueForKey:@"volume"]);
	                    SET_IF_NOT_NULL(item.pieces, [itemObj valueForKey:@"pieces"]);
	                    SET_IF_NOT_NULL(item.updated_pieces, [itemObj valueForKey:@"pieces"]);
	                    SET_IF_NOT_NULL(item.lading, [itemObj valueForKey:@"lading"]);

	                    [shipment addItemsObject:item];
					}];     ///ITEMS LOOP

	                [_stop addShipmentsObject:shipment];
	                //                    [load addStopsObject:_stop];
				}]; // end of shipment enumberation
	            [load addStopsObject:_stop];
			}];

	        NSArray *refs = [obj valueForKey:@"refs"];
	        [refs enumerateObjectsUsingBlock: ^(id refobj, NSUInteger idx, BOOL *stop) {
	            Ref *_ref = [NSEntityDescription insertNewObjectForEntityForName:@"Ref" inManagedObjectContext:_managedObjectContext];
	            SET_IF_NOT_NULL(_ref.name, [refobj valueForKey:@"name"]);
	            SET_IF_NOT_NULL(_ref.value, [refobj valueForKey:@"value"]);

	            [load addRefsObject:_ref];
			}];
		} //end of if loads found
	}];

	NSError *error = nil;
	if (![_managedObjectContext save:&error]) {
	}
	else {
	}
}

@end
