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
//        NSURL *ChepBaseUrl = [NSURL URLWithString:@"http://usorlut27.chep.com:50000"];
//        NSURL *ChepBaseUrl = [NSURL URLWithString:@"http://bl-con.chep.com"];
        NSURL *ChepBaseUrl = [NSURL URLWithString:@"https://api.chep.com"];
        _sharedClient = [[CVChepClient alloc]initWithBaseURL:ChepBaseUrl];
        _sharedClient.requestSerializer = [AFJSONRequestSerializer serializer];
        _sharedClient.requestSerializer.stringEncoding = NSUTF8StringEncoding;
        [_sharedClient.requestSerializer setAuthorizationHeaderFieldWithUsername:@"MobiShipRestUser" password:@"M0b1Sh1pm3n743"];

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
        }];
    });
    
    

    
    _sharedClient.dateFormatter = [[NSDateFormatter alloc]init];
    [_sharedClient.dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    //[_sharedClient.dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"BST"]];
    [_sharedClient.dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];


    return _sharedClient;
}

#pragma  mark Create Today

-(NSDate*)createDateForThisMorning{
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [cal setTimeZone:[NSTimeZone systemTimeZone]];
    
    NSDateComponents * comp = [cal components:( NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];
    
    [comp setMinute:0];
    [comp setHour:0];
    
    NSDate *startOfToday = [cal dateFromComponents:comp];
    return startOfToday;
}

-(NSDate*)createDateForMidnight{
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [cal setTimeZone:[NSTimeZone systemTimeZone]];
    
    NSDateComponents * comp = [cal components:( NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];
    
    [comp setMinute:59];
    [comp setHour:23];
    
    NSDate *startOfToday = [cal dateFromComponents:comp];
    return startOfToday;
}



#define SET_IF_NOT_NULL(TARGET, VAL) if(VAL != [NSNull null]) { TARGET = VAL; }

- (void) deleteAllObjects: (NSString *) entityDescription comparingNetworkResults:(NSArray*)networkResults  {
    CVAppDelegate *del =  (CVAppDelegate *)[UIApplication sharedApplication].delegate;
      self.moc = del.managedObjectContext;
    
    NSArray *loadIdsArray = [networkResults valueForKey:@"load_number"];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:self.moc];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [self.moc executeFetchRequest:fetchRequest error:&error];
    
    for (Load *load in items) {
        if([load isCompletedLoad]){
            [self.moc deleteObject:load];
        }else if (![loadIdsArray containsObject:load.load_number]){//1 LOAD HAS BEEN CANCELLED 2
            [self.moc deleteObject:load];
        }
    }
    if (![self.moc save:&error]) {
    	NSLog(@"Error deleting %@ - error:%@",entityDescription,error);
    }
    
}

- (void)importArrayOfStopsIntoCoreData:(NSArray*)resultsArray
{
    [self deleteAllObjects:@"Load" comparingNetworkResults:resultsArray];
    
    
    NSString *predicateString = [NSString stringWithFormat:@"load_number == $LOAD_NUMBER"];//if the n-loadnubmer doesnt exist;create
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
           // SET_IF_NOT_NULL(load.driver, [obj valueForKey:@"driver"]);
            NSString *driver = [obj valueForKey:@"driver"];
            load.driver = driver ?: @"?";
            
            NSArray *stops = [obj objectForKey:@"stops"];
            [stops enumerateObjectsUsingBlock:^(id stopobj, NSUInteger idx, BOOL *stop) {
                Stop *_stop = [NSEntityDescription insertNewObjectForEntityForName:@"Stop" inManagedObjectContext:_moc];
                //            [_stop setValuesForKeysWithDictionary:stopobj];
                SET_IF_NOT_NULL(_stop.location_name , [stopobj valueForKey:@"location_name"]);
                SET_IF_NOT_NULL(_stop.id , [stopobj valueForKey:@"id"]);
                SET_IF_NOT_NULL(_stop.location_id, [stopobj valueForKey:@"location_id"]);
                SET_IF_NOT_NULL(_stop.location_ref, [stopobj valueForKey:@"location_ref"]);
                SET_IF_NOT_NULL(_stop.type, [stopobj valueForKey:@"type"]);
                ///do we get values returned without dates?
                
                NSString *startdatestring = [[stopobj valueForKey:@"planned_start"] substringWithRange:NSMakeRange(0, [[stopobj valueForKey:@"planned_start"] length]-6)];
                NSString *enddatestring = [[stopobj valueForKey:@"planned_end"] substringWithRange:NSMakeRange(0, [[stopobj valueForKey:@"planned_end"] length]-6)];
                _stop.planned_start =  [_dateFormatter dateFromString:startdatestring];
                _stop.planned_end =  [_dateFormatter dateFromString:enddatestring];
                
                SET_IF_NOT_NULL(_stop.weight, [stopobj valueForKey:@"weight"]);
                SET_IF_NOT_NULL(_stop.pallets, [stopobj valueForKey:@"pallets"]);
                SET_IF_NOT_NULL(_stop.pieces, [stopobj valueForKey:@"pieces"]);

                _stop.actual_arrival =  [_dateFormatter dateFromString:[[stopobj valueForKey:@"actual_arrival"] substringWithRange:NSMakeRange(0, [[stopobj valueForKey:@"actual_arrival"] length]-6)]] ?: Nil;
                _stop.actual_departure =  [_dateFormatter dateFromString:[[stopobj valueForKey:@"actual_departure"] substringWithRange:NSMakeRange(0, [[stopobj valueForKey:@"actual_departure"] length]-6)]] ?: Nil;
               
                
                Address *address = [NSEntityDescription insertNewObjectForEntityForName:@"Address" inManagedObjectContext:_moc];
                SET_IF_NOT_NULL(address.address1, [stopobj valueForKeyPath:@"address.address1"]);
                SET_IF_NOT_NULL(address.city, [stopobj valueForKeyPath:@"address.city"]);
                SET_IF_NOT_NULL(address.state, [stopobj valueForKeyPath:@"address.state"]);
                SET_IF_NOT_NULL(address.zip, [stopobj valueForKeyPath:@"address.zip"])
                SET_IF_NOT_NULL(address.country, [stopobj valueForKeyPath:@"address.country"]);
                _stop.address = address;
                
                NSArray *shipments = [stopobj valueForKey:@"shipments"];
//                NSLog(@"Shipemnts in master %@", shipments);
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
                        SET_IF_NOT_NULL(item.updated_pieces, [itemObj valueForKey:@"pieces"]);
                        SET_IF_NOT_NULL(item.lading, [itemObj valueForKey:@"lading"]);

                        [shipment addItemsObject:item];
                    }];///ITEMS LOOP
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
    
    
    NSLog(@"This Morningin: %@", [self createDateForMidnight]);
    NSLog(@"Midnight TOinght: %@", [self createDateForMidnight]);
    
    
        NSString *username = [userinfo valueForKey:@"carrier"];
        NSString *password =  [userinfo valueForKey:@"password"];
        NSString *vehicle = [userinfo valueForKey:@"vehicle"];
    
        NSString *urlString = [NSString stringWithFormat:@"/shipment_tracking_rest/jsonp/loads/uid/%@/pwd/%@/region/eu",username,password];
        NSURLSessionDataTask *task = [self POST:urlString parameters:@{
                                                                     @"vehicle":vehicle,
                                                                     @"res":@"",
                                                                     @"offset":@0,
                                                                     @"limit":@50,
                                                                     @"include_stops":@YES,
                                                                     @"include_shipments":@YES,
                                                                     @"expand_loads":@YES,
                                                                     @"pick_start_date":@"",
                                                                     @"pick_end_date":@"",
                                                                     @"drop_start_date":@"",
                                                                     @"drop_end_date":@""}
                                      
                                        success:^(NSURLSessionDataTask *task, id responseObject) {
                                            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
                                            NSLog(@"Http resp: %@", httpResponse);
                                            NSArray *loads = [responseObject valueForKey:@"loads"];
                                            NSLog(@"Loads: %@",loads);
                                            if (httpResponse.statusCode == 200) {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    if ([loads count] < 1) {
                                                        completion(@"No Loads For This Vehicle", nil);
                                                    }else{
                                                         [self importArrayOfStopsIntoCoreData:loads];
                                                        completion(@"all is good with 200 in da hood",nil);
                                                    }
                                                    
                                                });
                                            }else{
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    completion(@"Something unexplained happened",nil);
                                                });
                                            }
                                        } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                             NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                
                                                if (httpResponse.statusCode == 401) {
                                                    completion(@"User login not successful", error);
                                                }else{
                                                    completion(@"Network connection error", error);
                                                }

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
    
    NSDictionary *userinfo = [[NSUserDefaults standardUserDefaults]objectForKey:@"userinfo"];
    NSString *username = [userinfo valueForKey:@"carrier"];
    NSString *password =  [userinfo valueForKey:@"password"];
    NSString *fullUrl = [NSString stringWithFormat: @"/shipment_tracking_rest/jsonp/loads/%@/stop/%@/pod/uid/%@/pwd/%@/region/eu",stop.load.id,stop.id,username,password];
    NSLog(@"Full URL: %@", fullUrl);
    
    __unused NSArray *deliveries = [self getQuantitesForStop:stop];
    

   // [_dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss+00:00"];
    [_dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
//    [_dateFormatter setDateFormat:@"yyyy-MM-dd'T'hh:mm:ssZZZ"];
  
    
    
    NSDictionary *updateDict = @{@"actual_arrival_date": [_dateFormatter stringFromDate:stop.actual_arrival],
                                 @"actual_departure_date": [_dateFormatter stringFromDate:stop.actual_departure],
                                 @"product_id": @"60",
                                 @"delivery_number": @"",
                                 @"deliveries":@[]
                                 };
    NSError *error;
    NSData *updateData = [NSJSONSerialization dataWithJSONObject:updateDict options:0 error:&error];
    NSDictionary *documentDict = @{@"document_type_id": @"",
                                 @"document_type_key": @"POD",
                                 @"product_id": @"60",
                                 @"comments": @"",
                                 @"stop_id": stop.id
                                 };
    
    NSData *documentData = [NSJSONSerialization dataWithJSONObject:documentDict options:0 error:&error];
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
                                                  // NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
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
    
    NSDictionary *userinfo = [[NSUserDefaults standardUserDefaults]objectForKey:@"userinfo"];
    NSString *username = [userinfo valueForKey:@"carrier"];
    NSString *password =  [userinfo valueForKey:@"password"];
    NSString *queryString = [NSString stringWithFormat:@"/shipment_tracking_rest/jsonp/loads/%@/stop/%@/upload/uid/%@/pwd/%@/region/eu",loadId,stopId,username,password];
    NSDictionary *docInfoDictionay = @{@"document_type_id":@"",
                                       @"document_type_key":@"POD",
                                       @"comments":@"",
                                       @"stop_id":@""
                                       };
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:docInfoDictionay options:0 error:nil];
    
    NSURLSessionDataTask * task = [self POST:queryString
                                  parameters:@{}
                   constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                       [formData appendPartWithFileData:photoData name:@"file" fileName:@"photoimage.jpg" mimeType:@"image/jpg"];
                       [formData appendPartWithFormData:jsonData name:@"document_info"];
                   } success:^(NSURLSessionDataTask *task, id responseObject) {
                   } failure:^(NSURLSessionDataTask *task, NSError *error) {
                   }];
    return task;
}

#pragma mark - Load Note Requests

-(NSURLSessionDataTask *)getLoadNotesForLoad:(NSString *)loadId completion:(void (^)(NSDictionary *, NSError *))completion{
    
    NSDictionary *userinfo = [[NSUserDefaults standardUserDefaults]objectForKey:@"userinfo"];
    NSString *username = [userinfo valueForKey:@"carrier"];
    NSString *password =  [userinfo valueForKey:@"password"];
    [self.operationQueue setSuspended:NO];
    NSString *queryString = [NSString stringWithFormat:@"/shipment_tracking_rest/jsonp/loads/%@/notes/0/0/uid/%@/pwd/%@/region/eu",loadId,username,password];
    NSLog(@"GET LOAD NOTES QUIERY STRING: %@", queryString);
    NSURLSessionDataTask *task = [self GET:queryString parameters:nil
                                   success:^(NSURLSessionDataTask *task, id responseObject) {
                                       NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
                                       NSLog(@"SUCCESS LOAD NOTES HTTP RESPONSE: %@", httpResponse);
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
                                       NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
                                       NSLog(@"FAILURE LOAD NOTES HTTP RESPONSE: %@", httpResponse);
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           completion(nil,error);
                                       });
                                   }];
    return task;
}

-(NSURLSessionDataTask *)postLoadNoteForLoad:(NSString *)loadId withNoteType:(NSString *)noteType withStopType:(NSString *)stopType withMessage:(NSString *)message completion:(void (^)(NSDictionary *, NSError *))completion{
    
    NSDictionary *userinfo = [[NSUserDefaults standardUserDefaults]objectForKey:@"userinfo"];
    NSString *username = [userinfo valueForKey:@"carrier"];
    NSString *password =  [userinfo valueForKey:@"password"];
    NSString *queryString = [NSString stringWithFormat:@"/shipment_tracking_rest/jsonp/loads/%@/addnote/uid/%@/pwd/%@/region/eu",loadId,username,password];
    
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
