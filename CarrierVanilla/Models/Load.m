//
//  Load.m
//  CarrierVanilla
//
//  Created by shane davis on 06/06/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import "Load.h"
#import "Ref.h"
#import "Stop.h"


@implementation Load

@dynamic completed;
@dynamic id;
@dynamic load_number;
@dynamic podData;
@dynamic status;
@dynamic stops;
@dynamic refs;

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
