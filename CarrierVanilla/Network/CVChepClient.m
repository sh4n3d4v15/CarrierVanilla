//
//  MLChepClient.m
//  MobileLogistics
//
//  Created by shane davis on 05/06/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import "CVChepClient.h"
#import "CVAppDelegate.h"
#import "CVCoreDataManager.h"

#import "Load.h"
#import "Address.h"
#import "Ref.h"
#import "Shipment.h"
#import "Item.h"

@interface CVChepClient()
@property (nonatomic) NSDateFormatter *df;

@end

@implementation CVChepClient
+ (CVChepClient *)sharedClient {
	static CVChepClient *_sharedClient = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
	    NSLog(@"Initialzing CVChepClient singleton");
	    NSURL *ChepBaseUrl = [NSURL URLWithString:@"http://bl-dev.chep.com"];
//        NSURL *ChepBaseUrl = [NSURL URLWithString:@"http://usorlut27.chep.com:50000"];
//        NSURL *ChepBaseUrl = [NSURL URLWithString:@"http://bl-con.chep.com"];
      //  NSURL *ChepBaseUrl = [NSURL URLWithString:@"https://api.chep.com"];
	    _sharedClient = [[CVChepClient alloc]initWithBaseURL:ChepBaseUrl];
	    _sharedClient.requestSerializer = [AFJSONRequestSerializer serializer];
	    _sharedClient.requestSerializer.stringEncoding = NSUTF8StringEncoding;
	    [_sharedClient.requestSerializer setAuthorizationHeaderFieldWithUsername:@"MobiShipRestUser" password:@"M0b1Sh1pm3n743"];

	    [[AFNetworkReachabilityManager sharedManager]startMonitoring];
	    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock: ^(AFNetworkReachabilityStatus status) {
	        NSOperationQueue *operationQueue = _sharedClient.operationQueue;
	        switch (status) {
				case AFNetworkReachabilityStatusReachableViaWWAN:
				case AFNetworkReachabilityStatusReachableViaWiFi:
					NSLog(@"NOT Suspending the operation queue");
					[operationQueue setSuspended:NO];
					break;

				case AFNetworkReachabilityStatusNotReachable:
				default:
					NSLog(@"Suspending the operation queue");
					[operationQueue setSuspended:YES];
					break;
			}
		}];
	});

    
    _sharedClient.df = [[NSDateFormatter alloc]init];
    [_sharedClient.df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    [_sharedClient.df setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];


	return _sharedClient;
}

#pragma mark - Stops methods
/**
 *  Get Stops from user info
 *
 *  @param userInfo   object containing the authentication detail and the the 'vehicle' field for searching assigned loads
 *  @param completion completion block that will return either an error, or nil if successful
 *
 *  @return returns NSURLSessionTask
 */

- (NSURLSessionDataTask *)getLoadsForUser:(NSDictionary *)userInfo completion:(void (^)(NSArray *, NSError *))completion {
    
    if (userInfo) {
        _username = [userInfo valueForKey:@"name"];
        _password = [userInfo valueForKey:@"password"];
        _vehicle = [userInfo valueForKey:@"vehicle"];
    }
    NSString *urlString = [NSString stringWithFormat:@"/shipment_tracking_rest/jsonp/loads/uid/%@/pwd/%@/region/eu", _username, _password];
    
    NSLog(@"URL string for get loads: %@", urlString);
    NSURLSessionDataTask *task = [self POST:urlString parameters:@{
                                                                   @"vehicle" : _vehicle,
                                                                   @"res" : @"",
                                                                   @"offset" : @0,
                                                                   @"limit" : @50,
                                                                   @"include_stops" : @YES,
                                                                   @"include_shipments" : @YES,
                                                                   @"expand_loads" : @YES,
                                                                   @"pick_start_date" : @"",
                                                                   @"pick_end_date" : @"",
                                                                   @"drop_start_date" : @"",
                                                                   @"drop_end_date" : @""
                                                                   } success: ^(NSURLSessionDataTask *task, id responseObject) {
                                                                       int responseCode = [[responseObject valueForKeyPath:@"error.code"] intValue];
                                                                       
                                                                       if (responseCode == 401) {
                                                                           NSError *error = [NSError errorWithDomain:@"bad credentials"
                                                                                                                code:401
                                                                                                            userInfo:@{}];
                                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                                               completion(nil, error);
                                                                           });
                                                                       }
                                                                       else {
                                                                           NSArray *loads = [responseObject valueForKey:@"loads"];
                                                                           NSLog(@"Here are the loads: %@", loads);
                                                                           
                                                                           [[CVCoreDataManager sharedClient]importArrayOfStopsIntoCoreData:loads];
                                                                           
                                                                           if ([loads count] == 0) {
                                                                               NSError *error = [NSError errorWithDomain:@"no loads" code:100 userInfo:nil];
                                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                                   completion(nil, error);
                                                                               });
                                                                           }else{
                                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                                   completion(loads, nil);
                                                                               });
                                                                           }
                                                                           
                                                                       }
                                                                   } failure: ^(NSURLSessionDataTask *task, NSError *error) {
                                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                                           NSLog(@"failure: %@", error);
                                                                           completion(nil, error);
                                                                       });
                                                                   }];
    return task;
}

/**
 *  Update the stop arrival time
 *
 *  @param arrivalTime NSString timestamp
 *  @param loadId      NSString of the load id
 *  @param stopId      NSString of the stop id
 *  @param completion  Returns error if call failed
 *
 *  @return returns NSURLSessionTask
 */
- (NSURLSessionDataTask *)updateArrivalTime:(NSString *)arrivalTime forLoadWithId:(NSString *)loadId forStopWithId:(NSString *)stopId completion:(void (^)(NSError *))completion {
    NSString *urlString = [NSString stringWithFormat:@"/shipment_tracking_rest/jsonp/loads/%@/stop/%@/arrived/%@/uid/%@/pwd/%@/region/eu", loadId, stopId, arrivalTime, _username, _password];
    
    NSURLSessionDataTask *task = [self GET:urlString parameters:nil success: ^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"Update arrial response object: %@", responseObject);
        int responseCode = [[responseObject valueForKeyPath:@"result.code"]intValue];
        if (responseCode == 401) {
            NSError *error = [NSError errorWithDomain:@"bad credentials"
                                                 code:401
                                             userInfo:@{}];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(error);
            });
        }else if(responseCode == 400){
            NSError *error = [NSError errorWithDomain:@"bad parameters"
                                                 code:401
                                             userInfo:@{}];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(error);
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil);
            });
        }
    } failure: ^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(error);
        });
    }];
    return task;
}

/**
 *  Update the stop departure time
 *
 *  @param arrivalTime NSString timestamp
 *  @param loadId      NSString of the load id
 *  @param stopId      NSString of the stop id
 *  @param completion  Returns error if call failed
 *
 *  @return returns NSURLSessionTask
 */
- (NSURLSessionDataTask *)updateDepartureTime:(NSString *)departureTime forLoadWithId:(NSString *)loadId forStopWithId:(NSString *)stopId completion:(void (^)(NSError *))completion {
    NSString *urlString = [NSString stringWithFormat:@"/shipment_tracking_rest/jsonp/loads/%@/stop/%@/departed/%@/uid/%@/pwd/%@/region/eu", loadId, stopId, departureTime, _username, _password];
    
    NSLog(@"DEPARTURE DATE: %@", departureTime);
    NSURLSessionDataTask *task = [self GET:urlString parameters:nil success: ^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"Update arrial response object: %@", responseObject);
        int responseCode = [[responseObject valueForKeyPath:@"error.code"]intValue];
        if (responseCode == 401) {
            NSError *error = [NSError errorWithDomain:@"bad credentials"
                                                 code:1
                                             userInfo:@{}];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(error);
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil);
            });
        }
    } failure: ^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(error);
        });
    }];
    return task;
}

/**
 *  UploadProofOfDelivery & update arrivaltime & departure time
 *
 *  @param podData       NSData representation of pod
 *  @param arrivalTime   NSString value of arrival time
 *  @param departureTime NSString value of departure time
 *  @param stopId        NSString id of stop
 *  @param loadId        NSString id of load
 *  @param completion    Retruns error if call failed
 *
 *  @return returns NSURLSessionDataTask
 */
- (NSURLSessionDataTask *)UploadProofOfDelivery:(NSData *)podData andUpdateArrivalTime:(NSDate *)arrivalTime andDepartureTime:(NSDate *)departureTime forStop:(NSString *)stopId onLoad:(NSString *)loadId completion:(void (^)(NSError *))completion {
    NSString *urlString = [NSString stringWithFormat:@"/shipment_tracking_rest/jsonp/loads/%@/stop/%@/pod/uid/%@/pwd/%@/region/eu", loadId, stopId, _username, _password];
    
    [_df setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSDictionary *updateDict = @{ @"actual_arrival_date": [_df stringFromDate: arrivalTime],
                                  @"actual_departure_date": [_df stringFromDate:departureTime],
                                  @"product_id": @"60",
                                  @"delivery_number": @"",
                                  @"deliveries":@[] };
    NSError *error;
    NSData *updateData = [NSJSONSerialization dataWithJSONObject:updateDict options:0 error:&error];
    NSDictionary *documentDict = @{ @"document_type_id": @"",
                                    @"document_type_key": @"POD",
                                    @"product_id": @"60",
                                    @"comments": @"",
                                    @"stop_id": stopId };
    
    NSData *documentData = [NSJSONSerialization dataWithJSONObject:documentDict options:0 error:&error];
    
    NSURLSessionDataTask *task = [self POST:urlString parameters:nil constructingBodyWithBlock: ^(id < AFMultipartFormData > formData) {
        [formData appendPartWithFormData:updateData name:@"update_parameters"];
        [formData appendPartWithFormData:documentData name:@"document_info"];
        
        [formData appendPartWithFileData:podData
                                    name:@"file"
                                fileName:@"Proof_signed.pdf"
                                mimeType:@"application/pdf"];
    } success: ^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"Response Object for update in cvchepclient %@", responseObject);
        int responseCode = [[responseObject valueForKeyPath:@"error.code"]intValue];
        NSLog(@"INT CODE %lu", (unsigned long)responseCode);
        if (responseCode == 401) {
            NSError *error = [NSError errorWithDomain:@"bad credentials"
                                                 code:1
                                             userInfo:@{}];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(error);
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil);
            });
        }
    } failure: ^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(error);
        });
    }];
    
    return task;
}
#pragma mark - Loadnote methods
/**
 *  Get load notes for loadId
 *
 *  @param loadId     NSString load id
 *  @param completion returns load notes (messages) or error
 *
 *  @return returns NSURLSessionDataTask
 */
- (NSURLSessionDataTask *)getLoadNotesForLoad:(NSString *)loadId completion:(void (^)(NSArray *, NSError *))completion {
    NSString *queryString = [NSString stringWithFormat:@"/shipment_tracking_rest/jsonp/loads/%@/notes/0/0/uid/%@/pwd/%@/region/eu", loadId, _username, _password];
    
    NSURLSessionDataTask *task = [self GET:queryString parameters:nil success: ^(NSURLSessionDataTask *task, id responseObject) {
        int responseCode = [[responseObject valueForKeyPath:@"error.code"]intValue];
        NSLog(@"Response in get load notes %@", responseObject);
        if (responseCode == 401) {
            NSError *error = [NSError errorWithDomain:@"bad credentials"
                                                 code:404
                                             userInfo:@{}];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, error);
            });
        }
        else {
            NSArray *messages = [responseObject valueForKey:@"notes"];
 
            if([messages count]>0){
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(messages, nil);
                });
            }else{
                NSError *error = [NSError errorWithDomain:@"No Notes"
                                                     code:401
                                                 userInfo:@{}];
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, error);
                });
            }
        }
    } failure: ^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, error);
        });
    }];
    return task;
}

/**
 *  Post a load note
 *
 *  @param message    NSString message to send
 *  @param loadId     NSString of loadId
 *  @param noteType   NSString Type of load to be sent (based on Lean loadnote codes)
 *  @param stopType   NSString type of stop (pick/drop)
 *  @param completion returns error;
 *
 *  @return returns NSURLSessionDataTask
 */
- (NSURLSessionDataTask *)postLoadNote:(NSString *)message forLoad:(NSString *)loadId withNoteType:(NSString *)noteType andStopType:(NSString *)stopType completion:(void (^)(NSError *))completion {
    NSString *queryString = [NSString stringWithFormat:@"/shipment_tracking_rest/jsonp/loads/%@/addnote/uid/%@/pwd/%@/region/eu", loadId, _username, _password];
    NSLog(@"query string: %@", queryString);
    NSURLSessionDataTask *task = [self POST:queryString parameters:@{
                                                                     @"subject":@"Mobile Load Note",
                                                                     @"message":message,
                                                                     @"note_type_id":@"4647",
                                                                     @"reply_note_id":@"0",
                                                                     @"reply_note_thread_id":@"0",
                                                                     @"emails":@[@"shane.davies@chep.com"]
                                                                     } success: ^(NSURLSessionDataTask *task, id responseObject) {
                                                                         
                                                                         NSLog(@"up res ob: %@", [responseObject valueForKey:@"result"]);
                                                                         int responseCode = [[responseObject valueForKeyPath:@"result.code"]intValue];
                                                                         NSLog(@"INT CODE %lu", (unsigned long)responseCode);
                                                                         
                                                                         if (responseCode == 401) {
                                                                             NSLog(@"The response code is 401");
                                                                             NSError *error = [NSError errorWithDomain:@"bad credentials"
                                                                                                                  code:401
                                                                                                              userInfo:@{}];
                                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                                 completion(error);
                                                                             });
                                                                         }
                                                                         else {
                                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                                 completion(nil);
                                                                             });
                                                                         }
                                                                     } failure: ^(NSURLSessionDataTask *task, NSError *error) {
                                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                                             completion(error);
                                                                         });
                                                                     }];
    
    return task;
}
#pragma mark - Document methods
/**
 *  Upload a document
 *
 *  @param docData    NSData of the image/document
 *  @param docType    NSString type of document (pod/image)
 *  @param stopId     NSString stop id
 *  @param loadId     NSString load id
 *  @param comment    NSString comment to add to the image/document
 *  @param completion returns error
 *
 *  @return returns NSURLSessionDataTask
 */
-(NSURLSessionDataTask *)uploadDocument:(NSData *)docData ofType:(NSString *)docType forStop:(NSString *)stopId onLoad:(NSString *)loadId withComment:(NSString *)comment completion:(void (^)(NSError *))completion{
    
    NSString *queryString = [NSString stringWithFormat:@"/shipment_tracking_rest/jsonp/loads/%@/stop/%@/upload/uid/%@/pwd/%@/region/eu",loadId,stopId,_username,_password];
    
    NSDictionary *docInfoDictionay = @{@"document_type_id":@"",
                                       @"document_type_key":@"POD",
                                       @"comments":@"",
                                       @"stop_id":@""
                                       };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:docInfoDictionay options:0 error:nil];
    
    NSURLSessionDataTask * task = [self POST:queryString
                                  parameters:@{}
                   constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                       if ([docType isEqualToString:@"POD"]) {
                           [formData appendPartWithFileData:docData name:@"file" fileName:[NSString stringWithFormat:@"%@.pdf",comment] mimeType:@"application/pdf"];
                       }else{
                           [formData appendPartWithFileData:docData name:@"file" fileName:@"photoimage.jpg" mimeType:@"image/jpg"];
                       }
                       [formData appendPartWithFormData:jsonData name:@"document_info"];
                   } success:^(NSURLSessionDataTask *task, id responseObject) {
                       int responseCode = [[responseObject valueForKeyPath:@"result.code"]intValue];
                       NSLog(@"INT CODE ,%@", responseObject);
                       
                       if (responseCode == 401) {
                           NSLog(@"The response code is 401");
                           NSError *error = [NSError errorWithDomain:@"bad credentials"
                                                                code:401
                                                            userInfo:@{}];
                           dispatch_async(dispatch_get_main_queue(), ^{
                               completion(error);
                           });
                       }
                       else {
                           dispatch_async(dispatch_get_main_queue(), ^{
                               completion(nil);
                           });
                       }
                   } failure:^(NSURLSessionDataTask *task, NSError *error) {
                       dispatch_async(dispatch_get_main_queue(), ^{
                           completion(error);
                       });
                   }];
    return task;
    
}


















@end
