//
//  Ref.h
//  CarrierVanilla
//
//  Created by shane davis on 06/06/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Load;

@interface Ref : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) Load *load;

@end
