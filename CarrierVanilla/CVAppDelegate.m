//
//  CVAppDelegate.m
//  CarrierVanilla
//
//  Created by shane davis on 06/06/2014.
//  Copyright (c) 2014 shane davis. All rights reserved.
//

#import "CVAppDelegate.h"
#import "TestFlight.h"
#import "CVMasterViewController.h"
#import "Pop.h"

@implementation CVAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;




- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [TestFlight takeOff:@"9effd5b8-b826-47d0-a85b-44fade06a340"];
    
    
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    CVMasterViewController *controller = (CVMasterViewController *)navigationController.topViewController;
    controller.managedObjectContext = self.managedObjectContext;
    [[UINavigationBar appearance]setBarTintColor:UIColorFromRGB(0x1070a9)];
    [[UINavigationBar appearance]setTintColor:[UIColor whiteColor]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
 
//    [SOMotionDetector sharedInstance].delegate = self;
//    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
//    {
//        [SOMotionDetector sharedInstance].useM7IfAvailable = YES; //Use M7 chip if available, otherwise use lib's algorithm
//    }
//    [[SOMotionDetector sharedInstance] startDetection];
//    
//    _driverSafeOverlay = [[UIView alloc]initWithFrame:CGRectMake(0, self.window.frame.size.height, self.window.frame.size.width, self.window.frame.size.height)];
//    _driverSafeOverlay.backgroundColor = UIColorFromRGB(0x1070a9);
//    
//    NSLog(@"Frame: %@" , NSStringFromCGRect( _driverSafeOverlay.frame) );
//    
//    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, self.window.frame.size.height/2, self.window.frame.size.width, 30)];
//    label.textColor = [UIColor whiteColor];
//    label.font = [UIFont systemFontOfSize:20.0f];
//    label.text = @"Safe Driving Mode";
//    label.textAlignment = NSTextAlignmentCenter;
//    
//    [_driverSafeOverlay addSubview:label];
//    
//    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(85, 100, 150, 150)];
//    [imageView setImage:[UIImage imageNamed:@"steeringwheel"]];
//    
//    [_driverSafeOverlay addSubview:imageView];

    return YES;
}
-(void)overlayDriveSafeView{
    [self.window addSubview:_driverSafeOverlay];
    POPSpringAnimation *yAnim = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    yAnim.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, self.window.frame.size.width, self.window.frame.size.height)];
    [_driverSafeOverlay pop_addAnimation:yAnim forKey:@"growHeight"];
}
-(void)removeDriveSafeView{
    
    POPSpringAnimation *yAnim = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    yAnim.toValue = [NSValue valueWithCGRect:CGRectMake(0, self.window.frame.size.height, self.window.frame.size.width, self.window.frame.size.height)];
    [yAnim setCompletionBlock:^(POPAnimation *anim, BOOL complete) {
        [_driverSafeOverlay removeFromSuperview];
    }];
    [_driverSafeOverlay pop_addAnimation:yAnim forKey:@"shrinkHeight"];
    
    
   
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MobLog" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MobLog"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
       // abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Motion Delegate Methods

//- (void)motionDetector:(SOMotionDetector *)motionDetector motionTypeChanged:(SOMotionType)motionType
//{
//    switch (motionType) {
//        case MotionTypeNotMoving:
//            [self removeDriveSafeView];
//            break;
//        case MotionTypeWalking:
//            [self removeDriveSafeView];
//            break;
//        case MotionTypeRunning:
//            [self removeDriveSafeView];
//            break;
//        case MotionTypeAutomotive:
//            [self overlayDriveSafeView];
//            break;
//    }
//}
//
//- (void)motionDetector:(SOMotionDetector *)motionDetector locationChanged:(CLLocation *)location
//{
//    NSLog(@"Speed: %@ ",[NSString stringWithFormat:@"%.2f km/h",motionDetector.currentSpeed * 3.6f]) ;
//}
//
//- (void)motionDetector:(SOMotionDetector *)motionDetector accelerationChanged:(CMAcceleration)acceleration
//{
////    BOOL isShaking = motionDetector.isShaking;
////    self.isShakingLabel.text = isShaking ? @"shaking":@"not shaking";
//}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
