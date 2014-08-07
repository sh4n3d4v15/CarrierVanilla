//
//  Load.h
//  Chep Carrier
//
//  Created by shane davis on 07/08/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Loadnote, Ref, Stop;

@interface Load : NSManagedObject

@property (nonatomic, retain) NSString * completed;
@property (nonatomic, retain) NSString * driver;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * load_number;
@property (nonatomic, retain) NSData * podData;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSSet *refs;
@property (nonatomic, retain) NSSet *stops;
@property (nonatomic, retain) NSSet *loadNotes;
@end

@interface Load (CoreDataGeneratedAccessors)

- (void)addRefsObject:(Ref *)value;
- (void)removeRefsObject:(Ref *)value;
- (void)addRefs:(NSSet *)values;
- (void)removeRefs:(NSSet *)values;

- (void)addStopsObject:(Stop *)value;
- (void)removeStopsObject:(Stop *)value;
- (void)addStops:(NSSet *)values;
- (void)removeStops:(NSSet *)values;

- (void)addLoadNotesObject:(Loadnote *)value;
- (void)removeLoadNotesObject:(Loadnote *)value;
- (void)addLoadNotes:(NSSet *)values;
- (void)removeLoadNotes:(NSSet *)values;
-(BOOL)isCompletedLoad;
@end
