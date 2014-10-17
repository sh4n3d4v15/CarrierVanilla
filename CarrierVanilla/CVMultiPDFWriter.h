//
//  CVMultiPDFWriter.h
//  Chep Carrier
//
//  Created by shane davis on 09/10/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "Stop.h"
#import <CoreLocation/CoreLocation.h>

@interface CVMultiPDFWriter : NSObject
+(void)createPDFfromShipment:(Shipment*)shipment;
@end
