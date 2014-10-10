//
//  MLChepClient.h
//  MobileLogistics
//
//  Created by shane davis on 05/06/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "Stop.h"
@interface CVChepClient : AFHTTPSessionManager

+(CVChepClient*)sharedClient;
#pragma mark - Stop Requests
- (NSURLSessionDataTask *)getStopsForUser:(NSDictionary *)userinfo completion:( void (^)(NSString *responseMessage, NSError *error) )completion;

-(NSURLSessionDataTask *)updateArrivalForStop:(Stop *)stop completion:(void (^)( NSError *))completion;
-(NSURLSessionDataTask *)updateStop:(Stop *)stop completion:(void (^)( NSError *))completion;

#pragma mark - Documents Requests
-(NSURLSessionDataTask*)uploadPhoto:(NSData*)photoData forStopId:(NSString*)stopId withLoadId:(NSString*)loadId withComment:(NSString*)comment completion:(void(^)(NSDictionary *responseDic,NSError *error))completion;

#pragma mark - Load Note Requests
-(NSURLSessionDataTask*)getLoadNotesForLoad: (NSString*)loadId completion:(void (^)(NSDictionary *results, NSError *error))completion;

-(NSURLSessionDataTask*)postLoadNoteForLoad: (NSString*)loadId withNoteType:(NSString*)noteType withStopType: (NSString*)stopType withMessage: (NSString *)message completion:(void (^)(NSDictionary *results, NSError *error))completion;

#pragma mark - POD related
-(Stop*)getPickStopWithShipmentNumber:(NSString*)shipmentNumber;
@property(nonatomic)NSManagedObjectContext *moc;
@property(nonatomic)BOOL isReachable;
@property(nonatomic)NSDateFormatter *dateFormatter;
@end

