//
//  CVMultiPDFWriter.m
//  Chep Carrier
//
//  Created by shane davis on 09/10/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import "CVMultiPDFWriter.h"
#import "Stop.h"
#import "Address.h"
#import "Shipment.h"
#import "Item.h"
#import "Load.h"
#import "Pod.h"
#import "CVChepClient.h"
#import <QuartzCore/QuartzCore.h>

#pragma clang diagnostic ignored "-Wdeprecated-declarations"


@implementation CVMultiPDFWriter



+(void)setUpPageWithFrame:(CGRect)frame strokeColor:(UIColor*)strokeColor{
    
 // add Chep Logo
    UIImage * chepLogo = [UIImage imageNamed:@"chep-logo.jpg"];

    CGRect logoBox = CGRectMake(CGRectGetMinX(frame) + 40, CGRectGetMinY(frame) + 20, 200, 53.5);
    [chepLogo drawInRect:logoBox];
    
    
    UIBezierPath* rectangle3Path = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame) + 41.5, CGRectGetMinY(frame) + 133.5, 523, 209)];
    [strokeColor setStroke];
    rectangle3Path.lineWidth = 1;
    [rectangle3Path stroke];
    
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 215.5, CGRectGetMinY(frame) + 133.5)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 215.5, CGRectGetMinY(frame) + 342.5)];
    [strokeColor setStroke];
    bezierPath.lineWidth = 1;
    [bezierPath stroke];
    
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 397.5, CGRectGetMinY(frame) + 133.5)];
    [bezier2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 397.5, CGRectGetMinY(frame) + 342.5)];
    [strokeColor setStroke];
    bezier2Path.lineWidth = 1;
    [bezier2Path stroke];
    
    
    //// Bezier 3 Drawing
    UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
    [bezier3Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 41.5, CGRectGetMinY(frame) + 235.5)];
    [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 564.5, CGRectGetMinY(frame) + 235.5)];
    [strokeColor setStroke];
    bezier3Path.lineWidth = 1;
    [bezier3Path stroke];
    
    
    UIBezierPath* rectangle4Path = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame) + 42.5, CGRectGetMinY(frame) + 351.5, 522, 140)];
    [strokeColor setStroke];
    rectangle4Path.lineWidth = 1;
    [rectangle4Path stroke];
    
    
    //// Bezier 4 Drawing
    UIBezierPath* bezier4Path = [UIBezierPath bezierPath];
    [bezier4Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 79.5, CGRectGetMinY(frame) + 351.5)];
    [bezier4Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 79.5, CGRectGetMinY(frame) + 491.5)];
    [strokeColor setStroke];
    bezier4Path.lineWidth = 1;
    [bezier4Path stroke];
    
    
    //// Bezier 5 Drawing
    UIBezierPath* bezier5Path = [UIBezierPath bezierPath];
    [bezier5Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 176.5, CGRectGetMinY(frame) + 351.5)];
    [bezier5Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 176.5, CGRectGetMinY(frame) + 491.5)];
    [strokeColor setStroke];
    bezier5Path.lineWidth = 1;
    [bezier5Path stroke];
    
    
    //// Bezier 6 Drawing
    UIBezierPath* bezier6Path = [UIBezierPath bezierPath];
    [bezier6Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 320.5, CGRectGetMinY(frame) + 351.5)];
    [bezier6Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 320.5, CGRectGetMinY(frame) + 492.5)];
    [strokeColor setStroke];
    bezier6Path.lineWidth = 1;
    [bezier6Path stroke];
    
    
    //// Bezier 7 Drawing
    UIBezierPath* bezier7Path = [UIBezierPath bezierPath];
    [bezier7Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 397.5, CGRectGetMinY(frame) + 351.5)];
    [bezier7Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 397.5, CGRectGetMinY(frame) + 491.5)];
    [strokeColor setStroke];
    bezier7Path.lineWidth = 1;
    [bezier7Path stroke];
    
    
    //// Bezier 8 Drawing
    UIBezierPath* bezier8Path = [UIBezierPath bezierPath];
    [bezier8Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 483.5, CGRectGetMinY(frame) + 351.5)];
    [bezier8Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 483.5, CGRectGetMinY(frame) + 492.5)];
    [strokeColor setStroke];
    bezier8Path.lineWidth = 1;
    [bezier8Path stroke];
    
    UIBezierPath* rectangle5Path = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame) + 42.5, CGRectGetMinY(frame) + 503.5, 522, 204)];
    [strokeColor setStroke];
    rectangle5Path.lineWidth = 1;
    [rectangle5Path stroke];
    
    
    //// Bezier 9 Drawing
    UIBezierPath* bezier9Path = [UIBezierPath bezierPath];
    [bezier9Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 218.5, CGRectGetMinY(frame) + 546.5)];
    [bezier9Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 218.5, CGRectGetMinY(frame) + 659.5)];
    [strokeColor setStroke];
    bezier9Path.lineWidth = 1;
    [bezier9Path stroke];
    
    
    //// Bezier 10 Drawing
    UIBezierPath* bezier10Path = [UIBezierPath bezierPath];
    [bezier10Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 404.5, CGRectGetMinY(frame) + 546.5)];
    [bezier10Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 404.5, CGRectGetMinY(frame) + 659.5)];
    [strokeColor setStroke];
    bezier10Path.lineWidth = 1;
    [bezier10Path stroke];
    
    
    //// Bezier 11 Drawing
    UIBezierPath* bezier11Path = [UIBezierPath bezierPath];
    [bezier11Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 42.5, CGRectGetMinY(frame) + 546.5)];
    [bezier11Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 564.5, CGRectGetMinY(frame) + 546.5)];
    [strokeColor setStroke];
    bezier11Path.lineWidth = 1;
    [bezier11Path stroke];
    
    
    //// Bezier 12 Drawing
    UIBezierPath* bezier12Path = [UIBezierPath bezierPath];
    [bezier12Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 42.5, CGRectGetMinY(frame) + 659.5)];
    [bezier12Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 564.5, CGRectGetMinY(frame) + 659.5)];
    [strokeColor setStroke];
    bezier12Path.lineWidth = 1;
    [bezier12Path stroke];
}

+(void)drawHeadersAndStaticTextWithFrame:(CGRect)frame withStrokeColor:(UIColor*)strokeColor{
    
    NSString* SENDER_HEADER             = @"SENDER:";
    NSString* CARRIER_HEADER            = @"CARRIER:";
    NSString* DELIVERY_NUMBER_HEADER    = @"DELIVERY NUMBER:";
    NSString* RECEIVER_HEADER           = @"RECEIVER:";
    NSString* DELIVERY_DATE_HEADER      = @"DELIVERY DATE:";
    NSString* SHIPMENT_NUMBER_HEADER    = @"SHIPMENT NUMBER:";
    NSString* ITEM_HEADER               = @"ITEM";
    NSString* PRODUCT_CODE_HEADER       = @"PRODUCT CODE";
    NSString* DESCRIPTION_HEADER        = @"PRODUCT DESCRIPTION";
    NSString* BATCH_HEADER              = @"BATCH";
    NSString* PLANNED_QUANTITY_HEADER   = @"PLANNED QTY";
    NSString* ACTUAL_QUANTITY_HEADER    = @"ACTUAL QTY";
    NSString* COMMENTS_HEADER           = @"COMMENTS";
    NSString* CHEP_ADDRESS1             = @"WEYBRIDGE BUSINESS PARK";
    NSString* CHEP_ROAD                 = @"ADDELSTONE ROAD, ADDELSTONE";
    NSString* CHEP_TOWN                 = @"SURREY KT15 2UP";
    NSString* CHEP_TEL                  = @"TEL: +44 01932 850085";
    NSString* CHEP_FAX                  = @"FAX +44 01932 850144";
    
    CGRect textRect = CGRectMake(CGRectGetMinX(frame) + 45, CGRectGetMinY(frame) + 138, 60, 15);
    [strokeColor setFill];
    [SENDER_HEADER drawInRect: textRect withFont: [UIFont fontWithName: @"Helvetica" size: 12] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];
    
    
    //// Text 2 Drawing
    CGRect text2Rect = CGRectMake(CGRectGetMinX(frame) + 221, CGRectGetMinY(frame) + 138, 58, 15);
    [strokeColor setFill];
    [CARRIER_HEADER drawInRect: text2Rect withFont: [UIFont fontWithName: @"Helvetica" size: 12] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];
    
    CGRect text2Rect1 = CGRectMake(CGRectGetMinX(frame) + 221, CGRectGetMinY(frame) + 158, 158, 15);
    [strokeColor setFill];
    [@"TDS Logistics" drawInRect: text2Rect1 withFont: [UIFont fontWithName: @"Helvetica" size: 12] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];
    
    
    //// Text 3 Drawing
    CGRect text3Rect = CGRectMake(CGRectGetMinX(frame) + 401, CGRectGetMinY(frame) + 138, 127, 15);
    [strokeColor setFill];
    [DELIVERY_NUMBER_HEADER drawInRect: text3Rect withFont: [UIFont fontWithName: @"Helvetica" size: 12] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];
    
    
    //// Text 4 Drawing
    CGRect text4Rect = CGRectMake(CGRectGetMinX(frame) + 47, CGRectGetMinY(frame) + 241, 75, 16);
    [strokeColor setFill];
    [RECEIVER_HEADER drawInRect: text4Rect withFont: [UIFont fontWithName: @"Helvetica" size: 12] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];
    
    
    //// Text 5 Drawing
    CGRect text5Rect = CGRectMake(CGRectGetMinX(frame) + 220, CGRectGetMinY(frame) + 241, 101, 15);
    [strokeColor setFill];
    [DELIVERY_DATE_HEADER drawInRect: text5Rect withFont: [UIFont fontWithName: @"Helvetica" size: 12] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];
    

    //// Text 6 Drawing
    CGRect text6Rect = CGRectMake(CGRectGetMinX(frame) + 402, CGRectGetMinY(frame) + 241, 126, 18);
    [strokeColor setFill];
    [SHIPMENT_NUMBER_HEADER drawInRect: text6Rect withFont: [UIFont fontWithName: @"Helvetica" size: 12] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];
    
    CGRect iTEMRect = CGRectMake(CGRectGetMinX(frame) + 48, CGRectGetMinY(frame) + 356, 26, 15);
    [strokeColor setFill];
    [ITEM_HEADER drawInRect: iTEMRect withFont: [UIFont fontWithName: @"Helvetica" size: 10] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
    
    
    //// PRODUCT Drawing
    CGRect pRODUCTRect = CGRectMake(CGRectGetMinX(frame) + 86, CGRectGetMinY(frame) + 356, 83, 14);
    [strokeColor setFill];
    [PRODUCT_CODE_HEADER drawInRect: pRODUCTRect withFont: [UIFont fontWithName: @"Helvetica" size: 10] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
    
    

    //// DESCRIPTION Drawing
    CGRect dESCRIPTIONRect = CGRectMake(CGRectGetMinX(frame) + 175, CGRectGetMinY(frame) + 355, 147, 15);
    [strokeColor setFill];
    [DESCRIPTION_HEADER drawInRect: dESCRIPTIONRect withFont: [UIFont fontWithName: @"Helvetica" size: 10] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
    

    
    //// BATCH Drawing
    CGRect bATCHRect = CGRectMake(CGRectGetMinX(frame) + 317, CGRectGetMinY(frame) + 355, 83, 15);
    [strokeColor setFill];
    [BATCH_HEADER drawInRect: bATCHRect withFont: [UIFont fontWithName: @"Helvetica" size: 10] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
    
    
    //// PLANNED QUANTITY Drawing
    CGRect pLANNEDQUANTITYRect = CGRectMake(CGRectGetMinX(frame) + 398, CGRectGetMinY(frame) + 356, 85, 16);
    [strokeColor setFill];
    [PLANNED_QUANTITY_HEADER drawInRect: pLANNEDQUANTITYRect withFont: [UIFont fontWithName: @"Helvetica" size: 9] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
    
    
    //// ACTUAL QUANTITY Drawing
    CGRect aCTUALQUANTITYRect = CGRectMake(CGRectGetMinX(frame) + 487, CGRectGetMinY(frame) + 356, 73, 14);
    [strokeColor setFill];
    [ACTUAL_QUANTITY_HEADER drawInRect: aCTUALQUANTITYRect withFont: [UIFont fontWithName: @"Helvetica" size: 9] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
    
    //// ACTUAL QUANTITY Drawing
    
    //// COMMENTS Drawing
    CGRect cOMMENTSRect = CGRectMake(CGRectGetMinX(frame) + 47, CGRectGetMinY(frame) + 508, 74, 15);
    [strokeColor setFill];
    [COMMENTS_HEADER drawInRect: cOMMENTSRect withFont: [UIFont fontWithName: @"Helvetica" size: 12] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];
    
    //// SENDER Drawing
    CGRect sENDERRect = CGRectMake(CGRectGetMinX(frame) + 46, CGRectGetMinY(frame) + 550, 108, 18);
    [strokeColor setFill];
    [SENDER_HEADER drawInRect: sENDERRect withFont: [UIFont fontWithName: @"Helvetica" size: 12] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];
    
    
    ////  Drawing
    CGRect cARRIERRect = CGRectMake(CGRectGetMinX(frame) + 226, CGRectGetMinY(frame) + 550, 111, 16);
    [strokeColor setFill];
    [CARRIER_HEADER drawInRect: cARRIERRect withFont: [UIFont fontWithName: @"Helvetica" size: 12] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];
    
    
    
    
    //// RECEIVER Drawing
    CGRect rECEIVERRect = CGRectMake(CGRectGetMinX(frame) + 414, CGRectGetMinY(frame) + 550, 86, 14);
    [strokeColor setFill];
    [RECEIVER_HEADER drawInRect: rECEIVERRect withFont: [UIFont fontWithName: @"Helvetica" size: 12] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];
    
    CGRect aDDRESSS1Rect = CGRectMake(CGRectGetMinX(frame) + 374, CGRectGetMinY(frame) + 23, 195, 16);
    [strokeColor setFill];
    [CHEP_ADDRESS1 drawInRect: aDDRESSS1Rect withFont: [UIFont fontWithName: @"Helvetica" size: 10] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentRight];
    
    
    //// ROAD Drawing
    CGRect rOADRect = CGRectMake(CGRectGetMinX(frame) + 329, CGRectGetMinY(frame) + 37, 240, 18);
    [strokeColor setFill];
    [CHEP_ROAD drawInRect: rOADRect withFont: [UIFont fontWithName: @"Helvetica" size: 10] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentRight];
    
    
    //// CITY Drawing
    CGRect cITYRect = CGRectMake(CGRectGetMinX(frame) + 365, CGRectGetMinY(frame) + 50, 204, 19);
    [strokeColor setFill];
    [CHEP_TOWN drawInRect: cITYRect withFont: [UIFont fontWithName: @"Helvetica" size: 10] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentRight];
    
    
    //// TEL Drawing
    CGRect tELRect = CGRectMake(CGRectGetMinX(frame) + 407, CGRectGetMinY(frame) + 70, 162, 16);
    [strokeColor setFill];
    [CHEP_TEL drawInRect: tELRect withFont: [UIFont fontWithName: @"Helvetica" size: 10] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentRight];
    
    
    //// FAX Drawing
    CGRect fAXRect = CGRectMake(CGRectGetMinX(frame) + 411, CGRectGetMinY(frame) + 83, 158, 17);
    [strokeColor setFill];
    [CHEP_FAX drawInRect: fAXRect withFont: [UIFont fontWithName: @"Helvetica" size: 10] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentRight];
    
}


+(void)createPDFfromStop:(Stop*)stop
{
    
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"dd-MM-yyyy"];

    
#pragma mark Page frame
    CGRect frame = CGRectMake(0, 0, 612, 792);
    UIColor* strokeColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 1];
    


    
#pragma mark Dynamic content
    NSArray * shipments = [stop.shipments allObjects];

    NSString* dropStopState = stop.address.state;
    NSString* dropStopAddress1 = stop.address.address1;
    NSString* dropStopName = stop.location_name;
    UIImage*  dropStopSignature = [UIImage imageWithData:stop.signatureSnapshot];


    [shipments enumerateObjectsUsingBlock:^(Shipment *shipment, NSUInteger outerIndex, BOOL *end_stop) {
        
        
        NSMutableData *pdfData = [NSMutableData data];
        
        CGRect pageFrame = CGRectMake(0, 0, 612, 792);
        UIGraphicsBeginPDFContextToData(pdfData, pageFrame, nil);
        UIGraphicsBeginPDFPage();
        
        
        [self setUpPageWithFrame:frame strokeColor:strokeColor];
        [self drawHeadersAndStaticTextWithFrame:frame withStrokeColor:strokeColor];
        
        
        NSString *ref = shipment.primary_reference_number;
        Stop *picStop =  [[CVChepClient sharedClient]getPickStopWithShipmentNumber:ref];
        picStop.processed = [NSNumber numberWithBool:YES];
        
        NSLog(@"This is the index %lu and the pictop is %@", (unsigned long)outerIndex,picStop.location_name);
        
        UIImage* senderSignature = [UIImage imageWithData:picStop.signatureSnapshot];
        NSString* pickStopName = picStop.location_name;
        NSString* pickStopAddress1 = picStop.address.address1;
        NSString* pickStopCity = picStop.address.city;
        NSString* pickStopState = picStop.address.state;

        CGRect plannedDateBox = CGRectMake(CGRectGetMinX(frame) + 220, CGRectGetMinY(frame) + 261, 101, 15);
        [strokeColor setFill];
        [[df stringFromDate:stop.planned_end] drawInRect: plannedDateBox withFont: [UIFont fontWithName: @"Helvetica" size: 12] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];

        CGRect loadNumberRect = CGRectMake(CGRectGetMinX(frame) + 402, CGRectGetMinY(frame) + 261, 126, 18);
        [strokeColor setFill];
        [stop.load.load_number drawInRect: loadNumberRect withFont: [UIFont fontWithName: @"Helvetica" size: 12] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];
    
        CGRect shipmentNumberBox = CGRectMake(CGRectGetMinX(frame) + 401, CGRectGetMinY(frame) + 158, 147, 15);
        [strokeColor setFill];
        [shipment.primary_reference_number drawInRect: shipmentNumberBox withFont: [UIFont fontWithName: @"Helvetica" size: 12] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];
    
        CGRect commentsBox = CGRectMake(CGRectGetMinX(frame) + 47, CGRectGetMinY(frame) + 528, 374, 15);
        [strokeColor setFill];
        [@"** This load was complete through the mobile application" drawInRect: commentsBox withFont: [UIFont fontWithName: @"Helvetica" size: 12] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];
        
            ///write shipment number
            NSArray *items = [shipment.items allObjects];
            [items enumerateObjectsUsingBlock:^(Item *item, NSUInteger innerIndex, BOOL *stop) {
                
                
                CGRect dESCRIPTIONRect1 = CGRectMake(CGRectGetMinX(frame) + 175, CGRectGetMinY(frame) + ( 375 + (10 * innerIndex)  ), 147, 15);
                [strokeColor setFill];
                [item.product_description drawInRect: dESCRIPTIONRect1 withFont: [UIFont fontWithName: @"Helvetica" size: 8] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
                
                CGRect pLANNEDQUANTITYRect1 = CGRectMake(CGRectGetMinX(frame) + 398, CGRectGetMinY(frame) + ( 375 + (10 * innerIndex)  ), 73, 14);
                [strokeColor setFill];
                
                
                [[item.pieces stringValue] drawInRect: pLANNEDQUANTITYRect1 withFont: [UIFont fontWithName: @"Helvetica" size: 9] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
                
                
                CGRect aCTUALQUANTITYRect1 = CGRectMake(CGRectGetMinX(frame) + 487, CGRectGetMinY(frame) + ( 375 + (10 * innerIndex)  ), 73, 14);
                [strokeColor setFill];
                [[item.updated_pieces stringValue] drawInRect: aCTUALQUANTITYRect1 withFont: [UIFont fontWithName: @"Helvetica" size: 9] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
                
                
                CGRect pRODUCTRect1 = CGRectMake(CGRectGetMinX(frame) + 86, CGRectGetMinY(frame) + ( 375 + (10 * innerIndex)  ), 73, 14);
                [strokeColor setFill];
                [item.product_id drawInRect: pRODUCTRect1 withFont: [UIFont fontWithName: @"Helvetica" size: 10] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
                
                
                
                
            }];//items enumeration

        CGRect pickStopCityBox = CGRectMake(CGRectGetMinX(frame) + 47, CGRectGetMinY(frame) + 321, 160, 16);
        [strokeColor setFill];
        [pickStopCity drawInRect: pickStopCityBox withFont: [UIFont fontWithName: @"Helvetica" size: 10] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];
    
        CGRect dropStopStateBox = CGRectMake(CGRectGetMinX(frame) + 47, CGRectGetMinY(frame) + 295, 160, 20);
        [strokeColor setFill];
        [dropStopState drawInRect: dropStopStateBox withFont: [UIFont fontWithName: @"Helvetica" size: 10] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];

        CGRect dropStopAddress1Box = CGRectMake(CGRectGetMinX(frame) + 47, CGRectGetMinY(frame) + 281, 160, 18);
        [strokeColor setFill];
        [dropStopAddress1 drawInRect: dropStopAddress1Box withFont: [UIFont fontWithName: @"Helvetica" size: 10] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];
        

        CGRect receiverLocationNameRect = CGRectMake(CGRectGetMinX(frame) + 47, CGRectGetMinY(frame) + 261, 160, 21);
        [strokeColor setFill];
        [dropStopName drawInRect: receiverLocationNameRect withFont: [UIFont fontWithName: @"Helvetica" size: 12] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];

        CGRect unkown = CGRectMake(CGRectGetMinX(frame) + 44, CGRectGetMinY(frame) + 217, 160, 16);
        [strokeColor setFill];
        [@"what am i?" drawInRect: unkown withFont: [UIFont fontWithName: @"Helvetica" size: 10] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];

        CGRect pickStopStatebox = CGRectMake(CGRectGetMinX(frame) + 44, CGRectGetMinY(frame) + 191, 160, 20);
        [strokeColor setFill];
        [pickStopState drawInRect: pickStopStatebox withFont: [UIFont fontWithName: @"Helvetica" size: 10] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];
        

        CGRect pickStopAddress1Box = CGRectMake(CGRectGetMinX(frame) + 44, CGRectGetMinY(frame) + 177, 160, 18);
        [strokeColor setFill];
        [pickStopAddress1 drawInRect: pickStopAddress1Box withFont: [UIFont fontWithName: @"Helvetica" size: 10] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];

        CGRect pickStopNameBox = CGRectMake(CGRectGetMinX(frame) + 44, CGRectGetMinY(frame) + 157, 160, 21);
        [strokeColor setFill];
        [pickStopName drawInRect: pickStopNameBox withFont: [UIFont fontWithName: @"Helvetica" size: 12] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];

        
        
        //// senderSignatureBox Drawing
        CGRect senderSignatureBoxRect = CGRectMake(CGRectGetMinX(frame) + 67.5, CGRectGetMinY(frame) + 576.5, 115, 57);
        [senderSignature drawInRect:senderSignatureBoxRect];
        
        //// dropStopSignatureBox Drawing
        CGRect dropStopSignatureBoxRect = CGRectMake(CGRectGetMinX(frame) + 424.5, CGRectGetMinY(frame) + 567.5, 114, 66);
        [dropStopSignature drawInRect:dropStopSignatureBoxRect];
        
        
        UIGraphicsEndPDFContext();
        NSArray* documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
        NSString* documentDirectory = [documentDirectories objectAtIndex:0];
        NSString* documentDirectoryFilename = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf",ref]];
        NSLog(@"aFilename will be wrote: %@", documentDirectoryFilename);
        
        Pod *pod = [NSEntityDescription insertNewObjectForEntityForName:@"Pod" inManagedObjectContext:[CVChepClient sharedClient].moc];
        pod.data = pdfData;
        pod.ref = ref;
        
        [stop.load addPodsObject:pod];

        [[CVChepClient sharedClient].moc save:nil];
        if (![pdfData writeToFile:documentDirectoryFilename atomically:YES]) {
            NSLog(@"saving file didnt work");
        }
        
    }];
    
    
}

@end
