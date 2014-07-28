//
//  CCMessageViewController.m
//  ChepCarrier
//
//  Created by shane davis on 02/06/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import "CCMessageViewController.h"
#import "CVChepClient.h"
#import "MBProgressHUD.h"
#import "Loadnote.h"
#import "CVAppDelegate.h"
#import "Load.h"
@interface CCMessageViewController ()


@property (strong, nonatomic) NSMutableArray *dataSource;

@end

@implementation CCMessageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataSource = [[NSMutableArray alloc]init];
    CVAppDelegate *dmgr = (CVAppDelegate *)[UIApplication sharedApplication].delegate;
    self.managedObjectContext = dmgr.managedObjectContext;
    [self loadMessages];
}

//- (void)loadMessages
//{
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    hud.labelText = @"Retrieving Messages";
//    NSLog(@"Loading messages");
//    [[CVChepClient sharedClient]getLoadNotesForLoad:self.load.id completion:^(NSDictionary *results, NSError *error) {
//        if (error) {
//            UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"ERROR" message:@"There was an error retrieving notes" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//            [av show];
//        }
//        [hud hide:YES afterDelay:0.5];
//        NSArray *notes = [results objectForKey:@"notes"];
//        [self recursivelyCheckForRepliesAndCreateMessage:notes];
//    }];
//}

-(void)loadMessages{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Updating Messages";
    [[CVChepClient sharedClient]getLoadNotesForLoad:self.stop.load.id completion:^(NSDictionary *results, NSError *error) {
        if (error) {
            UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"ERROR" message:@"There was an error retrieving notes" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [av show];
        }
        NSArray *notes = [results objectForKey:@"notes"];
        NSLog(@"NOtes: %@", notes);
        if ([notes count]<1) {
            hud.labelText = @"No new notes";
            
        }
        [hud hide:YES afterDelay:1];
        [self recursivelyCheckForRepliesAndCreateMessage:notes];
    }];
    
    
//    [[self.stop.loadNotes allObjects]enumerateObjectsUsingBlock:^(Loadnote *message, NSUInteger idx, BOOL *stop) {
//        SOMessage *soMessage = [[SOMessage alloc]init];
//        soMessage.text = message.text;
//        soMessage.fromMe = [message.fromMe boolValue];
//        soMessage.type = message.thumbnail ? SOMessageTypePhoto : SOMessageTypeText;
//        soMessage.thumbnail = message.thumbnail ? [UIImage imageWithData:message.thumbnail] : nil;
//        soMessage.media = message.media ? message.media : nil;
//        soMessage.date = message.date;
//        [self.dataSource addObject:soMessage];
//    }];
   // [self refreshMessages];
}

//..26 June Lean Update Request - 03 July Lean Update
-(void)recursivelyCheckForRepliesAndCreateMessage:(NSArray*)messages{
    [messages enumerateObjectsUsingBlock:^(id message, NSUInteger idx, BOOL *stop) {
        SOMessage *soMessage = [[SOMessage alloc]init];
        soMessage.text = message[@"message"];
        soMessage.fromMe = [[message valueForKey:@"created_by"] isEqualToString:@"APItester"] ? YES : NO;
        soMessage.type = SOMessageTypeText;
        soMessage.date = [[NSDateFormatter new]dateFromString:message[@"created_date"]];
        [self.dataSource addObject:soMessage];
        NSArray *replies = [message valueForKey:@"replies"];
        if ([replies count]) {
            [self recursivelyCheckForRepliesAndCreateMessage:replies];
            *stop = YES;
        }else{
            [self refreshMessages];
        }
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
    
    Loadnote *note = [NSEntityDescription insertNewObjectForEntityForName:@"Loadnote" inManagedObjectContext:self.managedObjectContext];
    note.text = message;
    note.date = [NSDate date];
    note.fromMe = [NSNumber numberWithBool:YES];
    

    SOMessage *soMessage = [[SOMessage alloc]init];
    soMessage.text = message;
    soMessage.fromMe = YES;
    soMessage.type = SOMessageTypeText;
    soMessage.date = note.date;
//    [self sendMessage:soMessage];
    
    [self.stop addLoadNotesObject:note];
    
    NSError* error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Unable to save context for class");
    } else {
        NSLog(@"saved all records!");
    }
    [self postMessageToServer:note withSoMessage:soMessage];
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

-(void)postMessageToServer:(Loadnote*)message withSoMessage:(SOMessage*)soMessage{
    [[CVChepClient sharedClient]postLoadNoteForLoad:self.stop.load.id
                                     withNoteType:@"MOBILE MESSAGE"
                                     withStopType:@"some"
                                     withMessage:message.text completion:^(NSDictionary *results, NSError *error) {
                                         if (error) {
                                             NSLog(@"error, %@", error);
                                             UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Message Fail" message:@"No connection to server" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                                             [av show];
                                             
                                         }else{
                                             NSLog(@"SUCCESS: %@", results);
                                         }
                                     }];
    [self sendMessage:soMessage];
}

#pragma mark - UIImage Picker Delegate Methods

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSLog(@"image has been picked");
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSData *imageData = UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerOriginalImage], 1);
    
    SOMessage *photoMessage = [[SOMessage alloc]init];
    photoMessage.type = SOMessageTypePhoto;
    photoMessage.media = imageData;
    photoMessage.thumbnail = [UIImage imageWithData:imageData];
    photoMessage.fromMe = YES;
    
    Loadnote *note = [NSEntityDescription insertNewObjectForEntityForName:@"Loadnote" inManagedObjectContext:self.managedObjectContext];
    note.date = [NSDate date];
    note.fromMe = [NSNumber numberWithBool:YES];
    note.thumbnail = imageData;
    note.media = imageData;
    note.type = SOMessageTypeText;
   
    
    NSError* error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Unable to save context for class");
    } else {
        NSLog(@"saved all records!");
    }
    //[self postMessageToServer:msg];

    
    [self.stop addLoadNotesObject:note];
    [self sendMessage:photoMessage];
    
    [[CVChepClient sharedClient]uploadPhoto:imageData
                                    forStopId:self.stop.id
                                    withLoadId:self.stop.load.id
                                    withComment:@"Upload from mobile application" completion:^(NSDictionary *responseDic, NSError *error) {
                                        if (error) {
                                            NSLog(@"error %@", [error localizedDescription]);
                                        }else{
                                            NSLog(@"Good upload of photo %@", responseDic);
                                        }
                                    }];
   // [self postMessageToServer:photoMessage];
}














@end