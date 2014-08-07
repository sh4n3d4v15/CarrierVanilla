//
//  NSArray+Flatten.m
//  Chep Carrier
//
//  Created by shane davis on 07/08/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import "NSArray+Flatten.h"

@implementation NSArray (Flatten)

- (NSArray *) flattenArray{
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"");
    }];
    return self;
}
@end
