//
//  MLChepClient.m
//  MobileLogistics
//
//  Created by shane davis on 05/06/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import "CVChepClient.h"
#import "CVAppDelegate.h"

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

        NSURL *ChepBaseUrl = [NSURL URLWithString:@"http://bl-con.chep.com"];
        _sharedClient = [[CVChepClient alloc]initWithBaseURL:ChepBaseUrl];
        _sharedClient.requestSerializer = [AFJSONRequestSerializer serializer];
        _sharedClient.requestSerializer.stringEncoding = NSUTF8StringEncoding;
        [[AFNetworkReachabilityManager sharedManager]startMonitoring];
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
    
    _sharedClient.dateFormatter = [[NSDateFormatter alloc]init];

    return _sharedClient;
}

#define SET_IF_NOT_NULL(TARGET, VAL) if(VAL != [NSNull null]) { TARGET = VAL; }

- (void) deleteAllObjects: (NSString *) entityDescription comparingNetworkResults:(NSArray*)networkResults  {
    CVAppDelegate *del =  (CVAppDelegate *)[UIApplication sharedApplication].delegate;
      self.moc = del.managedObjectContext;
    
    NSArray *loadIdsArray = [networkResults valueForKey:@"load_number"];
    NSLog(@"Entity description: %@", entityDescription);
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:self.moc];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [self.moc executeFetchRequest:fetchRequest error:&error];
    
    
    for (Load *load in items) {
        if([load isCompletedLoad]){
            [self.moc deleteObject:load];
            NSLog(@"%@ object deleted",entityDescription);
        }else if (![loadIdsArray containsObject:load.load_number]){
            [self.moc deleteObject:load];
            NSLog(@"%@ object deleted",entityDescription);
        }
    }
    if (![self.moc save:&error]) {
    	NSLog(@"Error deleting %@ - error:%@",entityDescription,error);
    }
    
}

- (void)importArrayOfStopsIntoCoreData:(NSArray*)resultsArray
{
    [self deleteAllObjects:@"Load" comparingNetworkResults:resultsArray];
    
    
    NSString *predicateString = [NSString stringWithFormat:@"load_number == $LOAD_NUMBER"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
    
    [resultsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop) {
        
        NSDictionary *variables = @{@"LOAD_NUMBER": [obj valueForKey:@"load_number"]};
        NSPredicate *localPredicate = [predicate predicateWithSubstitutionVariables:variables];
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Load"];
        NSError *error;
        [fetchRequest setPredicate:localPredicate];
        NSArray *foundLoads = [_moc executeFetchRequest:fetchRequest error:&error];
        
        if (![foundLoads count]) {
            
            Load *load = [NSEntityDescription insertNewObjectForEntityForName:@"Load" inManagedObjectContext:_moc];
            SET_IF_NOT_NULL(load.id , [obj valueForKey:@"id"]);
            SET_IF_NOT_NULL(load.load_number, [obj valueForKey:@"load_number"]);
            SET_IF_NOT_NULL(load.status, [obj valueForKey:@"status"]);
            
            NSArray *stops = [obj objectForKey:@"stops"];
            [stops enumerateObjectsUsingBlock:^(id stopobj, NSUInteger idx, BOOL *stop) {
                Stop *_stop = [NSEntityDescription insertNewObjectForEntityForName:@"Stop" inManagedObjectContext:_moc];
                //            [_stop setValuesForKeysWithDictionary:stopobj];
                SET_IF_NOT_NULL(_stop.location_name , [stopobj valueForKey:@"location_name"]);
                SET_IF_NOT_NULL(_stop.id , [stopobj valueForKey:@"id"]);
                SET_IF_NOT_NULL(_stop.location_id, [stopobj valueForKey:@"location_id"]);
                SET_IF_NOT_NULL(_stop.location_ref, [stopobj valueForKey:@"location_ref"]);
                SET_IF_NOT_NULL(_stop.type, [stopobj valueForKey:@"type"]);
                SET_IF_NOT_NULL(_stop.planned_start, [stopobj valueForKey:@"planned_start"]);
                SET_IF_NOT_NULL(_stop.planned_end, [stopobj valueForKey:@"planned_end"]);
                SET_IF_NOT_NULL(_stop.weight, [stopobj valueForKey:@"weight"]);
                SET_IF_NOT_NULL(_stop.pallets, [stopobj valueForKey:@"pallets"]);
                SET_IF_NOT_NULL(_stop.pieces, [stopobj valueForKey:@"pieces"]);
               
                
                Address *address = [NSEntityDescription insertNewObjectForEntityForName:@"Address" inManagedObjectContext:_moc];
                SET_IF_NOT_NULL(address.address1, [stopobj valueForKeyPath:@"address.address1"]);
                SET_IF_NOT_NULL(address.city, [stopobj valueForKeyPath:@"address.city"]);
                SET_IF_NOT_NULL(address.state, [stopobj valueForKeyPath:@"address.state"]);
                SET_IF_NOT_NULL(address.zip, [stopobj valueForKeyPath:@"address.zip"])
                SET_IF_NOT_NULL(address.country, [stopobj valueForKeyPath:@"address.country"]);
                _stop.address = address;
                
                NSArray *shipments = [stopobj valueForKey:@"shipments"];
                NSLog(@"Shipemnts in master %@", shipments);
                [shipments enumerateObjectsUsingBlock:^(id shipmentObj, NSUInteger idx, BOOL *stop) {
                    Shipment *shipment = [NSEntityDescription insertNewObjectForEntityForName:@"Shipment" inManagedObjectContext:_moc];
                    SET_IF_NOT_NULL(shipment.shipment_number,  shipmentObj[@"shipment_number"]);
                    SET_IF_NOT_NULL(shipment.comments, shipmentObj[@"comments"]);
                    SET_IF_NOT_NULL(shipment.primary_reference_number, shipmentObj[@"primary_reference_number"]);
                    
                    NSArray *items = [shipmentObj valueForKey:@"items"];
                    [items enumerateObjectsUsingBlock:^(id itemObj, NSUInteger idx, BOOL *stop) {
                        Item *item = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:_moc];
                        SET_IF_NOT_NULL(item.line, [itemObj valueForKey:@"line"]);
                        SET_IF_NOT_NULL(item.product_id,  [itemObj valueForKey:@"product_id"]);
                        SET_IF_NOT_NULL(item.product_description, [itemObj valueForKey:@"product_description"]);
                        SET_IF_NOT_NULL(item.commodity, [itemObj valueForKey:@"commodity"]);
                        SET_IF_NOT_NULL(item.weight, [itemObj valueForKey:@"weight"]);
                        SET_IF_NOT_NULL(item.volume, [itemObj valueForKey:@"volume"]);
                        SET_IF_NOT_NULL(item.pieces, [itemObj valueForKey:@"pieces"]);
                        SET_IF_NOT_NULL(item.lading, [itemObj valueForKey:@"lading"]);

                        [shipment addItemsObject:item];
                    }];///ITEMS LOOP
                    
                    NSLog(@"SHIPMENT ITEMS: %@", [shipment.items allObjects]);
                    [_stop addShipmentsObject:shipment];
                    [load addStopsObject:_stop];
                }];
            }];
            
            NSArray *refs = [obj valueForKey:@"refs"];
            [refs enumerateObjectsUsingBlock:^(id refobj, NSUInteger idx, BOOL *stop) {
                Ref *_ref = [NSEntityDescription insertNewObjectForEntityForName:@"Ref" inManagedObjectContext:_moc];
                SET_IF_NOT_NULL(_ref.name, [refobj valueForKey:@"name"]);
                SET_IF_NOT_NULL(_ref.value, [refobj valueForKey:@"value"]);

                [load addRefsObject:_ref];
            }];
        }//end of if loads found
    }];
    
    NSError* error = nil;
    if (![_moc save:&error]) {
        NSLog(@"Unable to save context for class");
    } else {
        NSLog(@"saved all records!");
    }
        
}


#pragma mark - Stop Requests


-(NSURLSessionDataTask *)getStopsForUser:(NSDictionary *)userinfo completion:(void (^)(NSString *, NSError *))completion{
        [self.operationQueue setSuspended:NO];
        NSString *username = [userinfo valueForKey:@"carrier"];
        NSString *password = [userinfo valueForKey:@"password"];
    
        NSLog(@"The username is %@ and the password is %@", username , password);
    
        [self.requestSerializer setAuthorizationHeaderFieldWithUsername:username password:password];
        //[self.requestSerializer setAuthorizationHeaderFieldWithUsername: password:[userinfo valueForKey:@"password"]];

        NSString *urlString = @"/shipment_tracking_rest/jsonp/loads/uid/APItester/pwd/ZTNhNzk5MGUtM2IyYi00M2M4LThhNDct/region/eu";
        NSLog(@"Vheicle selected: %@", userinfo );
        NSURLSessionDataTask *task = [self POST:urlString parameters:@{
                                                                     @"vehicle":[userinfo valueForKey:@"vehicle"],
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
                                            NSLog(@"Success");
                                            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
                                            NSArray *loads = [responseObject valueForKey:@"loads"];
                                            NSLog(@"top response %@", responseObject);
                                            if (httpResponse.statusCode == 200) {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    NSLog(@"REPONSE::::: %@", responseObject);
                                                    if (![loads count]) {
                                                        completion(@"No Loads For This Vehicle", nil);
                                                    }else{
                                                         [self importArrayOfStopsIntoCoreData:loads];
                                                    }
                                                    completion(@"all is good with 200 in da hood",nil);
                                                });
                                            }else{
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    completion(@"Something unexplained happened",nil);
                                                    NSLog(@"Received: %@", responseObject);
                                                    NSLog(@"Received HTTP %lo", (long)httpResponse.statusCode);
                                                });
                                            }
                                        } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                           NSLog(@"Failure");
                                             NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
                                            NSLog(@"STATUS: %li", (long)httpResponse.statusCode);
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                
                                                if (httpResponse.statusCode == 401) {
                                                    completion(@"User login not successful", error);
                                                }else{
                                                    completion(@"Network connection error", error);
                                                }
//                                                NSError *error;
//                                                NSString *filepath = [[NSBundle mainBundle]pathForResource:@"loads" ofType:@"json"];
//                                                NSString *loadsJson = [[NSString alloc]initWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error];
//                                                NSData *loadsData = [loadsJson dataUsingEncoding:NSUTF8StringEncoding];
//                                                NSArray *loadsArray = [NSJSONSerialization JSONObjectWithData:loadsData options:0 error:&error];
//                                                [self importArrayOfStopsIntoCoreData:loadsArray];
//                                                NSLog(@"LoadsArray %@", loadsArray );
//                                                NSLog(@"Error: %@", error);
                                              // completion(nil,error);
                                            });
                                        }];
    return task;
};

-(NSArray*)getQuantitesForStop:(Stop*)stop{
    NSMutableArray *returnArray = [NSMutableArray new];
    [stop.shipments enumerateObjectsUsingBlock:^(Shipment *shipment, BOOL *stop) {
        [[shipment.items allObjects]enumerateObjectsUsingBlock:^(Item *item, NSUInteger idx, BOOL *stop) {
            
            [returnArray addObject:@{@"delivery_line_item_number": item.line,
                                     @"quantity": item.pieces ,
                                     @"material_number":item.commodity
                                     }];
        }];
    }];
    return returnArray;
}


-(NSURLSessionDataTask *)updateStop:(Stop *)stop completion:(void (^)( NSError *))completion{
    NSLog(@"Update stop method fired");
    NSString *fullUrl = [NSString stringWithFormat: @"/shipment_tracking_rest/jsonp/loads/%@/stop/%@/pod/uid/APItester/pwd/ZTNhNzk5MGUtM2IyYi00M2M4LThhNDct/region/eu",stop.load.id,stop.id];
    NSLog(@"Full URL: %@", fullUrl);
    
    __unused NSArray *deliveries = [self getQuantitesForStop:stop];
    

    [_dateFormatter setDateFormat:@"yyyy-MM-dd'T'hh:mm:ss+00:00"];
    NSLog(@"********* Here is what date will be uploaded into the TMS: %@", [_dateFormatter stringFromDate:stop.actual_departure]);
   //[df setDateFormat:@"yyyy-MM-dd'T'hh:mm:ssZZZ"];
    
    
    NSDictionary *updateDict = @{@"actual_arrival_date": [_dateFormatter stringFromDate:stop.actual_arrival],
                                 @"actual_departure_date": [_dateFormatter stringFromDate:stop.actual_departure],
                                 @"product_id": @"60",
                                 @"delivery_number": @"",
                                 @"deliveries":@[]
                                 };
    NSError *error;
    NSData *updateData = [NSJSONSerialization dataWithJSONObject:updateDict options:0 error:&error];
    if (error) {
        NSLog(@"There was an error JSON serializing the data: %@", [error localizedDescription]);
    }
    
    NSDictionary *documentDict = @{@"document_type_id": @"",
                                 @"document_type_key": @"POD",
                                 @"product_id": @"60",
                                 @"comments": @"Completed in Madrid after lunch",
                                 @"stop_id": stop.id
                                 };
    
    NSData *documentData = [NSJSONSerialization dataWithJSONObject:documentDict options:0 error:&error];
    if (error) {
        NSLog(@"There was an error JSON serializing the data: %@", [error localizedDescription]);
    }
    
    NSURLSessionDataTask *task =  [self POST:fullUrl
                                  parameters:nil
                   constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                       
                       [formData appendPartWithFormData:updateData name:@"update_parameters"];
                       [formData appendPartWithFormData:documentData name:@"document_info"];

                       [formData appendPartWithFileData:stop.load.podData
                                                   name:@"file"
                                               fileName:@"Proof_signed.pdf"
                                               mimeType:@"application/pdf"];

                   }
                                     success:^(NSURLSessionDataTask *task,
                                               id responseObject)
                                                {
                                                   NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
                                                    NSLog(@"Response object %@", httpResponse);
                                                    completion(Nil);
                                                }
                                     failure:^(NSURLSessionDataTask *task,
                                               NSError *error) {
                                         completion(error);
                                     }];
    
    
    return task;
}

#pragma mark - Documents Requests

-(NSURLSessionDataTask *)uploadPhoto:(NSData *)photoData forStopId:(NSString *)stopId withLoadId:(NSString *)loadId withComment:(NSString *)comment completion:(void (^)(NSDictionary *, NSError *))completion{

    NSString *queryString = [NSString stringWithFormat:@"/shipment_tracking_rest/jsonp/loads/%@/stop/%@/upload/uid/APItester/pwd/ZTNhNzk5MGUtM2IyYi00M2M4LThhNDct/region/eu",loadId,stopId];
    NSDictionary *docInfoDictionay = @{@"document_type_id":@"",
                                       @"document_type_key":@"POD",
                                       @"comments":comment,
                                       @"stop_id":@""
                                       };
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:docInfoDictionay options:0 error:nil];
    
    NSURLSessionDataTask * task = [self POST:queryString
                                  parameters:@{}
                   constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                       [formData appendPartWithFileData:photoData name:@"file" fileName:@"photoimage.jpg" mimeType:@"image/jpg"];
                       [formData appendPartWithFormData:jsonData name:@"document_info"];
                   } success:^(NSURLSessionDataTask *task, id responseObject) {
                       NSLog(@"Photo successfully uploaded %@", responseObject);
                   } failure:^(NSURLSessionDataTask *task, NSError *error) {
                       NSLog(@"there was a problem %@", task.response);
                   }];
    return task;
}

#pragma mark - Load Note Requests

-(NSURLSessionDataTask *)getLoadNotesForLoad:(NSString *)loadId completion:(void (^)(NSDictionary *, NSError *))completion{
    [self.operationQueue setSuspended:NO];
    NSString *queryString = [NSString stringWithFormat:@"/shipment_tracking_rest/jsonp/loads/%@/notes/0/0/uid/APItester/pwd/ZTNhNzk5MGUtM2IyYi00M2M4LThhNDct/region/eu",loadId];
    NSURLSessionDataTask *task = [self GET:queryString parameters:nil
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

-(NSURLSessionDataTask *)postLoadNoteForLoad:(NSString *)loadId withNoteType:(NSString *)noteType withStopType:(NSString *)stopType withMessage:(NSString *)message completion:(void (^)(NSDictionary *, NSError *))completion{
    NSString *queryString = [NSString stringWithFormat:@"/shipment_tracking_rest/jsonp/loads/%@/addnote/uid/APItester/pwd/ZTNhNzk5MGUtM2IyYi00M2M4LThhNDct/region/eu",loadId];
    
    NSURLSessionDataTask *task = [self POST:queryString parameters:@{
                                                                     @"subject":@"Mobile Load Note",
                                                                     @"message":message,
                                                                     @"note_type_id":@"4647",
                                                                     @"reply_note_id":@"0",
                                                                     @"reply_note_thread_id":@"0",
                                                                     @"emails":@[@"shane.davies@chep.com"]
                                                                     }
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

@end
