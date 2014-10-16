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
@property (weak, nonatomic) IBOutlet UIImageView *chepLogo;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
@property (weak, nonatomic) IBOutlet UITextField *carrierTextField;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *loginInfoLabel;
@property(nonatomic)NSDictionary *keys;
- (IBAction)submitButtonPressed:(id)sender;

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
    self.view.backgroundColor = UIColorFromRGB(0x1070a9);//0x1070a9
    self.passwordTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.nameTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.carrierTextField.borderStyle = UITextBorderStyleRoundedRect;
    

}
-(void)viewDidAppear:(BOOL)animated{
    
    NSError *error;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"keys" ofType:@"json"];
    NSString *myJSON = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    _keys = [NSJSONSerialization JSONObjectWithData:[myJSON dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleTap];
    [super viewDidAppear:animated];
    
    POPSpringAnimation *resize = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    resize.toValue = [NSValue valueWithCGSize:CGSizeMake(2, 2)];
    resize.springBounciness = 10;
    [self.chepLogo.layer pop_addAnimation:resize forKey:@"scale"];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)sender{
    [_carrierTextField resignFirstResponder];
    [_nameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
}



- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

#pragma mark - Text Field Delegate

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBounds];
    anim.toValue = [NSValue valueWithCGRect:CGRectInset(textField.bounds, -2, -2)];
    anim.springBounciness = 20;
    [textField.layer pop_addAnimation:anim forKey:@"bounds"];
}

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

- (IBAction)submitButtonPressed:(id)sender {
    
    NSString *name = [[self.nameTextField text]copy];
    NSString *carrierId =  [[self.carrierTextField text]copy];
    NSString *password =  [_keys valueForKey:carrierId] ?: @"";

   
    if([name isEqualToString:@""] || [carrierId isEqualToString:@""] || [password isEqualToString:@""]){
        self.loginInfoLabel.text = NSLocalizedString(@"BadCredentials", nil);
    }else{
        
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = NSLocalizedString(@"Loggin message", nil);
   
    NSDictionary *userInfo = @{@"vehicle": name , @"carrier": carrierId, @"password":password};
        [_delegate userDidLoginWithDictionary:userInfo completion:^(NSError *error, NSString *message) {
            NSLog(@"ERRORR:: %@", error);
            if(error){
                NSLog(@"there was an error logging in - message %@", message);
                hud.labelText = @"Login error";
                [hud hide:YES afterDelay:0.5];
                self.loginInfoLabel.text = message;
            }else if([message isEqualToString:@"empty"]){
                hud.labelText = @"Login error";
                [hud hide:YES afterDelay:0.5];
                self.loginInfoLabel.text = NSLocalizedString(@"NoLoads", nil);
            } else{
                [hud hide:YES];
                [[NSUserDefaults standardUserDefaults]setObject:userInfo forKey:@"userinfo"];
                [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"userLoggedIn"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }
}
@end
