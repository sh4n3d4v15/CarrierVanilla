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
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITextField *carrierTextField;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *loginInfoLabel;
- (IBAction)submitButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *logoView;

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
        __unused CGRect offsetRect = CGRectOffset(_logoView.frame, 0, 145.0f);
        
        POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
        anim.toValue = [NSValue valueWithCGPoint:CGPointMake(150, 180)];
        anim.springBounciness = 10;
        anim.springSpeed = 2;
        
        _logoView.backgroundColor = [UIColor redColor];
        [_logoView.layer pop_addAnimation:anim forKey:@"position"];
    }
    self.passwordTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.nameTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.carrierTextField.borderStyle = UITextBorderStyleRoundedRect;

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleTap];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
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


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];//TODO add validation

    return YES;
}

-(void)resetFields{
    _carrierTextField.text = @"";
    _nameTextField.text = @"";
    _passwordTextField.text = @"";
}

- (IBAction)submitButtonPressed:(id)sender {
    
    _loginInfoLabel.text = @"";
    
    NSString *name      = @"TDSadmin";//[_carrierTextField.text copy];
    NSString *vehicle   = [_nameTextField.text copy];
    NSString *password  = @"5UTP71BBYT3SUADBR0VIS8NLJMKUZCIV";//[_passwordTextField.text copy];
    
    if ( [vehicle isEqualToString:@""] ) {
        _loginInfoLabel.text = NSLocalizedString(@"BadCredentials", nil);
    }
    else {
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = NSLocalizedString(@"Loggin message", nil);
        
        NSDictionary *credentials = @{ @"name":name, @"vehicle":vehicle, @"password":password };
        [_delegate userLoginWithcredentials:credentials completion: ^(NSError *error) {
                           [hud hide:YES afterDelay:0.5];
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
#pragma mark UI Methods

-(void)changeButtonColor:(UIButton*)button{
    
    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPViewBackgroundColor];
    anim.toValue = UIColorFromRGB(0xc0392b);
    anim.springBounciness = 5;
    anim.springSpeed = 5;
    [anim setCompletionBlock:^(POPAnimation *anim, BOOL complete) {
        [button pop_removeAllAnimations];
        POPSpringAnimation *inim = [POPSpringAnimation animationWithPropertyNamed:kPOPViewBackgroundColor];
        inim.toValue = UIColorFromRGB(0x339e00);
        inim.springSpeed = 5;
        inim.springBounciness = 5;
        [button pop_addAnimation:inim forKey:@"redBackgroundColor"];
    }];
    [button pop_addAnimation:anim forKey:@"greenbackgroundColor"];
    
}

-(void)animateView:(UIView*)view up:(BOOL)up forValue:(int)value{
    
    
    [view pop_removeAllAnimations];
    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    anim.toValue = [NSValue valueWithCGRect:CGRectMake(view.frame.origin.x, view.frame.origin.y +( up ? -value : value), view.frame.size.width, view.frame.size.height)];
    anim.springBounciness = up ? 1 : 3;
    anim.springSpeed = 15;
    
    [view pop_addAnimation:anim forKey:@"yposition"];
    
}
#pragma mark - Keyboard Methods

-(void)keyboardWillShow{
    [self animateView:_logoView up:YES forValue:150];
    [self animateView:_containerView up:YES forValue:100];
}

-(void)keyboardWillHide{
    NSLog(@"Keyboard is hiding");

    [self animateView:_logoView up:NO forValue:150];
    [self animateView:_containerView up:NO forValue:100];
}

















@end
