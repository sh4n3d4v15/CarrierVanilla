//
//  MLChepClient.m
//  MobileLogistics
//
//  Created by shane davis on 05/06/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import "CVChepClient.h"
#import "CVAppDelegate.h"
#import "Stop.h"
#import "Load.h"
#import "Address.h"
#import "Ref.h"
#import "Shipment.h"
#import "Item.h"
@implementation CVChepClient
+(CVChepClient *)sharedClient{
    static CVChepClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *baseUrl = [NSURL URLWithString:@"http://chepserver.eu01.aws.af.cm"];
        _sharedClient = [[CVChepClient alloc]initWithBaseURL:baseUrl];
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            NSOperationQueue *operationQueue = _sharedClient.operationQueue;
            switch (status) {
                case AFNetworkReachabilityStatusReachableViaWWAN:
                case AFNetworkReachabilityStatusReachableViaWiFi:
                    [operationQueue setSuspended:NO];
                    break;
                case AFNetworkReachabilityStatusNotReachable:
                default:
                    [operationQueue setSuspended:YES];
                    break;
            }
            NSLog(@"Reachability %@", AFStringFromNetworkReachabilityStatus(status));
        }];
    });
    [[AFNetworkReachabilityManager sharedManager]startMonitoring];
    return _sharedClient;
}

#define SET_IF_NOT_NULL(TARGET, VAL) if(VAL != [NSNull null]) { TARGET = VAL; }
- (void)importArrayOfStopsIntoCoreData:(NSArray*)resultsArray
{
    CVAppDelegate *dmgr = (CVAppDelegate *)[UIApplication sharedApplication].delegate;
    
    
    NSString *predicateString = [NSString stringWithFormat:@"load_number == $LOAD_NUMBER"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
    
    
    [resultsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop) {
        NSDictionary *variables = @{@"LOAD_NUMBER": [obj valueForKey:@"load_number"]};
        NSPredicate *localPredicate = [predicate predicateWithSubstitutionVariables:variables];
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Load"];
        NSError *error;
        [fetchRequest setPredicate:localPredicate];
        NSArray *foundLoads = [dmgr.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if (![foundLoads count]) {
            
            Load *load = [NSEntityDescription insertNewObjectForEntityForName:@"Load" inManagedObjectContext:dmgr.managedObjectContext];
            load.id = [obj valueForKey:@"id"];
            load.load_number = [obj valueForKey:@"load_number"];
            load.status = [obj valueForKey:@"status"];
            
            NSArray *stops = [obj objectForKey:@"stops"];
            [stops enumerateObjectsUsingBlock:^(id stopobj, NSUInteger idx, BOOL *stop) {
                Stop *_stop = [NSEntityDescription insertNewObjectForEntityForName:@"Stop" inManagedObjectContext:dmgr.managedObjectContext];
                //            [_stop setValuesForKeysWithDictionary:stopobj];
                //            _stop.location_name = [stopobj valueForKey:@"location_name"];
                SET_IF_NOT_NULL(_stop.location_name , [stopobj valueForKey:@"location_name"]);
                _stop.location_id = [stopobj valueForKey:@"location_id"];
                _stop.location_ref = [stopobj valueForKey:@"location_ref"];
                _stop.type = [stopobj valueForKey:@"type"];
                _stop.planned_start = [stopobj valueForKey:@"planned_start"];
                _stop.planned_end = [stopobj valueForKey:@"planned_end"];
                _stop.weight = [stopobj valueForKey:@"weight"];
                _stop.pallets = [stopobj valueForKey:@"pallets"];
                _stop.pieces = [stopobj valueForKey:@"pieces"];
                
                Address *address = [NSEntityDescription insertNewObjectForEntityForName:@"Address" inManagedObjectContext:dmgr.managedObjectContext];
                address.address1 = [stopobj valueForKeyPath:@"address.address1"];
                _stop.address = address;
                
                NSArray *shipments = [stopobj valueForKey:@"shipments"];
                NSLog(@"Shipemnts in master %@", shipments);
                [shipments enumerateObjectsUsingBlock:^(id shipmentObj, NSUInteger idx, BOOL *stop) {
                    Shipment *shipment = [NSEntityDescription insertNewObjectForEntityForName:@"Shipment" inManagedObjectContext:dmgr.managedObjectContext];
                    shipment.shipment_number = shipmentObj[@"Shipment_number"];
                    shipment.comments = shipmentObj[@"comments"];
                    
                    NSArray *items = [shipmentObj valueForKey:@"items"];
                    [items enumerateObjectsUsingBlock:^(id itemObj, NSUInteger idx, BOOL *stop) {
                        Item *item = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:dmgr.managedObjectContext];
                        item.line = [itemObj valueForKey:@"line"];
                        item.product_id = [itemObj valueForKey:@"product_id"];
                        item.product_description = [itemObj valueForKey:@"product_description"];
                        item.commodity = [itemObj valueForKey:@"commodity"];
                        item.weight = [itemObj valueForKey:@"weight"];
                        item.volume = [itemObj valueForKey:@"volume"];
                        item.pieces = [itemObj valueForKey:@"pieces"];
                        item.lading = [itemObj valueForKey:@"lading"];
                        [shipment addItemsObject:item];
                    }];
                    
                    [_stop addShipmentsObject:shipment];
                    [load addStopsObject:_stop];
                }];
            }];
            
            NSArray *refs = [obj valueForKey:@"refs"];
            [refs enumerateObjectsUsingBlock:^(id refobj, NSUInteger idx, BOOL *stop) {
                Ref *_ref = [NSEntityDescription insertNewObjectForEntityForName:@"Ref" inManagedObjectContext:dmgr.managedObjectContext];
                _ref.name = [refobj valueForKey:@"name"];
                _ref.value = [refobj valueForKey:@"value"];
                [load addRefsObject:_ref];
            }];
        }else{
            NSLog(@"I stopped this from being duplicated: %@", foundLoads);
        }
    }];
    
    NSError* error = nil;
    if (![dmgr.managedObjectContext save:&error]) {
        NSLog(@"Unable to save context for class");
    } else {
        NSLog(@"saved all records!");
    }
}


#pragma mark - Stop Requests

-(NSURLSessionDataTask *)getStopsForVehicle:(NSString *)vehicleId completion:(void (^)(NSArray *, NSError *))completion{
    NSURLSessionDataTask *task = [self GET:@"loads" parameters:@{@"vehicle":vehicleId} success:^(NSURLSessionDataTask *task, id responseObject) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
        NSArray *loads = [responseObject valueForKey:@"loads"];
        if(httpResponse.statusCode == 200){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self importArrayOfStopsIntoCoreData:loads];
                completion(loads,nil);
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil,nil);
            });
            NSLog(@"Received: %@", loads);
            NSLog(@"Received HTTP %lo", (long)httpResponse.statusCode);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil,error);
        });
    }];
    return task;
};
@end
