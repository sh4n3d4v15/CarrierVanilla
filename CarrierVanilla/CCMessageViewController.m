//
//  CCMessageViewController.m
//  ChepCarrier
//
//  Created by shane davis on 02/06/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import "CCMessageViewController.h"
#import "CVChepClient.h"
@interface CCMessageViewController ()


@property (strong, nonatomic) NSMutableArray *dataSource;

@end

@implementation CCMessageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
     
    [self loadMessages];
}

- (void)loadMessages
{
    
    [[CVChepClient sharedClient]getLoadNotesForLoad:@"theLoadId" completion:^(NSArray *results, NSError *error) {
      
        NSMutableArray *messageArray = [[NSMutableArray alloc]init];
        NSDictionary *note = [[[results firstObject]objectForKey:@"notes"]firstObject];
       
            SOMessage *message = [[SOMessage alloc]init];
            message.text = note[@"message"];
            message.fromMe = NO;
            message.type = SOMessageTypeText;
            message.date = [NSDate date];
            [messageArray addObject:message];
            NSLog(@"results: %@", message.text);
            self.dataSource = messageArray;
            [self refreshMessages];
    }];
}

#pragma mark - SOMessaging data source
- (NSMutableArray *)messages
{
    
    return self.dataSource;
}

- (NSTimeInterval)intervalForMessagesGrouping
{
    // Return 0 for disableing grouping
    return 0;
}

- (void)configureMessageCell:(SOMessageCell *)cell forMessageAtIndex:(NSInteger)index
{
    SOMessage *message = self.dataSource[index];
    
    // Adjusting content for 3pt. (In this demo the width of bubble's tail is 6pt)
    if (!message.fromMe) {
        cell.contentInsets = UIEdgeInsetsMake(0, 3.0f, 0, 0); //Move content for 3 pt. to right
        cell.textView.textColor = [UIColor blackColor];
    } else {
        cell.contentInsets = UIEdgeInsetsMake(0, 0, 0, 3.0f); //Move content for 3 pt. to left
        cell.textView.textColor = [UIColor whiteColor];
    }
}

#pragma mark - SOMessaging delegate
- (void)didSelectMedia:(NSData *)media inMessageCell:(SOMessageCell *)cell
{
    // Show selected media in fullscreen
    [super didSelectMedia:media inMessageCell:cell];
}

- (void)messageInputView:(SOMessageInputView *)inputView didSendMessage:(NSString *)message
{
    if (![[message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]) {
        return;
    }
    
    SOMessage *msg = [[SOMessage alloc] init];
    msg.text = message;
    msg.fromMe = YES;
    
    [self postMessageToServer:msg];
}

- (void)messageInputViewDidSelectMediaButton:(SOMessageInputView *)inputView
{
    NSLog(@"media button pressed");
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
    // Take a photo/video or choose from gallery
}

-(void)postMessageToServer:(SOMessage*)message{
    [[CVChepClient sharedClient]postLoadNoteForLoad:[self.stop valueForKeyPath:@"load.id"]
                                     withNoteType:@"MOBILE MESSAGE"
                                     withStopType:self.stop.type
                                     withMessage:message.text completion:^(NSArray *results, NSError *error) {
                                        NSLog(@"posted to server %@" ,[self.stop valueForKeyPath:@"load.id"]);
                                      
                                     }];
    [self sendMessage:message];
}

#pragma mark - UIImage Picker Delegate Methods

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSLog(@"image has been picked");
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSData *imageData = UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerOriginalImage], 1);
    
    SOMessage *photoMessage = [[SOMessage alloc]init];
    photoMessage.type = SOMessageTypePhoto;
    photoMessage.media = imageData;
    photoMessage.fromMe = YES;
    
    [[CVChepClient sharedClient]uploadPhoto:imageData
                                    forStopId:self.stop.id
                                    withLoadId:[self.stop valueForKeyPath:@"load.id"]
                                    withComment:@"UPload from mobile" completion:^(NSArray *results, NSError *error) {
                                        if (error) {
                                            NSLog(@"error %@", [error localizedDescription]);
                                        }else{
                                            NSLog(@"Good upload of photo");
                                        }
                                    }];
    [self postMessageToServer:photoMessage];
}














@end