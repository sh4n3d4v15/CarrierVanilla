//
//  MLChepClient.m
//  MobileLogistics
//
//  Created by shane davis on 05/06/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import "CVChepClient.h"

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

#pragma mark - Stop Requests

-(NSURLSessionDataTask *)getStopsForVehicle:(NSString *)vehicleId completion:(void (^)(NSArray *, NSError *))completion{
    NSURLSessionDataTask *task = [self GET:@"loads" parameters:@{@"vehicle":vehicleId} success:^(NSURLSessionDataTask *task, id responseObject) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
        NSArray *loads = [responseObject valueForKey:@"loads"];
        if(httpResponse.statusCode == 200){
            dispatch_async(dispatch_get_main_queue(), ^{
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
