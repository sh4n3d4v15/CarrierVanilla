//
//  HTAutocompleteManager.m
//  HotelTonight
//
//  Created by Jonathan Sibley on 12/6/12.
//  Copyright (c) 2012 Hotel Tonight. All rights reserved.
//

#import "HTAutocompleteManager.h"

static HTAutocompleteManager *sharedManager;

@implementation HTAutocompleteManager

+ (HTAutocompleteManager *)sharedManager
{
	static dispatch_once_t once;
	dispatch_once(&once, ^{ sharedManager = [[HTAutocompleteManager alloc] init]; });
	return sharedManager;
}

#pragma mark - HTAutocompleteTextFieldDelegate

- (NSString *)textField:(HTAutocompleteTextField *)textField
    completionForPrefix:(NSString *)prefix
             ignoreCase:(BOOL)ignoreCase
{

        static dispatch_once_t colorOnceToken;
        static NSArray *vehicleIdsArray;
        dispatch_once(&colorOnceToken, ^
        {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            vehicleIdsArray = [defaults arrayForKey:@"vehicleIds"];
        });

        NSString *stringToLookFor;
		NSArray *componentsString = [prefix componentsSeparatedByString:@","];
        NSString *prefixLastComponent = [componentsString.lastObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (ignoreCase)
        {
            stringToLookFor = [prefixLastComponent lowercaseString];
        }
        else
        {
            stringToLookFor = prefixLastComponent;
        }
        
        for (NSString *stringFromReference in vehicleIdsArray)
        {
            NSString *stringToCompare;
            if (ignoreCase)
            {
                stringToCompare = [stringFromReference lowercaseString];
            }
            else
            {
                stringToCompare = stringFromReference;
            }
            
            if ([stringToCompare hasPrefix:stringToLookFor])
            {
                return [stringFromReference stringByReplacingCharactersInRange:[stringToCompare rangeOfString:stringToLookFor] withString:@""];
            }
        }
    return @"";
}

@end
