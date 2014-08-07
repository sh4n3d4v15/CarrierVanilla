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

#import "NSArray+Flatten.h"
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
    [self addLoadnotesToDataSource];
    self.df = [NSDateFormatter new];
    [self loadMessages];
    NSLog(@"Stop Loadnote count: %i", [_stop.load.loadNotes count]);
}

-(void)addLoadnotesToDataSource{
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
    NSArray *sortedMessages = [[_stop.load.loadNotes allObjects]sortedArrayUsingDescriptors:sortDescriptors];
    NSLog(@"Sorted loadnotes: %@", sortedMessages);
    [sortedMessages enumerateObjectsUsingBlock:^(Loadnote *loadnote, NSUInteger idx, BOOL *stop) {
        [self.dataSource addObject:[self convertLoadnoteToSomessage:loadnote]];
        _lastMessageDate = loadnote.date;
        // NSLog(@"Loadnote date: %@", loadnote);
        [self refreshMessages];
    }];
    
}


-(SOMessage*)convertLoadnoteToSomessage:(Loadnote*)loadnote{
    NSLog(@"convertme");
    SOMessage *newMessage = [SOMessage new];
    newMessage.text = loadnote.text;
    newMessage.media = loadnote.media;
    newMessage.type = loadnote.media ? SOMessageTypePhoto : SOMessageTypeText;
    newMessage.fromMe = [loadnote.fromMe boolValue];
    newMessage.date = loadnote.date;
    return newMessage;
}

- (void)loadMessages
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Retrieving Messages";
    NSLog(@"Loading messages");
    [[CVChepClient sharedClient]getLoadNotesForLoad:self.stop.load.id completion:^(NSDictionary *results, NSError *error) {
        if (error) {
            UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"ERROR" message:@"There was an error retrieving notes" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            
            [av show];
        }else{
            NSArray *notes = [results objectForKey:@"notes"];
           __unused NSArray *flatMessages = @[];
            [notes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj[@"replies"] isKindOfClass:[NSArray class]] && [obj[@"replies"]count]  ) {
                    NSLog(@"A reply: %@", obj[@"replies"]);
                }
            }];
            
            NSSortDescriptor *orderByDate = [[NSSortDescriptor alloc] initWithKey:@"created_date"
                                                                        ascending:YES];
            NSArray *messages = [notes sortedArrayUsingDescriptors:@[orderByDate]];

            [self recursivelyCheckForRepliesAndCreateMessage:messages];
        }
        [hud hide:YES afterDelay:0.5];
        
    }];
}
        




-(void)recursivelyCheckForRepliesAndCreateMessage:(NSArray*)messages{
    //    NSLog(@"Message:")
    
    [_df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    //    [_df setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
   // NSSortDescriptor* sortOrderByCreatedDate = [NSSortDescriptor sortDescriptorWithKey: @"created_date" ascending: YES];
   // messages = [messages sortedArrayUsingDescriptors:@[sortOrderByCreatedDate]];
    [messages enumerateObjectsUsingBlock:^(id message, NSUInteger idx, BOOL *stop) {
        
        NSDate *messageCreatedDate = [_df dateFromString:message[@"created_date"]];
        NSComparisonResult result = [messageCreatedDate compare:_lastMessageDate];
        if (result == NSOrderedDescending || _lastMessageDate == NULL )
        {
//            NSLog(@"This date %@ is earlier than this date %@", messageCreatedDate,_lastMessageDate);
        
            SOMessage *soMessage = [[SOMessage alloc]init];
            soMessage.text = message[@"message"];
            soMessage.fromMe = [[message valueForKey:@"created_by"] isEqualToString:@"APItester"] ? YES : NO;
            soMessage.type = SOMessageTypeText;
            soMessage.date = [_df dateFromString:message[@"created_date"]];
            
            Loadnote *note = [NSEntityDescription insertNewObjectForEntityForName:@"Loadnote" inManagedObjectContext:_managedObjectContext];
            note.text = message[@"message"];
            note.fromMe = [[message valueForKey:@"created_by"] isEqualToString:@"APItester"] ? [NSNumber numberWithBool:YES] : [NSNumber numberWithBool:NO];
            note.type = SOMessageTypeText;
            note.date = [_df dateFromString:message[@"created_date"]];
            NSLog(@"Created date: %@", [_df dateFromString:message[@"created_date"]]);
            
            [_stop.load addLoadNotesObject:note];
            
            [self.dataSource addObject:soMessage];
            NSArray *replies = [message valueForKey:@"replies"];
            if ([replies isKindOfClass:[NSArray class]] && [replies count]) {
                NSLog(@"Running recursion on the replies");
                [self recursivelyCheckForRepliesAndCreateMessage:replies];
                //*stop = YES;
            }else{
                NSLog(@"HERE IS THE DATA SOURCE: %@", _dataSource);
//                [self refreshMessages];
            }
            
        }//end of if

    }];
    [self refreshMessages];
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
    [self sendMessage:soMessage];
    
    [_stop.load addLoadNotesObject:note];
    
    NSError* error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Unable to save context for class");
    } else {
        NSLog(@"saved all records!");
    }
    [self postMessageToServer:soMessage];
}

- (void)messageInputViewDidSelectMediaButton:(SOMessageInputView *)inputView
{
    NSLog(@"media button pressed");
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
}

-(void)postMessageToServer:(SOMessage*)message{
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
    // [self sendMessage:message];
}

#pragma mark - UIImage Picker Delegate Methods

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSData *imageData = UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerOriginalImage], 1);
    
    SOMessage *photoMessage = [[SOMessage alloc]init];
    photoMessage.type = SOMessageTypePhoto;
    photoMessage.media = imageData;
    
    Loadnote *ln = [NSEntityDescription insertNewObjectForEntityForName:@"Loadnote" inManagedObjectContext:_managedObjectContext];
    ln.media = imageData;
    ln.fromMe = [NSNumber numberWithBool:YES];
    ln.date = [NSDate date];
    [_stop.load addLoadNotesObject:ln];
    
    [self sendMessage:photoMessage];

    [[CVChepClient sharedClient]uploadPhoto:imageData forStopId:_stop.id withLoadId:_stop.load.id withComment:@"" completion:^(NSDictionary *responseDic, NSError *error) {
        if (error) {
            UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Message Fail" message:@"Network Error" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [av show];
        }else{
        
        }
            
    }];
}














@end