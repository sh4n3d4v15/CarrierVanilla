//
//  Pod.h
//  Chep Carrier
//
//  Created by shane davis on 14/10/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Load;

@interface Pod : NSManagedObject

@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSString * ref;
@property (nonatomic, retain) Load *load;

@end
