//
//  CCSignatureDrawView.h
//  
//
//  Created by shane davis on 24/04/2014.
//
//

#import <UIKit/UIKit.h>
@protocol CCSignatureDrawViewDelegate <NSObject>

-(void)saveSignatureSnapshotAsData:(NSData *)imageData andSignatureBezier:(UIBezierPath*)signatureBezierPath updateQuantity:(NSString*)quantity andDismissView: (UIView*)view;

@end
@interface CCSignatureDrawView : UIImageView <UITextFieldDelegate> {
    CGPoint lastPoint;
    BOOL mouseSwiped;
}

@property(nonatomic,weak) id <CCSignatureDrawViewDelegate> delegate;
@property (nonatomic, strong) CAShapeLayer *pathLayer;
@property(nonatomic,strong)UIBezierPath *signatureBezierPath;
- (id)initWithFrame:(CGRect)frame andQuantity:(NSString*)quantity;
@property(nonatomic,strong)NSString *quantity;
@end




//-(void)saveSignatureSnapshotAsData:(NSData *)imageData;
