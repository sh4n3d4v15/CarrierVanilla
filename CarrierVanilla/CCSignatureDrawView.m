//
//  CCSignatureDrawView.m
//  
//
//  Created by shane davis on 24/04/2014.
//
//
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#import "CCSignatureDrawView.h"
@implementation CCSignatureDrawView

- (id)initWithFrame:(CGRect)frame andQuantity:(NSString*)quantity
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.signatureBezierPath = [[UIBezierPath alloc]init];
        NSLog(@"THE SELF QUANTITY %@ ", quantity);
        _quantity = quantity;
       self.backgroundColor = [UIColor whiteColor];
//        self.alpha = 0.5f;
        self.userInteractionEnabled = YES;
        

        
        UILabel *confirmLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 40, 200, 40)];
        confirmLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:22.0f];
        confirmLabel.textColor = UIColorFromRGB(0x3c6ba1);
        confirmLabel.textAlignment = NSTextAlignmentCenter;
        confirmLabel.text = @"Standard Pallets: ";
        
        [self addSubview:confirmLabel];
        
        UIView *containerView = [[UIView alloc]initWithFrame:self.bounds];
        NSLog(@"Container View Frame: %@", NSStringFromCGRect(containerView.frame));
        
        UITextField *quantityTextField = [[UITextField alloc]initWithFrame:CGRectMake(210, 45, 90, 30)];
        quantityTextField.font = [UIFont fontWithName:@"Helvetica" size:26.0f];
        quantityTextField.textColor = UIColorFromRGB(0x3c6ba1);
        quantityTextField.text = self.quantity;
        quantityTextField.layer.borderColor = UIColorFromRGB(0x3c6ba1).CGColor;
        quantityTextField.layer.borderWidth = 1;
        quantityTextField.layer.cornerRadius = 5;
        quantityTextField.textAlignment = NSTextAlignmentCenter;
        quantityTextField.layer.masksToBounds = YES;
        quantityTextField.delegate = self;
        
        CGRect dottedFrame = CGRectMake(10, 150, 280, 130);
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:dottedFrame cornerRadius:10.0];

        CAShapeLayer *dottedBorder = [CAShapeLayer layer];
        dottedBorder.frame = dottedFrame;
        
        NSLog(@"Dotted border Frame: %@", NSStringFromCGRect(dottedBorder.frame));
        [dottedBorder setStrokeColor:UIColorFromRGB(0x3c6ba1).CGColor];
        [dottedBorder setFillColor:[UIColor clearColor].CGColor];
        [dottedBorder setLineDashPattern:@[[NSNumber numberWithInt:10],[NSNumber numberWithInt:5]]];
        [dottedBorder setLineJoin:kCALineCapRound];
        [dottedBorder setPath:path.CGPath];
//        [drawBox.layer addSublayer:dottedBorder];
//        [containerView addSubview:drawBox];
        [containerView.layer addSublayer:dottedBorder];
        containerView.backgroundColor = [UIColor clearColor];
        [containerView addSubview:quantityTextField];
        [self addSubview:containerView];
        
        CABasicAnimation *strokeEndAnim = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        strokeEndAnim.duration = 0.75f;
        strokeEndAnim.fromValue = [NSNumber numberWithFloat:0.0f];
        strokeEndAnim.toValue = [NSNumber numberWithFloat:1.0f];
        strokeEndAnim.fillMode = kCAFillModeForwards;
        strokeEndAnim.removedOnCompletion = NO;
        
        [dottedBorder addAnimation:strokeEndAnim forKey:nil];
//        self.quantityLabel.alpha = 0.0f;

//        CGRect destinationFrame = CGRectMake(210.0f,454.0f, 90, 30);
        UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        doneButton.frame = CGRectMake(210,454.0f, 90, 30);
        [doneButton setTitle:@"signed" forState:UIControlStateNormal];
        [doneButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [doneButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [doneButton addTarget:self action:@selector(saveImageAndDismissView:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:doneButton];
        
    }
    return self;
}
#pragma mark - Drawing

-(void)saveImageAndDismissView:(id)sender{
    NSLog(@"dismissing");
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    [self.image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    UIImage *saveImage = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImagePNGRepresentation(saveImage);
    [self.delegate saveSignatureSnapshotAsData:imageData andSignatureBezier:self.signatureBezierPath updateQuantity:self.quantity andDismissView:self];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.2f];
    mouseSwiped = NO;
    UITouch *touch = [touches anyObject];
    lastPoint = [touch locationInView:self];
    

}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    mouseSwiped = YES;
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self];
    
    UIGraphicsBeginImageContext(self.frame.size);
    [self.image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    [self.signatureBezierPath moveToPoint:CGPointMake(currentPoint.x, currentPoint.y)];
    [self.signatureBezierPath addLineToPoint:CGPointMake(lastPoint.x, lastPoint.y)];
    
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),  UIColorFromRGB(0x3c6ba1).CGColor);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 2.0f);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0f, 0.0f, 0.0f, 1.0f);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeNormal);
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    lastPoint = currentPoint;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
//    self.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.0f];
    if (!mouseSwiped) {
        UIGraphicsBeginImageContext(self.frame.size);
        [self.image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 2.0f);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0f, 0.0f, 0.0f, 1.0f);
        
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        
        [self.signatureBezierPath moveToPoint:CGPointMake(lastPoint.x, lastPoint.y)];
        [self.signatureBezierPath addLineToPoint:CGPointMake(lastPoint.x, lastPoint.y)];
        
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        self.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    

}

#pragma mark Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    NSString *textValue = textField.text;
    NSLog(@"TEXT VALUE: %@", textValue);
    self.quantity = textValue;
    [textField resignFirstResponder];
        return YES;
}


@end
