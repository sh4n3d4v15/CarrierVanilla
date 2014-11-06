//
//  MLCoreDataManager.h
//  MobileLogistics
//
//  Created by shane davis on 28/10/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CVCoreDataManager : NSObject
+(CVCoreDataManager*)sharedClient;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property(nonatomic)NSDateFormatter *dateFormatter;
- (void)importArrayOfStopsIntoCoreData:(NSArray*)resultsArray;
@end
