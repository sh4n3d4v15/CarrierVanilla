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
#import "CVChepClient.h"
#import <QuartzCore/QuartzCore.h>

#pragma clang diagnostic ignored "-Wdeprecated-declarations"


@implementation CVMultiPDFWriter

+(void)createPDFfromStop:(Stop*)stop
{
    
    if ([stop.type isEqualToString:@"Drop"]) {
        
        NSLog(@"CVMultiPDFWriter found a Drop");
        NSArray * shipments = [stop.shipments allObjects];
        
        __block Stop *picStop;
        [shipments enumerateObjectsUsingBlock:^(Shipment *shipment, NSUInteger idx, BOOL *end_stop) {
            NSString *ref = shipment.primary_reference_number;
            picStop =  [[CVChepClient sharedClient]getPickStopWithShipmentNumber:ref];
            NSLog(@"Pickstop: %@", picStop);
            


    
    NSMutableData *pdfData = [NSMutableData data];
    
    CGRect pageFrame = CGRectMake(0, 0, 612, 792);
    UIGraphicsBeginPDFContextToData(pdfData, pageFrame, nil);
    UIGraphicsBeginPDFPage();
    
    //// Color Declarations
    UIColor* strokeColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 1];
    //UIColor* logo = [UIColor colorWithRed: 0 green: 0.467 blue: 0.674 alpha: 1];
    
    //// Image Declarations
    UIImage* senderSignature = [UIImage imageWithData:picStop.signatureSnapshot];
    UIImage* receiverSignature = [UIImage imageWithData:stop.signatureSnapshot];
    
    //// Frames
    CGRect frame = CGRectMake(0, 0, 612, 792);
    
    
    //// Abstracted Attributes
    NSString* textContent = @"SENDER:";
    NSString* text2Content = @"CARRIER:";
    NSString* text3Content = @"DELIVERY NUMBER:";
    NSString* text4Content = @"RECEIVER:";
    NSString* text5Content = @"DELIVERY DATE:";
    NSString* text6Content = @"SHIPMENT NUMBER:";
    NSString* iTEMContent = @"ITEM";
    NSString* pRODUCTContent = @"PRODUCT CODE";
    NSString* dESCRIPTIONContent = @"PRODUCT DESCRIPTION";
    NSString* bATCHContent = @"BATCH";
    NSString* pLANNEDQUANTITYContent = @"PLANNED QTY";
    NSString* aCTUALQUANTITYContent = @"ACTUAL QTY";
    NSString* cOMMENTSContent = @"COMMENTS";
    NSString* sENDERContent = @"SENDER";
    NSString* cARRIERContent = @"CARRIER";
    NSString* rECEIVERContent = @"RECEIVER";
    NSString* aDDRESSS1Content = @"WEYBRIDGE BUSINESS PARK";
    NSString* rOADContent = @"ADDELSTONE ROAD, ADDELSTONE";
    NSString* cITYContent = @"SURREY KT15 2UP";
    NSString* tELContent = @"TEL: +44 01932 850085";
    NSString* fAXContent = @"FAX +44 01932 850144";
    //RECIEVER
    NSString* aDDRESSSCITYRContent = picStop.address.city;
    //    NSString* address3RContent = stop.address.address3;
    NSString* address2RContent = stop.address.state;
    NSString* address1RContent = stop.address.address1;
    NSString* receiverLocationNameContent = stop.location_name;
    //SENDER
    NSString* aDDRESSSCITYContent = picStop.address.city;
    //    NSString* address3Content = picStop.address.address3;
    NSString* address2Content = picStop.address.state;
    NSString* address1Content = picStop.address.address1;
    NSString* senderLocationNameContent = picStop.location_name;
    

#pragma mark - writing
    
    //// Locations
    {
        //// Rectangle 3 Drawing
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
        
        
        //// Text Drawing
        CGRect textRect = CGRectMake(CGRectGetMinX(frame) + 45, CGRectGetMinY(frame) + 138, 60, 15);
        [strokeColor setFill];
        [textContent drawInRect: textRect withFont: [UIFont fontWithName: @"Helvetica" size: 12] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];
        
        
        //// Text 2 Drawing
        CGRect text2Rect = CGRectMake(CGRectGetMinX(frame) + 221, CGRectGetMinY(frame) + 138, 58, 15);
        [strokeColor setFill];
        [text2Content drawInRect: text2Rect withFont: [UIFont fontWithName: @"Helvetica" size: 12] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];
        
        CGRect text2Rect1 = CGRectMake(CGRectGetMinX(frame) + 221, CGRectGetMinY(frame) + 158, 158, 15);
        [strokeColor setFill];
        [@"TDS Logistics" drawInRect: text2Rect1 withFont: [UIFont fontWithName: @"Helvetica" size: 12] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];
        
        
        //// Text 3 Drawing
        CGRect text3Rect = CGRectMake(CGRectGetMinX(frame) + 401, CGRectGetMinY(frame) + 138, 127, 15);
        [strokeColor setFill];
        [text3Content drawInRect: text3Rect withFont: [UIFont fontWithName: @"Helvetica" size: 12] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];
        
        
        //        CGRect text3Rect1 = CGRectMake(CGRectGetMinX(frame) + 401, CGRectGetMinY(frame) + 158, 147, 15);
        //        [strokeColor setFill];
        //        [shipmentNumber drawInRect: text3Rect1 withFont: [UIFont fontWithName: @"Helvetica" size: 12] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];
        
        
        //// Text 4 Drawing
        CGRect text4Rect = CGRectMake(CGRectGetMinX(frame) + 47, CGRectGetMinY(frame) + 241, 75, 16);
        [strokeColor setFill];
        [text4Content drawInRect: text4Rect withFont: [UIFont fontWithName: @"Helvetica" size: 12] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];
        
        
        //// Text 5 Drawing
        CGRect text5Rect = CGRectMake(CGRectGetMinX(frame) + 220, CGRectGetMinY(frame) + 241, 101, 15);
        [strokeColor setFill];
        [text5Content drawInRect: text5Rect withFont: [UIFont fontWithName: @"Helvetica" size: 12] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];
        
        //// Text 5 Drawing
        NSDateFormatter *df = [NSDateFormatter new];
        [df setDateFormat:@"dd-MM-yyyy"];
        CGRect text5Rect1 = CGRectMake(CGRectGetMinX(frame) + 220, CGRectGetMinY(frame) + 261, 101, 15);
        [strokeColor setFill];
        [[df stringFromDate:stop.planned_end] drawInRect: text5Rect1 withFont: [UIFont fontWithName: @"Helvetica" size: 12] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];
        
        
        //// Text 6 Drawing
        CGRect text6Rect = CGRectMake(CGRectGetMinX(frame) + 402, CGRectGetMinY(frame) + 241, 126, 18);
        [strokeColor setFill];
        [text6Content drawInRect: text6Rect withFont: [UIFont fontWithName: @"Helvetica" size: 12] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];
        
        CGRect shipnumrect = CGRectMake(CGRectGetMinX(frame) + 402, CGRectGetMinY(frame) + 261, 126, 18);
        [strokeColor setFill];
        [picStop.load.load_number drawInRect: shipnumrect withFont: [UIFont fontWithName: @"Helvetica" size: 12] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];
    }
    
    
    //// Products
    {
        //// Rectangle 4 Drawing
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
        
        
        NSArray *shipments = [stop.shipments allObjects];
        
        CGRect text3Rect1 = CGRectMake(CGRectGetMinX(frame) + 401, CGRectGetMinY(frame) + 158, 147, 15);
        [strokeColor setFill];
        [[shipments[0] valueForKey:@"primary_reference_number" ] drawInRect: text3Rect1 withFont: [UIFont fontWithName: @"Helvetica" size: 12] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];
        
        [shipments enumerateObjectsUsingBlock:^(Shipment *shipment, NSUInteger outerIndex, BOOL *stop) {
            
            ///write shipment number
            NSArray *items = [shipment.items allObjects];
            [items enumerateObjectsUsingBlock:^(Item *item, NSUInteger innerIndex, BOOL *stop) {
                
                
                CGRect dESCRIPTIONRect1 = CGRectMake(CGRectGetMinX(frame) + 175, CGRectGetMinY(frame) + ( 375 + (10 * innerIndex) + ( outerIndex * 10) ), 147, 15);
                [strokeColor setFill];
                [item.product_description drawInRect: dESCRIPTIONRect1 withFont: [UIFont fontWithName: @"Helvetica" size: 8] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
                
                CGRect pLANNEDQUANTITYRect1 = CGRectMake(CGRectGetMinX(frame) + 398, CGRectGetMinY(frame) + ( 375 + (10 * innerIndex) + ( outerIndex * 10) ), 73, 14);
                [strokeColor setFill];
                
                
                [[item.pieces stringValue] drawInRect: pLANNEDQUANTITYRect1 withFont: [UIFont fontWithName: @"Helvetica" size: 9] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
                
                
                CGRect aCTUALQUANTITYRect1 = CGRectMake(CGRectGetMinX(frame) + 487, CGRectGetMinY(frame) + ( 375 + (10 * innerIndex) + ( outerIndex * 10) ), 73, 14);
                [strokeColor setFill];
                [[item.updated_pieces stringValue] drawInRect: aCTUALQUANTITYRect1 withFont: [UIFont fontWithName: @"Helvetica" size: 9] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
                
                
                CGRect pRODUCTRect1 = CGRectMake(CGRectGetMinX(frame) + 86, CGRectGetMinY(frame) + ( 375 + (10 * innerIndex) + ( outerIndex * 10) ), 73, 14);
                [strokeColor setFill];
                [item.product_id drawInRect: pRODUCTRect1 withFont: [UIFont fontWithName: @"Helvetica" size: 10] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
                
                
                
                
            }];//items enumeration
        }];//shipment enumeration
        
        
        //// ITEM Drawing
        CGRect iTEMRect = CGRectMake(CGRectGetMinX(frame) + 48, CGRectGetMinY(frame) + 356, 26, 15);
        [strokeColor setFill];
        [iTEMContent drawInRect: iTEMRect withFont: [UIFont fontWithName: @"Helvetica" size: 10] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
        
        //        CGRect iTEMRect1 = CGRectMake(CGRectGetMinX(frame) + 48, CGRectGetMinY(frame) + 376, 26, 15);
        //        [strokeColor setFill];
        //        [@"10" drawInRect: iTEMRect1 withFont: [UIFont fontWithName: @"Helvetica" size: 10] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
        
        
        //// PRODUCT Drawing
        CGRect pRODUCTRect = CGRectMake(CGRectGetMinX(frame) + 86, CGRectGetMinY(frame) + 356, 83, 14);
        [strokeColor setFill];
        [pRODUCTContent drawInRect: pRODUCTRect withFont: [UIFont fontWithName: @"Helvetica" size: 10] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
        
        
        //// PRODUCT Drawing
        //        CGRect pRODUCTRect1 = CGRectMake(CGRectGetMinX(frame) + 86, CGRectGetMinY(frame) + 376, 83, 14);
        //        [strokeColor setFill];
        //        [@"00000001" drawInRect: pRODUCTRect1 withFont: [UIFont fontWithName: @"Helvetica" size: 10] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
        
        //// DESCRIPTION Drawing
        CGRect dESCRIPTIONRect = CGRectMake(CGRectGetMinX(frame) + 175, CGRectGetMinY(frame) + 355, 147, 15);
        [strokeColor setFill];
        [dESCRIPTIONContent drawInRect: dESCRIPTIONRect withFont: [UIFont fontWithName: @"Helvetica" size: 10] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
        
        //// DESCRIPTION Drawing
        //        CGRect dESCRIPTIONRect1 = CGRectMake(CGRectGetMinX(frame) + 175, CGRectGetMinY(frame) + 375, 147, 15);
        //        [strokeColor setFill];
        //        [@"B1208A- 800x1200 Block Pallet" drawInRect: dESCRIPTIONRect1 withFont: [UIFont fontWithName: @"Helvetica" size: 8] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
        
        
        //// BATCH Drawing
        CGRect bATCHRect = CGRectMake(CGRectGetMinX(frame) + 317, CGRectGetMinY(frame) + 355, 83, 15);
        [strokeColor setFill];
        [bATCHContent drawInRect: bATCHRect withFont: [UIFont fontWithName: @"Helvetica" size: 10] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
        
        
        //// PLANNED QUANTITY Drawing
        CGRect pLANNEDQUANTITYRect = CGRectMake(CGRectGetMinX(frame) + 398, CGRectGetMinY(frame) + 356, 85, 16);
        [strokeColor setFill];
        [pLANNEDQUANTITYContent drawInRect: pLANNEDQUANTITYRect withFont: [UIFont fontWithName: @"Helvetica" size: 9] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
        
        //// PLANNED QUANTITY Drawing
        //        CGRect pLANNEDQUANTITYRect1 = CGRectMake(CGRectGetMinX(frame) + 398, CGRectGetMinY(frame) + 376, 85, 16);
        //        [strokeColor setFill];
        //        [@"520" drawInRect: pLANNEDQUANTITYRect1 withFont: [UIFont fontWithName: @"Helvetica" size: 9] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
        
        //// ACTUAL QUANTITY Drawing
        CGRect aCTUALQUANTITYRect = CGRectMake(CGRectGetMinX(frame) + 487, CGRectGetMinY(frame) + 356, 73, 14);
        [strokeColor setFill];
        [aCTUALQUANTITYContent drawInRect: aCTUALQUANTITYRect withFont: [UIFont fontWithName: @"Helvetica" size: 9] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
        
        //// ACTUAL QUANTITY Drawing
        
        //// COMMENTS Drawing
        CGRect cOMMENTSRect = CGRectMake(CGRectGetMinX(frame) + 47, CGRectGetMinY(frame) + 508, 74, 15);
        [strokeColor setFill];
        [cOMMENTSContent drawInRect: cOMMENTSRect withFont: [UIFont fontWithName: @"Helvetica" size: 12] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];
        
        //// COMMENTS Drawing
        CGRect cOMMENTSRect1 = CGRectMake(CGRectGetMinX(frame) + 47, CGRectGetMinY(frame) + 528, 374, 15);
        [strokeColor setFill];
        [@"** This load was complete through the mobile application" drawInRect: cOMMENTSRect1 withFont: [UIFont fontWithName: @"Helvetica" size: 12] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];
    }
    
    
    //// Signatures
    {
        //// Rectangle 5 Drawing
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
        
        
        //// SENDER Drawing
        CGRect sENDERRect = CGRectMake(CGRectGetMinX(frame) + 46, CGRectGetMinY(frame) + 550, 108, 18);
        [strokeColor setFill];
        [sENDERContent drawInRect: sENDERRect withFont: [UIFont fontWithName: @"Helvetica" size: 12] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];
        
        
        ////  Drawing
        CGRect cARRIERRect = CGRectMake(CGRectGetMinX(frame) + 226, CGRectGetMinY(frame) + 550, 111, 16);
        [strokeColor setFill];
        [cARRIERContent drawInRect: cARRIERRect withFont: [UIFont fontWithName: @"Helvetica" size: 12] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];
        
        
        
        
        //// RECEIVER Drawing
        CGRect rECEIVERRect = CGRectMake(CGRectGetMinX(frame) + 414, CGRectGetMinY(frame) + 550, 86, 14);
        [strokeColor setFill];
        [rECEIVERContent drawInRect: rECEIVERRect withFont: [UIFont fontWithName: @"Helvetica" size: 12] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];
    }
    
    
    //// ADDRESS
    {
        //// ADDRESSS1 Drawing
        CGRect aDDRESSS1Rect = CGRectMake(CGRectGetMinX(frame) + 374, CGRectGetMinY(frame) + 23, 195, 16);
        [strokeColor setFill];
        [aDDRESSS1Content drawInRect: aDDRESSS1Rect withFont: [UIFont fontWithName: @"Helvetica" size: 10] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentRight];
        
        
        //// ROAD Drawing
        CGRect rOADRect = CGRectMake(CGRectGetMinX(frame) + 329, CGRectGetMinY(frame) + 37, 240, 18);
        [strokeColor setFill];
        [rOADContent drawInRect: rOADRect withFont: [UIFont fontWithName: @"Helvetica" size: 10] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentRight];
        
        
        //// CITY Drawing
        CGRect cITYRect = CGRectMake(CGRectGetMinX(frame) + 365, CGRectGetMinY(frame) + 50, 204, 19);
        [strokeColor setFill];
        [cITYContent drawInRect: cITYRect withFont: [UIFont fontWithName: @"Helvetica" size: 10] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentRight];
        
        
        //// TEL Drawing
        CGRect tELRect = CGRectMake(CGRectGetMinX(frame) + 407, CGRectGetMinY(frame) + 70, 162, 16);
        [strokeColor setFill];
        [tELContent drawInRect: tELRect withFont: [UIFont fontWithName: @"Helvetica" size: 10] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentRight];
        
        
        //// FAX Drawing
        CGRect fAXRect = CGRectMake(CGRectGetMinX(frame) + 411, CGRectGetMinY(frame) + 83, 158, 17);
        [strokeColor setFill];
        [fAXContent drawInRect: fAXRect withFont: [UIFont fontWithName: @"Helvetica" size: 10] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentRight];
        
        
        //// dynamicRecieverDetails
        {
            //// ADDRESSSCITYR Drawing
            CGRect aDDRESSSCITYRRect = CGRectMake(CGRectGetMinX(frame) + 47, CGRectGetMinY(frame) + 321, 160, 16);
            [strokeColor setFill];
            [aDDRESSSCITYRContent drawInRect: aDDRESSSCITYRRect withFont: [UIFont fontWithName: @"Helvetica" size: 10] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];
            
            
            //            //// address3R Drawing
            //            CGRect address3RRect = CGRectMake(CGRectGetMinX(frame) + 47, CGRectGetMinY(frame) + 308, 160, 17);
            //            [strokeColor setFill];
            //            [address3RContent drawInRect: address3RRect withFont: [UIFont fontWithName: @"Helvetica" size: 10] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];
            
            
            //// address2R Drawing
            CGRect address2RRect = CGRectMake(CGRectGetMinX(frame) + 47, CGRectGetMinY(frame) + 295, 160, 20);
            [strokeColor setFill];
            [address2RContent drawInRect: address2RRect withFont: [UIFont fontWithName: @"Helvetica" size: 10] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];
            //
            //
            //            //// address1R Drawing
            CGRect address1RRect = CGRectMake(CGRectGetMinX(frame) + 47, CGRectGetMinY(frame) + 281, 160, 18);
            [strokeColor setFill];
            [address1RContent drawInRect: address1RRect withFont: [UIFont fontWithName: @"Helvetica" size: 10] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];
            
            
            //// receiverLocationName Drawing
            CGRect receiverLocationNameRect = CGRectMake(CGRectGetMinX(frame) + 47, CGRectGetMinY(frame) + 261, 160, 21);
            [strokeColor setFill];
            [receiverLocationNameContent drawInRect: receiverLocationNameRect withFont: [UIFont fontWithName: @"Helvetica" size: 12] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];
            
            
        }
        
        
        //// dynamicSenderDetails
        {
            //// ADDRESSSCITY Drawing
            CGRect aDDRESSSCITYRect = CGRectMake(CGRectGetMinX(frame) + 44, CGRectGetMinY(frame) + 217, 160, 16);
            [strokeColor setFill];
            [aDDRESSSCITYContent drawInRect: aDDRESSSCITYRect withFont: [UIFont fontWithName: @"Helvetica" size: 10] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];
            
            
            //// address3 Drawing
            //            CGRect address3Rect = CGRectMake(CGRectGetMinX(frame) + 44, CGRectGetMinY(frame) + 204, 160, 17);
            //            [strokeColor setFill];
            //            [address3Content drawInRect: address3Rect withFont: [UIFont fontWithName: @"Helvetica" size: 10] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];
            //
            //
            //            //// address2 Drawing
            CGRect address2Rect = CGRectMake(CGRectGetMinX(frame) + 44, CGRectGetMinY(frame) + 191, 160, 20);
            [strokeColor setFill];
            [address2Content drawInRect: address2Rect withFont: [UIFont fontWithName: @"Helvetica" size: 10] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];
            
            
            //// address1 Drawing
            CGRect address1Rect = CGRectMake(CGRectGetMinX(frame) + 44, CGRectGetMinY(frame) + 177, 160, 18);
            [strokeColor setFill];
            [address1Content drawInRect: address1Rect withFont: [UIFont fontWithName: @"Helvetica" size: 10] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];
            //
            //
            //// senderLocationName Drawing
            CGRect senderLocationNameRect = CGRectMake(CGRectGetMinX(frame) + 44, CGRectGetMinY(frame) + 157, 160, 21);
            [strokeColor setFill];
            [senderLocationNameContent drawInRect: senderLocationNameRect withFont: [UIFont fontWithName: @"Helvetica" size: 12] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];
        }
    }
    
    
    //// senderSignatureBox Drawing
    CGRect senderSignatureBoxRect = CGRectMake(CGRectGetMinX(frame) + 67.5, CGRectGetMinY(frame) + 576.5, 115, 57);
    [senderSignature drawInRect:senderSignatureBoxRect];
    
    //// receiverSignatureBox Drawing
    CGRect receiverSignatureBoxRect = CGRectMake(CGRectGetMinX(frame) + 424.5, CGRectGetMinY(frame) + 567.5, 114, 66);
    [receiverSignature drawInRect:receiverSignatureBoxRect];
    
    
    UIGraphicsEndPDFContext();
    NSArray* documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString* documentDirectory = [documentDirectories objectAtIndex:0];
    NSString* documentDirectoryFilename = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf",ref]];
            NSLog(@"aFilename will be wrote: %@", documentDirectoryFilename);
    stop.load.podData = pdfData;
            if (![pdfData writeToFile:documentDirectoryFilename atomically:YES]) {
                NSLog(@"saving file didnt work");
            }
            
        }];
    }
    
}

@end
