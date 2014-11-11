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

- (void)viewDidLoad {
	[super viewDidLoad];
	self.dataSource = [[NSMutableArray alloc]init];
	CVAppDelegate *dmgr = (CVAppDelegate *)[UIApplication sharedApplication].delegate;
	self.managedObjectContext = dmgr.managedObjectContext;
	[self addLoadnotesToDataSource];
	self.df = [NSDateFormatter new];
	[self.df setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
	[self loadMessages];
}

- (void)addLoadnotesToDataSource {
	NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
	NSArray *sortedMessages = [[_stop.load.loadNotes allObjects]sortedArrayUsingDescriptors:sortDescriptors];
	[sortedMessages enumerateObjectsUsingBlock: ^(Loadnote *loadnote, NSUInteger idx, BOOL *stop) {
	    [self.dataSource addObject:[self convertLoadnoteToSomessage:loadnote]];
	    _lastMessageDate = loadnote.date;
	    [self refreshMessages];
	}];
}

- (SOMessage *)convertLoadnoteToSomessage:(Loadnote *)loadnote {
	NSLog(@"convertme");
	SOMessage *newMessage = [SOMessage new];
	newMessage.text = loadnote.text;
	newMessage.media = loadnote.media;
	newMessage.type = loadnote.media ? SOMessageTypePhoto : SOMessageTypeText;
	newMessage.fromMe = [loadnote.fromMe boolValue];
	newMessage.date = loadnote.date;
	return newMessage;
}

- (void)loadMessages {
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	hud.labelText = NSLocalizedString(@"Retrieving Messages", nil);
	[[CVChepClient sharedClient]getLoadNotesForLoad:self.stop.load.id completion: ^(NSArray *results, NSError *error) {
        NSLog(@"RESULTS OBJECT IN MESSAGECONTROLLER: %@",results);
	    NSLog(@"Getting load notes for Load: %@", self.stop.load.id);
	    if (error) {
            if(error.code == 401){
                hud.labelText = NSLocalizedString(@"no new notes",nil);
                [hud hide:YES afterDelay:2.0];
            }else{
                UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Error" message:NSLocalizedString(@"ConnectionError", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                NSLog(@"this is the error: %@", error);
                [av show];
            }

		}
	    else {
	        NSSortDescriptor *orderByDate = [[NSSortDescriptor alloc] initWithKey:@"created_date"
	                                                                    ascending:YES];
	        NSArray *messages = [results sortedArrayUsingDescriptors:@[orderByDate]];
	        [self recursivelyCheckForRepliesAndCreateMessage:messages];
		}
	    [hud hide:YES afterDelay:0.5];
	}];
}

- (void)recursivelyCheckForRepliesAndCreateMessage:(NSArray *)messages {
	NSDictionary *userinfo = [[NSUserDefaults standardUserDefaults]objectForKey:@"userinfo"];
	NSString *name =  [userinfo valueForKey:@"carrier"];

	NSLog(@"name == %@", name);

	[_df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
	NSSortDescriptor *sortOrderByCreatedDate = [NSSortDescriptor sortDescriptorWithKey:@"created_date" ascending:YES];

	NSArray *replies = [[messages valueForKey:@"replies"]firstObject];

//    NSMutableArray *replies;
//    [messages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        NSArray *reply = [obj valueForKey:@"replies"];
//        NSLog(@"adding reply: %@", reply);
//        [replies addObject:[reply firstObject]];
//    }];

	NSArray *flatMessages = [messages arrayByAddingObjectsFromArray:replies];
	NSArray *flatMessagesSorted = [flatMessages sortedArrayUsingDescriptors:@[sortOrderByCreatedDate]];
	NSLog(@"These are the flat sorted messages: %@", flatMessagesSorted);
	[flatMessagesSorted enumerateObjectsUsingBlock: ^(id message, NSUInteger idx, BOOL *stop) {
	    NSDate *messageCreatedDate = [_df dateFromString:message[@"created_date"]];
	    NSComparisonResult result = [messageCreatedDate compare:_lastMessageDate];
	    NSLog(@"Last message date is : %@", _lastMessageDate);
	    NSLog(@"Comparison result : %ld", (unsigned long)result);
	    if (result == NSOrderedDescending || _lastMessageDate == NULL) {
	        NSLog(@"I am inside the if condition with message: %@", message);
	        SOMessage *soMessage = [[SOMessage alloc]init];
	        soMessage.text = message[@"message"];
	        soMessage.fromMe = [[message valueForKey:@"created_by"] isEqualToString:name] ? YES : NO;
	        soMessage.type = SOMessageTypeText;
	        soMessage.date = [_df dateFromString:message[@"created_date"]];

	        Loadnote *note = [NSEntityDescription insertNewObjectForEntityForName:@"Loadnote" inManagedObjectContext:_managedObjectContext];
	        note.text = message[@"message"];
	        note.fromMe = [[message valueForKey:@"created_by"] isEqualToString:name] ? [NSNumber numberWithBool:YES] : [NSNumber numberWithBool:NO];
	        note.type = SOMessageTypeText;
	        note.date = [_df dateFromString:message[@"created_date"]];

	        [_stop.load addLoadNotesObject:note];
	        [self.dataSource addObject:soMessage];
		} //end of if
	}];
	[self refreshMessages];
}

#pragma mark - SOMessaging data source
- (NSMutableArray *)messages {
	return self.dataSource;
}

- (NSTimeInterval)intervalForMessagesGrouping {
	// Return 0 for disableing grouping
	return 60 * 60;
}

- (void)configureMessageCell:(SOMessageCell *)cell forMessageAtIndex:(NSInteger)index {
	SOMessage *message = self.dataSource[index];

	// Adjusting content for 3pt. (In this demo the width of bubble's tail is 6pt)
	if (!message.fromMe) {
		cell.contentInsets = UIEdgeInsetsMake(0, 3.0f, 0, 0); //Move content for 3 pt. to right
		cell.textView.textColor = [UIColor blackColor];
	}
	else {
		cell.contentInsets = UIEdgeInsetsMake(0, 0, 0, 3.0f); //Move content for 3 pt. to left
		cell.textView.textColor = [UIColor whiteColor];
	}
}

#pragma mark - SOMessaging delegate
- (void)didSelectMedia:(NSData *)media inMessageCell:(SOMessageCell *)cell {
	// Show selected media in fullscreen
	[super didSelectMedia:media inMessageCell:cell];
}

- (void)messageInputView:(SOMessageInputView *)inputView didSendMessage:(NSString *)message {
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

	NSError *error = nil;
	if (![self.managedObjectContext save:&error]) {
		NSLog(@"Unable to save context for class");
	}
	else {
		NSLog(@"saved all records!");
	}
	[self postMessageToServer:soMessage];
}

- (void)messageInputViewDidSelectMediaButton:(SOMessageInputView *)inputView {
	NSLog(@"media button pressed");
	UIImagePickerController *picker = [[UIImagePickerController alloc]init];
	picker.sourceType = UIImagePickerControllerSourceTypeCamera;
	picker.delegate = self;
	picker.allowsEditing = YES;
	[self presentViewController:picker animated:YES completion:nil];
}

- (void)postMessageToServer:(SOMessage *)message {
	[[CVChepClient sharedClient]postLoadNote:message.text forLoad:_stop.load.id withNoteType:@"" andStopType:_stop.type completion: ^(NSError *error) {
	    if (error) {
	        NSLog(@"error, %@", error);
	        UIAlertView *av = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"ConnectionError", nil) message:NSLocalizedString(@"ConnectionError", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	        [av show];
		}
	}];
	// [self sendMessage:message];
}

#pragma mark - UIImage Picker Delegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
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

	[[CVChepClient sharedClient]uploadDocument:imageData ofType:@"image" forStop:_stop.id onLoad:_stop.load.id withComment:@"" completion: ^(NSError *error) {
	    if (error) {
	        UIAlertView *av = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"ConnectionError", nil) message:NSLocalizedString(@"ConnectionError", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	        [av show];
		}
	    else {
		}
	}];
}

@end
