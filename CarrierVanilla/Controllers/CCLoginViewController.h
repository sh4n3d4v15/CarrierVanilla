//
//  CCLoginViewController.h
//  ChepCarrier
//
//  Created by shane davis on 22/04/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CCLoginViewDelegate <NSObject>

-(void)userLoginWithcredentials:(NSDictionary*)credentials completion:(void(^)(NSError*))completion;

@end

@interface CCLoginViewController : UIViewController<UITextFieldDelegate>

@property id<CCLoginViewDelegate> delegate;

@end
