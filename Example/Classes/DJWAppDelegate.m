//
//  DJWAppDelegate.m
//  DJWSegmentedViewController
//
//  Created by Dan Williams on 17/05/2014.
//  Copyright (c) 2014 Dan Williams. All rights reserved.
//

#import "DJWAppDelegate.h"
#import "DJWSegmentedViewController.h"
#import "TestViewController.h"

@interface DJWAppDelegate() <DJWSegmentedViewControllerDataSource, DJWSegmentedViewControllerDelegate>

@end

@implementation DJWAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    DJWSegmentedViewController *viewController = [[DJWSegmentedViewController alloc] initWithControlPlacement:DJWSegmentedViewControllerControlPlacementNavigationBar];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
    viewController.dataSource = self;

    self.window.rootViewController = nav;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (NSUInteger)numberOfViewControllers
{
    return 3;
}

- (UIViewController *)DJWSegmentedViewController:(DJWSegmentedViewController *)segmentedViewController viewControllerAtIndex:(NSUInteger)index
{
    TestViewController *viewController = [TestViewController new];
    switch (index) {
        case 0:
            viewController.view.backgroundColor = [UIColor redColor];
            viewController.string = @"One";
            break;
        case 1:
            viewController.view.backgroundColor = [UIColor blueColor];
            viewController.string = @"Two";
            break;
        case 2:
            viewController.view.backgroundColor = [UIColor greenColor];
            viewController.string = @"Three";
            break;
            
        default:
            break;
    }
    
    return viewController;
}

- (NSString *)DJWSegmentedViewController:(DJWSegmentedViewController *)segmentedViewController segmentedControlTitleForIndex:(NSUInteger)index
{
    switch (index) {
        case 0:
            return @"First";
            break;
        case 1:
            return @"Second";
            break;
        case 2:
            return @"Third";
            break;
            
        default:
            return @"";
            break;
    }
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
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
