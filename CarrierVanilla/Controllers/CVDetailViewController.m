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
#import "Address.h"
#import "Ref.h"
#import "Shipment.h"
#import "Item.h"
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
    if (self.stop) {
        
        //ADDRESS INFO
        UIView *addressView = [[UIView alloc] initWithFrame:CGRectMake(10, 5, CGRectGetWidth(self.view.bounds)-20, 200)];
        
        UILabel *addressOneLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, CGRectGetWidth(addressView.bounds), 20)];
        addressOneLabel.text = _stop.address.address1;
        
        UILabel *cityLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 30, CGRectGetWidth(addressView.bounds), 20)];
        cityLabel.text = _stop.address.city;
        
        UILabel *stateLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 50, CGRectGetWidth(addressView.bounds), 20)];
        stateLabel.text =  _stop.address.state;
        
        UILabel *zipLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 70, CGRectGetWidth(addressView.bounds), 20)];
        zipLabel.text =  _stop.address.zip;
        
        [addressView addSubview:addressOneLabel];
        [addressView addSubview:cityLabel];
        [addressView addSubview:stateLabel];
        [addressView addSubview:zipLabel];
        
        [self.view addSubview:addressView];
        
        
        NSSet *shipments = [self.stop valueForKey:@"shipments"];
        [[shipments allObjects] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Shipment *shipment =  obj;
            //SHIPEMENT INFO
            UIView *shipmentView = [[UIView alloc] initWithFrame:CGRectMake(10, idx * 160 + 100, CGRectGetWidth(self.view.bounds)-20, 150)];
            shipmentView.backgroundColor = idx == 0 ?  [UIColor greenColor] : [UIColor redColor];
            UILabel *shipNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, CGRectGetWidth(shipmentView.bounds), 20)];
            shipNumberLabel.text = shipment.shipment_number;

            
            [shipmentView addSubview:shipNumberLabel];

            
            [self.view addSubview:shipmentView];
            
            //ITEMS
            NSArray *items = [shipment.items allObjects];
            [items enumerateObjectsUsingBlock:^(Item* item, NSUInteger idx, BOOL *stop) {
       
                UILabel *itemLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, (idx+2)*20, CGRectGetWidth(self.view.bounds), 20)];
                itemLabel.text = [NSString stringWithFormat:@"%@ %@",item.product_description, item.pieces];
                [shipmentView addSubview:itemLabel];
            }];
            
            UILabel *commentsLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, (items.count +2 )*20, CGRectGetWidth(shipmentView.bounds), 20 )];
            commentsLabel.text = shipment.comments;
            [shipmentView addSubview:commentsLabel];

        }];//end of shipments


    }
}

- (void)viewDidLoad
{
    self.edgesForExtendedLayout = UIRectEdgeNone;
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 100, 50)];
//    label.text = @"youfoiasdufasd";
//    [self.view addSubview:label];
    
    [super viewDidLoad];
//    [self.delegate saveChangesOnContext];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
