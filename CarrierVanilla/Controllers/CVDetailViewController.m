//
//  CVDetailViewController.m
//  CarrierVanilla
//
//  Created by shane davis on 06/06/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import "CVDetailViewController.h"
#import "Stop.h"
#import "Shipment.h"
@interface CVDetailViewController ()
- (void)configureView;
@end

@implementation CVDetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)stop
{
    if (_stop != stop) {
        _stop = stop;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [[self.stop valueForKey:@"location_name"] description];
        NSArray *shipments = [self.detailItem valueForKey:@"shipments"];
        [shipments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSArray *items = [obj valueForKey:@"items"];
            [items enumerateObjectsUsingBlock:^(id ibj, NSUInteger idx, BOOL *stop) {
                NSLog(@"an item:: %@", [ibj valueForKey:@"pieces"] );
            }];
        }];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.delegate saveChangesOnContext];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
