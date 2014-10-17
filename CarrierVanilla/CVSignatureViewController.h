//
//  CVSignatureViewController.h
//  Chep Carrier
//
//  Created by shane davis on 21/08/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CCSignatureViewControllerDelegate <NSObject>

-(void)cancelSignatureAndStopCompletion;
-(void)signatureViewData:(NSData*)signatureData;
@end

@interface CVSignatureViewController : UIViewController
@property(nonatomic)id<CCSignatureViewControllerDelegate>delegate;
@property(nonatomic)NSDictionary *loadInfo;
@end
