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
- (void)importArrayOfStopsIntoCoreData:(NSArray*)resultsArray;
#pragma mark - Stop Requests
- (NSURLSessionDataTask *)getStopsForVehicle:(NSString *)vehicleId completion:( void (^)(NSArray *results, NSError *error) )completion;

@end

