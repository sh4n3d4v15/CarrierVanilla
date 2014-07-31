//
//  Item.h
//  Chep Carrier
//
//  Created by shane davis on 31/07/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Shipment;

@interface Item : NSManagedObject

@property (nonatomic, retain) NSString * commodity;
@property (nonatomic, retain) NSNumber * finalized;
@property (nonatomic, retain) NSString * lading;
@property (nonatomic, retain) NSString * line;
@property (nonatomic, retain) NSNumber * pieces;
@property (nonatomic, retain) NSString * product_description;
@property (nonatomic, retain) NSString * product_id;
@property (nonatomic, retain) NSNumber * volume;
@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) NSNumber * updated_pieces;
@property (nonatomic, retain) Shipment *shipment;

@end
