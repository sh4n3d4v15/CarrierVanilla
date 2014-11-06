//
//  CVChepClientTest.m
//  Chep Carrier QA
//
//  Created by shane davis on 23/10/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "CVChepClient.h"

@interface CVChepClientTest : XCTestCase

@end

@implementation CVChepClientTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    
    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"client completed"];
    // This is an example of a functional test case.
    [CVChepClient sharedClient]getStopsForUser:@{@"carrier":@"APITestuser",@"password":@"foo", @"vehicle":@"shane"}
                                     completion:^(NSString *responseMessage, NSError *error) {
                                         
                                         XCTAssertNotEqualObjects(error, nil,@"Result was not ok")
                                         [completionExpectation fulfill];
        
                                     }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil]
}


@end
