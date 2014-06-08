//
//  Item.h
//  CarrierVanilla
//
//  Created by shane davis on 06/06/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Item : NSManagedObject

@property (nonatomic, retain) NSString * line;
@property (nonatomic, retain) NSString * product_id;
@property (nonatomic, retain) NSString * product_description;
@property (nonatomic, retain) NSString * commodity;
@property (nonatomic, retain) NSString * weight;
@property (nonatomic, retain) NSString * volume;
@property (nonatomic, retain) NSString * pieces;
@property (nonatomic, retain) NSString * lading;
@property (nonatomic, retain) NSManagedObject *shipment;

@end
