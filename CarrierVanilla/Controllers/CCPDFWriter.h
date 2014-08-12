//
//  CCPDFWriter.h
//  ChepCarrier
//
//  Created by shane davis on 25/04/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Load.h"
#import <CoreLocation/CoreLocation.h>

@interface CCPDFWriter : NSObject
+(void)createPDFfromLoad:(Load*)load forStopType:(NSString*)stopType saveToDocumentsWithFileName:(NSString*)aFilename;
@end
