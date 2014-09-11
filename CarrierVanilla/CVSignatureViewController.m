//
//  CVSignatureViewController.m
//  Chep Carrier
//
//  Created by shane davis on 21/08/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import "CVSignatureViewController.h"
#import "Item.h"
#import "SignatureView.h"
#import "UIColor+MLPFLatColors.h"
#import "CVItemTableViewCell.h"

#import <POP/POP.h>
@interface CVSignatureViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UITextViewDelegate>
@property (weak, nonatomic) IBOutlet SignatureView *signatureView;
- (IBAction)acceptPressed:(id)sender;
- (IBAction)cancelPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UITextView *textField;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITableView *talbeView;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property CGRect orginalNameFieldFrame;
@property CGRect orginalTextFieldFrame;

@end

@implementation CVSignatureViewController

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
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardShow:) name:UIKeyboardWillShowNotification object:nil];


//    _containerView.layer.borderColor = [[UIColor flatBlueColor]CGColor];
//    _containerView.layer.borderWidth = 3;
//    _containerView.layer.cornerRadius = 3;
//    _containerView.backgroundColor = [UIColor clearColor];
//    _containerView.backgroundColor =[UIColor flatRedColor];
    
    self.talbeView.dataSource = self;
    self.talbeView.delegate = self;
    self.talbeView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.talbeView.separatorColor = [UIColor clearColor];
    
    NSLog(@"Items array: %@", _itemsArray);
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleTap];

    // Do any additional setup after loading the view.
    self.signatureView.foregroundLineColor = [UIColor flatGrayColor];
    self.signatureView.backgroundLineColor = [UIColor flatDarkBlueColor];
    
    
    _textField.textColor =  UIColorFromRGB(0x3c6ba1);
    _textField.delegate = self;
    _textField.returnKeyType = UIReturnKeyDone;
    
    _nameField.textColor =  UIColorFromRGB(0x3c6ba1);
    _nameField.delegate = self;
    
    _orginalNameFieldFrame = _nameField.frame;
    _orginalTextFieldFrame = _textField.frame;
    
    [self addStyleToView:_textField];
    [self addStyleToView:_nameField];
    [self addStyleToView:_signatureView];
    

}


-(void)addStyleToView:(UIView*)view{
    
    view.backgroundColor = [UIColor colorWithRed:60/255.0f green:107/255.0f blue:161/255.0f alpha:0.05f];
    view.layer.borderColor = [UIColor colorWithRed:60/255.0f green:107/255.0f blue:161/255.0f alpha:0.2f].CGColor;
    view.layer.borderWidth = 1;
    view.layer.cornerRadius = 3;
}

-(void)handleSingleTap:(UIGestureRecognizer*)gesture{
    [self.view endEditing:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -Tableview methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_itemsArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CVItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    Item *item = _itemsArray[indexPath.row];
    cell.productLabel.text = [NSString stringWithFormat:@"%@", item.product_description];
    cell.productLabel.font = [UIFont fontWithName:@"HelveticaNeue-light" size:12];

    
    UILabel *qtyField  = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(cell.bounds)-60, 20, 50, 30)];
    qtyField.text = [item.updated_pieces stringValue];
    qtyField.layer.borderColor = [UIColor whiteColor].CGColor;
    
    NSLog(@"Updaated pieces: %@", item.updated_pieces);
     NSLog(@"Pieces: %@", item.pieces);
    
    if ([item.updated_pieces integerValue] > [item.pieces integerValue]) {
        qtyField.textColor = [UIColor flatDarkGreenColor];
    } else if([item.updated_pieces integerValue] < [item.pieces integerValue]) {
        qtyField.textColor = [UIColor flatDarkRedColor];
    }else{
        qtyField.textColor = UIColorFromRGB(0x3c6ba1);
    }
    
    qtyField.font = [UIFont fontWithName:@"HelveticaNeue-light" size:13];
    qtyField.backgroundColor =  [UIColor colorWithWhite:1 alpha:.6];
    qtyField.layer.borderWidth = 1;
    qtyField.layer.cornerRadius = 3;
    qtyField.textAlignment = NSTextAlignmentCenter;
    
    [cell addSubview:qtyField];
    return cell;

}

#pragma mark -IBActions
- (IBAction)acceptPressed:(id)sender {
        NSLog(@"Signature data: %@", [self.signatureView signatureData]);
        [self.delegate signatureViewData:[self.signatureView signatureData]];
        [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancelPressed:(id)sender {
    [self.delegate cancelSignatureAndStopCompletion];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -Textfield & Textview methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return  YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}
#pragma mark Keyboard methods

-(void)onKeyboardShow:(NSNotification *)notification
{
    NSLog(@"Hiding keyboard");
    
    
    NSLog(@"Showing keyboard");
    POPSpringAnimation *tableanim = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    tableanim.toValue = [NSValue valueWithCGRect:CGRectMake(_talbeView.frame.origin.x, 242, _talbeView.frame.size.width, _talbeView.frame.size.height)];
    [_talbeView pop_addAnimation:tableanim forKey:@"tableview_position"];
    
    POPSpringAnimation *nameanim = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    nameanim.toValue = [NSValue valueWithCGRect:CGRectMake(_nameField.frame.origin.x, 30, _nameField.frame.size.width, _nameField.frame.size.height)];
    [_nameField pop_addAnimation:nameanim forKey:@"name_position"];
    
    POPSpringAnimation *textanim = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    textanim.toValue = [NSValue valueWithCGRect:CGRectMake(_textField.frame.origin.x, 70, _textField.frame.size.width, _textField.frame.size.height+60)];
    [_textField pop_addAnimation:textanim forKey:@"text_position"];
}

-(void)onKeyboardHide:(NSNotification *)notification
{
    NSLog(@"Showing keyboard");
    POPSpringAnimation *tableanim = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    tableanim.toValue = [NSValue valueWithCGRect:CGRectMake(0, 34, 300, 120)];
    [_talbeView pop_addAnimation:tableanim forKey:@"tableview_position"];
    
    POPSpringAnimation *nameanim = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    nameanim.toValue = [NSValue valueWithCGRect:CGRectMake(0, 242, 300, 30)];
    [_nameField pop_addAnimation:nameanim forKey:@"name_position"];
    
    POPSpringAnimation *textanim = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    textanim.toValue = [NSValue valueWithCGRect:CGRectMake(0, 162, 300, 69)];
    [_textField pop_addAnimation:textanim forKey:@"text_position"];
    
    
    if ([_nameField.text isEqualToString:@""]) {
        NSLog(@"you havnt completed");
    }else{
        _acceptButton.enabled = YES;
    }
    
}
@end
