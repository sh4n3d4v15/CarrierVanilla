//
//  Load.m
//  Chep Carrier
//
//  Created by shane davis on 10/10/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import "Load.h"
#import "Loadnote.h"
#import "Pod.h"
#import "Ref.h"
#import "Stop.h"


@implementation Load

@dynamic completed;
@dynamic driver;
@dynamic id;
@dynamic load_number;
@dynamic podData;
@dynamic status;
@dynamic loadNotes;
@dynamic pods;
@dynamic refs;
@dynamic stops;
-(BOOL)isCompletedLoad{
    __block BOOL complete = YES;
    
    [self.stops enumerateObjectsUsingBlock:^(Stop *currentStop, BOOL *stop) {
        if (!currentStop.actual_departure) {
            complete = NO;
        }
    }];
    return complete;
}

@end
