//
//  CVMasterViewController.m
//  CarrierVanilla
//
//  Created by shane davis on 06/06/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import "CVMasterViewController.h"

#import "CVDetailViewController.h"

#import "CVChepClient.h"
#import "Stop.h"
#import "Load.h"
#import "Address.h"
#import "Ref.h"
#import "Shipment.h"
#import "Item.h"
@interface CVMasterViewController ()<stopChangeDelegate>
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation CVMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [[CVChepClient sharedClient]getStopsForVehicle:@"goo" completion:^(NSArray *results, NSError *error) {
        NSLog(@"results: %@", results);
        [self importArrayOfStopsIntoCoreData:results];
    }];
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
}

#define SET_IF_NOT_NULL(TARGET, VAL) if(VAL != [NSNull null]) { TARGET = VAL; }
- (void)importArrayOfStopsIntoCoreData:(NSArray*)resultsArray
{
    [resultsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop) {
        Load *load = [NSEntityDescription insertNewObjectForEntityForName:@"Load" inManagedObjectContext:self.managedObjectContext];
        load.id = [obj valueForKey:@"id"];
        load.load_number = [obj valueForKey:@"load_number"];
        load.status = [obj valueForKey:@"status"];
        
        NSArray *stops = [obj objectForKey:@"stops"];
        [stops enumerateObjectsUsingBlock:^(id stopobj, NSUInteger idx, BOOL *stop) {
            Stop *_stop = [NSEntityDescription insertNewObjectForEntityForName:@"Stop" inManagedObjectContext:self.managedObjectContext];
            NSLog(@"the location name is of type: %@", [[stopobj valueForKey:@"location_name"]class]);
            //            [_stop setValuesForKeysWithDictionary:stopobj];
//            _stop.location_name = [stopobj valueForKey:@"location_name"];
            SET_IF_NOT_NULL(_stop.location_name , [stopobj valueForKey:@"location_name"]);
            _stop.location_id = [stopobj valueForKey:@"location_id"];
            _stop.location_ref = [stopobj valueForKey:@"location_ref"];
            _stop.type = [stopobj valueForKey:@"type"];
            _stop.planned_start = [stopobj valueForKey:@"planned_start"];
            _stop.planned_end = [stopobj valueForKey:@"planned_end"];
            _stop.weight = [stopobj valueForKey:@"weight"];
            _stop.pallets = [stopobj valueForKey:@"pallets"];
            _stop.pieces = [stopobj valueForKey:@"pieces"];

            Address *address = [NSEntityDescription insertNewObjectForEntityForName:@"Address" inManagedObjectContext:self.managedObjectContext];
            address.address1 = [stopobj valueForKeyPath:@"address.address1"];
            _stop.address = address;

            NSArray *shipments = [stopobj valueForKey:@"shipments"];
            NSLog(@"Shipemnts in master %@", shipments);
            [shipments enumerateObjectsUsingBlock:^(id shipmentObj, NSUInteger idx, BOOL *stop) {
                Shipment *shipment = [NSEntityDescription insertNewObjectForEntityForName:@"Shipment" inManagedObjectContext:self.managedObjectContext];
                shipment.shipment_number = shipmentObj[@"Shipment_number"];
                shipment.comments = shipmentObj[@"comments"];
                
                NSArray *items = [shipmentObj valueForKey:@"items"];
                [items enumerateObjectsUsingBlock:^(id itemObj, NSUInteger idx, BOOL *stop) {
                    Item *item = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
                    item.line = [itemObj valueForKey:@"line"];
                    item.product_id = [itemObj valueForKey:@"product_id"];
                    item.product_description = [itemObj valueForKey:@"product_description"];
                    item.commodity = [itemObj valueForKey:@"commodity"];
                    item.weight = [itemObj valueForKey:@"weight"];
                    item.volume = [itemObj valueForKey:@"volume"];
                    item.pieces = [itemObj valueForKey:@"pieces"];
                    item.lading = [itemObj valueForKey:@"lading"];
                    [shipment addItemsObject:item];
                }];
                
            [_stop addShipmentsObject:shipment];
            [load addStopsObject:_stop];
            }];
        }];
        
        NSArray *refs = [obj valueForKey:@"refs"];
        [refs enumerateObjectsUsingBlock:^(id refobj, NSUInteger idx, BOOL *stop) {
            Ref *_ref = [NSEntityDescription insertNewObjectForEntityForName:@"Ref" inManagedObjectContext:self.managedObjectContext];
            _ref.name = [refobj valueForKey:@"name"];
            _ref.value = [refobj valueForKey:@"value"];
            [load addRefsObject:_ref];
        }];
    }];
    
    NSError* error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Unable to save context for class");
    } else {
        NSLog(@"saved all records!");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
         // Replace this implementation with code to handle the error appropriately.
         // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    int stopCount = [[sectionInfo objects]count];
    return [NSString stringWithFormat:@"Load: %@  Stops: %i",[sectionInfo name],stopCount];

};

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Stop *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        NSLog(@"LOAD: %@",object    );
        CVDetailViewController *dvc = (CVDetailViewController*)[segue destinationViewController];
        [dvc setDetailItem:object];
        dvc.delegate = self;
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Stop" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"load.id" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"load.id" cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */
-(void)saveChangesOnContext{
    NSLog(@"I logged this because i was told to by the detail screen");
}
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [[object valueForKey:@"location_name"] description];
}

@end
