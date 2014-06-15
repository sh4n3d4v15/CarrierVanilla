//
//  Address.h
//  CarrierVanilla
//
//  Created by shane davis on 12/06/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Stop;

@interface Address : NSManagedObject

@property (nonatomic, retain) NSString * address1;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * zip;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) Stop *stop;

@end
