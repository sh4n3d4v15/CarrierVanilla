//
//  MLChepClient.h
//  MobileLogistics
//
//  Created by shane davis on 05/06/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface CVChepClient : AFHTTPSessionManager

+(CVChepClient*)sharedClient;
#pragma mark - Stop Requests
- (NSURLSessionDataTask *)getStopsForVehicle:(NSString *)vehicleId completion:( void (^)(NSArray *results, NSError *error) )completion;

-(NSURLSessionDataTask *)updateStopWithId:(NSString *)stopid forLoad:(NSString*)loadId withQuantities:(NSArray *)quantities withActualArrival:(NSDate *)arrivalDate withActualDeparture:(NSDate*)departureDate andPod: (NSData*)podData completion:(void (^)( NSError *))completion;

#pragma mark - Documents Requests
-(NSURLSessionDataTask*)uploadPhoto:(NSData*)photoData forStopId:(NSString*)stopId withLoadId:(NSString*)loadId withComment:(NSString*)comment completion:(void(^)(NSDictionary *responseDic,NSError *error))completion;

#pragma mark - Load Note Requests
-(NSURLSessionDataTask*)getLoadNotesForLoad: (NSString*)loadId completion:(void (^)(NSDictionary *results, NSError *error))completion;

-(NSURLSessionDataTask*)postLoadNoteForLoad: (NSString*)loadId withNoteType:(NSString*)noteType withStopType: (NSString*)stopType withMessage: (NSString *)message completion:(void (^)(NSDictionary *results, NSError *error))completion;
@end

