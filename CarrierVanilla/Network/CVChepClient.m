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
        
        __unused NSURL *baseUrl = [NSURL URLWithString:@"http://chepserver.eu01.aws.af.cm"];
         NSURL *ChepBaseUrl = [NSURL URLWithString:@"http://bl-con.chep.com"];
        _sharedClient = [[CVChepClient alloc]initWithBaseURL:ChepBaseUrl];
        _sharedClient.requestSerializer = [AFJSONRequestSerializer serializer];
        
        [_sharedClient.requestSerializer setAuthorizationHeaderFieldWithUsername:@"MobiShipRestUser" password:@"M0b1Sh1pm3n743"];
      //  [_sharedClient.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"content-type"];
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
            SET_IF_NOT_NULL(load.id , [obj valueForKey:@"id"]);
            SET_IF_NOT_NULL(load.load_number, [obj valueForKey:@"load_number"]);
            SET_IF_NOT_NULL(load.status, [obj valueForKey:@"status"]);
            
            NSArray *stops = [obj objectForKey:@"stops"];
            [stops enumerateObjectsUsingBlock:^(id stopobj, NSUInteger idx, BOOL *stop) {
                Stop *_stop = [NSEntityDescription insertNewObjectForEntityForName:@"Stop" inManagedObjectContext:dmgr.managedObjectContext];
                //            [_stop setValuesForKeysWithDictionary:stopobj];
                //            _stop.location_name = [stopobj valueForKey:@"location_name"];
                SET_IF_NOT_NULL(_stop.location_name , [stopobj valueForKey:@"location_name"]);
                SET_IF_NOT_NULL(_stop.location_id, [stopobj valueForKey:@"location_id"]);
                SET_IF_NOT_NULL(_stop.location_ref, [stopobj valueForKey:@"location_ref"]);
                SET_IF_NOT_NULL(_stop.type, [stopobj valueForKey:@"type"]);
                SET_IF_NOT_NULL(_stop.planned_start, [stopobj valueForKey:@"planned_start"]);
                SET_IF_NOT_NULL(_stop.planned_end, [stopobj valueForKey:@"planned_end"]);
                SET_IF_NOT_NULL(_stop.weight, [stopobj valueForKey:@"weight"]);
                SET_IF_NOT_NULL(_stop.pallets, [stopobj valueForKey:@"pallets"]);
                SET_IF_NOT_NULL(_stop.pieces, [stopobj valueForKey:@"pieces"]);
               
                
                Address *address = [NSEntityDescription insertNewObjectForEntityForName:@"Address" inManagedObjectContext:dmgr.managedObjectContext];
                SET_IF_NOT_NULL(address.address1, [stopobj valueForKeyPath:@"address.address1"]);
                SET_IF_NOT_NULL(address.city, [stopobj valueForKeyPath:@"address.city"]);
                SET_IF_NOT_NULL(address.state, [stopobj valueForKeyPath:@"address.state"]);
                SET_IF_NOT_NULL(address.zip, [stopobj valueForKeyPath:@"address.zip"])
                SET_IF_NOT_NULL(address.country, [stopobj valueForKeyPath:@"address.country"]);
                _stop.address = address;
                
                NSArray *shipments = [stopobj valueForKey:@"shipments"];
                NSLog(@"Shipemnts in master %@", shipments);
                [shipments enumerateObjectsUsingBlock:^(id shipmentObj, NSUInteger idx, BOOL *stop) {
                    Shipment *shipment = [NSEntityDescription insertNewObjectForEntityForName:@"Shipment" inManagedObjectContext:dmgr.managedObjectContext];
                    SET_IF_NOT_NULL(shipment.shipment_number,  shipmentObj[@"shipment_number"]);
                    SET_IF_NOT_NULL(shipment.comments, shipmentObj[@"comments"]);
                    
                    NSArray *items = [shipmentObj valueForKey:@"items"];
                    [items enumerateObjectsUsingBlock:^(id itemObj, NSUInteger idx, BOOL *stop) {
                        Item *item = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:dmgr.managedObjectContext];
                        SET_IF_NOT_NULL(item.line, [itemObj valueForKey:@"line"]);
                        SET_IF_NOT_NULL(item.product_id,  [itemObj valueForKey:@"product_id"]);
                        SET_IF_NOT_NULL(item.product_description, [itemObj valueForKey:@"product_description"]);
                        SET_IF_NOT_NULL(item.commodity, [itemObj valueForKey:@"commodity"]);
                        SET_IF_NOT_NULL(item.weight, [itemObj valueForKey:@"weight"]);
                        SET_IF_NOT_NULL(item.volume, [itemObj valueForKey:@"volume"]);
                        SET_IF_NOT_NULL(item.pieces, [itemObj valueForKey:@"pieces"]);
                        SET_IF_NOT_NULL(item.lading, [itemObj valueForKey:@"lading"]);

                        [shipment addItemsObject:item];
                    }];
                    
                    [_stop addShipmentsObject:shipment];
                    [load addStopsObject:_stop];
                }];
            }];
            
            NSArray *refs = [obj valueForKey:@"refs"];
            [refs enumerateObjectsUsingBlock:^(id refobj, NSUInteger idx, BOOL *stop) {
                Ref *_ref = [NSEntityDescription insertNewObjectForEntityForName:@"Ref" inManagedObjectContext:dmgr.managedObjectContext];
                SET_IF_NOT_NULL(_ref.name, [refobj valueForKey:@"name"]);
                SET_IF_NOT_NULL(_ref.value, [refobj valueForKey:@"value"]);

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

//-(NSURLSessionDataTask *)getStopsForVehicle:(NSString *)vehicleId completion:(void (^)(NSArray *, NSError *))completion{
//    NSURLSessionDataTask *task = [self GET:@"loads" parameters:@{@"vehicle":vehicleId} success:^(NSURLSessionDataTask *task, id responseObject) {
//        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
//        NSArray *loads = [responseObject valueForKey:@"loads"];
//        if(httpResponse.statusCode == 200){
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self importArrayOfStopsIntoCoreData:loads];
//                completion(loads,nil);
//            });
//        }else{
//            dispatch_async(dispatch_get_main_queue(), ^{
//                completion(nil,nil);
//            });
//            NSLog(@"Received: %@", loads);
//            NSLog(@"Received HTTP %lo", (long)httpResponse.statusCode);
//        }
//        
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            completion(nil,error);
//        });
//    }];
//    return task;
//};


-(NSURLSessionDataTask *)getStopsForVehicle:(NSString *)vehicleId completion:(void (^)(NSArray *, NSError *))completion{
    NSLog(@"Calling the method::");
        NSString *urlString = @"/shipment_tracking_rest/jsonp/loads/uid/APItester/pwd/ZTNhNzk5MGUtM2IyYi00M2M4LThhNDct/region/eu";
        NSURLSessionDataTask *task = [self POST:urlString parameters:@{
                                                                     @"vehicle":@"TEST123",
                                                                     @"res":@"",
                                                                     @"offset":@0,
                                                                     @"limit":@50,
                                                                     @"include_stops":@YES,
                                                                     @"include_shipments":@YES,
                                                                     @"pick_start_date":@"",
                                                                     @"pick_end_date":@"",
                                                                     @"drop_start_date":@"",
                                                                     @"drop_end_date":@""}
                                      
                                        success:^(NSURLSessionDataTask *task, id responseObject) {
                                            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
                                            NSArray *loads = [responseObject valueForKey:@"loads"];
                                            NSLog(@"top response %@", responseObject);
                                            if (httpResponse.statusCode == 200) {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    [self importArrayOfStopsIntoCoreData:loads];
                                                    NSLog(@"RESONSE: %@", httpResponse);
                                                    NSLog(@"RESONSE OBJECT: %@", responseObject);
                                                    completion(responseObject,nil);
                                                });
                                            }else{
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    completion(nil,nil);
                                                    NSLog(@"Received: %@", responseObject);
                                                    NSLog(@"Received HTTP %lo", (long)httpResponse.statusCode);
                                                });
                                            }
                                        } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                completion(nil,error);
                                            });
                                        }];
    return task;
};


//-(NSURLSessionDataTask *)updateStopWithId:(NSString *)id forLoad:(NSString*)loadId withQuantity:(NSString *)quantity withActualArrival:(NSDate *)arrivalDate withActualDeparture:(NSDate*)departureDate completion:(void (^)(NSArray *, NSError *))completion{
//    NSLog(@"Update stop method fired");
//    NSString *fullUrl = [[NSString stringWithFormat:@"%@/pod/%@/%@/%@",urlString,quantity,arrivalDate ? arrivalDate : @"",departureDate ? departureDate : @""]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"FULL URL:: %@", fullUrl);
//    NSURLSessionDataTask *task = [self POST:fullUrl parameters:@{@"name":@"shane"}
//                                    success:^(NSURLSessionDataTask *task, id responseObject) {
//                                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
//                                        if (httpResponse.statusCode == 200) {
//                                            dispatch_async(dispatch_get_main_queue(), ^{
//                                                completion(responseObject,nil);
//                                            });
//                                        }else{
//                                            dispatch_async(dispatch_get_main_queue(), ^{
//                                                completion(nil,nil);
//                                                NSLog(@"Received: %@", responseObject);
//                                                NSLog(@"Received HTTP %lo", (long)httpResponse.statusCode);
//                                            });
//                                        }
//                                    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//                                        dispatch_async(dispatch_get_main_queue(), ^{
//                                            completion(nil,error);
//                                        });
//                                    }];
//    return task;
//}

#pragma mark - Documents Requests

-(NSURLSessionDataTask *)uploadPhoto:(NSData *)photoData forStopId:(NSString *)stopId withLoadId:(NSString *)loadId withComment:(NSString *)comment completion:(void (^)(NSArray *, NSError *))completion{
    
    NSURLSessionDataTask * task = [self POST:@"/photo" parameters:@{@"stopId": stopId,
                                                                    @"loadId":loadId,
                                                                    @"comment": comment}
                                     success:^(NSURLSessionDataTask *task, id responseObject) {
                                         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
                                         if (httpResponse.statusCode == 200) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 completion(responseObject,nil);
                                             });
                                         }else{
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 completion(nil,nil);
                                                 NSLog(@"Recieved: %@", responseObject);
                                                 NSLog(@"Recieved HTTP %lo", (long)httpResponse.statusCode);
                                             });
                                         }
                                     } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             completion(nil,error);
                                         });
                                     }];
    return task;
}

#pragma mark - Load Note Requests

-(NSURLSessionDataTask *)getLoadNotesForLoad:(NSString *)loadId completion:(void (^)(NSArray *, NSError *))completion{
    NSURLSessionDataTask *task = [self GET:@"/loadnotes" parameters:@{@"loadId": loadId}
                                   success:^(NSURLSessionDataTask *task, id responseObject) {
                                       NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
                                       if (httpResponse.statusCode == 200) {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               completion(responseObject,nil);
                                           });
                                       }else{
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               completion(nil,nil);
                                               NSLog(@"Received: %@", responseObject);
                                               NSLog(@"Received HTTP %lo", (long)httpResponse.statusCode);
                                           });
                                       }
                                       
                                   } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           completion(nil,error);
                                       });
                                   }];
    return task;
}

-(NSURLSessionDataTask *)postLoadNoteForLoad:(NSString *)loadId withNoteType:(NSString *)noteType withStopType:(NSString *)stopType withMessage:(NSString *)message completion:(void (^)(NSArray *, NSError *))completion{
    
    NSURLSessionDataTask *task = [self POST:@"loadnote" parameters:@{@"loadId": loadId,
                                                                     @"noteType": noteType,
                                                                     @"stopType":stopType,
                                                                     @"message":message}
                                    success:^(NSURLSessionDataTask *task, id responseObject) {
                                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
                                        if (httpResponse.statusCode == 200) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                completion(responseObject,nil);
                                            });
                                        }else{
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                completion(nil,nil);
                                                NSLog(@"Recieved: %@",responseObject);
                                                NSLog(@"Recieved HTTP %lo",(long)httpResponse.statusCode);
                                            });
                                        }
                                    } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            completion(nil,error);
                                        });
                                    }];
    return task;
}
#pragma mark Todo: Change this method to 'complete load'
- (NSURLSessionDataTask *)completeStop:(Stop*)stop withDocData: (NSData*)podData completion:( void(^)(BOOL, NSError*) )completion {
    NSURLSessionDataTask *task =  [self POST:@"/"
                                  parameters:nil
                   constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                       [formData appendPartWithFileData:podData
                                                   name:[NSString stringWithFormat:@"%@.pdf",stop.id]
                                               fileName:[NSString stringWithFormat:@"%@.pdf",stop.id]
                                               mimeType:@"application/pdf"];
                   }
                                     success:^(NSURLSessionDataTask *task,
                                               id responseObject) { NSLog(@"Success"); }
                                     failure:^(NSURLSessionDataTask *task,
                                               NSError *error) { NSLog(@"error"); }];
    return task;
}

@end
