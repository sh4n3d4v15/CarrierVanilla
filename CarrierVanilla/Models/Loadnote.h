//
//  Loadnote.h
//  CarrierVanilla
//
//  Created by shane davis on 27/06/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Stop;

@interface Loadnote : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSData * media;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * attributes;
@property (nonatomic, retain) NSNumber * fromMe;
@property (nonatomic, retain) Stop *stop;

@end
