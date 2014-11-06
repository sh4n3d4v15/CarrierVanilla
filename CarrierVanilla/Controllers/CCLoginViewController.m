//
//  CCLoginViewController.m
//  ChepCarrier
//
//  Created by shane davis on 22/04/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import "CCLoginViewController.h"
#import "HTAutocompleteTextField.h"
#import "HTAutocompleteManager.h"
#import "UIColor+MLPFLatColors.h"
#import "MBProgressHUD.h"
#import "Pop.h"

#import "CVChepClient.h"


@interface CCLoginViewController ()
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;

@property (weak, nonatomic) IBOutlet UITextField *carrierTextField;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *loginInfoLabel;
- (IBAction)submitButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation CCLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    self.view.backgroundColor = UIColorFromRGB(0x3c6ba1);
    [super viewDidLoad];
    [HTAutocompleteTextField setDefaultAutocompleteDataSource:[HTAutocompleteManager sharedManager]];

    if ([[NSUserDefaults standardUserDefaults]valueForKey:@"carrierID"]) {
        self.carrierTextField.alpha = 0;
        self.carrierTextField.enabled = NO;
        __unused CGRect offsetRect = CGRectOffset(_containerView.frame, 0, 145.0f);
        
        POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
        anim.toValue = [NSValue valueWithCGPoint:CGPointMake(150, 180)];
        anim.springBounciness = 10;
        anim.springSpeed = 2;
        
        
        [_containerView.layer pop_addAnimation:anim forKey:@"position"];
    }
    self.passwordTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.nameTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.carrierTextField.borderStyle = UITextBorderStyleRoundedRect;

}
-(void)viewDidAppear:(BOOL)animated{
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleTap];
    [super viewDidAppear:animated];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    [_carrierTextField resignFirstResponder];
    [_nameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Text Field Delegate

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBounds];
    anim.toValue = [NSValue valueWithCGRect:CGRectInset(textField.bounds, -2, -2)];
    anim.springBounciness = 20;
    [textField.layer pop_addAnimation:anim forKey:@"bounds"];
}
//-(void)textFieldDidBeginEditing:(UITextField *)textField{
//    POPSpringAnimation *anim =
//}
#pragma mark Todo: add validation here
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];

    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBounds];
    anim.toValue = [NSValue valueWithCGRect:CGRectInset(textField.bounds, 2, 2)];
    anim.springBounciness = 20;
    [textField.layer pop_addAnimation:anim forKey:@"bounds"];
}
-(void)resetFields{
    _carrierTextField.text = @"";
    _nameTextField.text = @"";
    _passwordTextField.text = @"";
}

- (IBAction)submitButtonPressed:(id)sender {
    
    _loginInfoLabel.text = @"";
    
    NSString *name      = [_carrierTextField.text copy];//@"APITester";
    NSString *vehicle   = [_nameTextField.text copy];
    NSString *password  = [_passwordTextField.text copy];//@"QVBJVDNzdDNyX3A0c3N3MHJk";
    if ([name isEqualToString:@""] || [vehicle isEqualToString:@""] || [password isEqualToString:@""]) {
        _loginInfoLabel.text = NSLocalizedString(@"Credentials missing", @"Credentials missing");
    }
    else {
        NSDictionary *credentials = @{ @"name":name, @"vehicle":vehicle, @"password":password };
        [_delegate userLoginWithcredentials:credentials completion: ^(NSError *error) {
            if (error) {
                switch (error.code) {
                    case 100:
                        _loginInfoLabel.text = NSLocalizedString(@"No loads for user", @"No loads for user");
                        break;
                        
                    case 401:
                        _loginInfoLabel.text = NSLocalizedString(@"Incorrect credentials", @"Incorrect credentials");
                        break;
                        
                    case -1009:
                        _loginInfoLabel.text = NSLocalizedString(@"Network connection error", @"Network connection error");
                        break;
                    case -1003:
                        _loginInfoLabel.text = NSLocalizedString(@"Network connection error", @"Network connection error");
                    default:
                        break;
                }
                [self resetFields];
            }else{
                [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                
            }
        }];
    }
}


















@end
