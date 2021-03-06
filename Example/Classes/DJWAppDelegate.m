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
    DJWSegmentedViewController *viewController = [[DJWSegmentedViewController alloc] initWithControlPlacement:DJWSegmentedViewControllerControlPlacementToolbar controlType:DJWSegmentedViewControllerControlTypeSegmentedControl];
    viewController.swipeGestureEnabled = YES;
    viewController.dataSource = self;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];

    self.window.rootViewController = nav;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (NSInteger)numberOfViewControllers
{
    return 3;
}

- (UIViewController *)DJWSegmentedViewController:(DJWSegmentedViewController *)segmentedViewController viewControllerAtIndex:(NSInteger)index
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

- (NSString *)DJWSegmentedViewController:(DJWSegmentedViewController *)segmentedViewController segmentedControlTitleForIndex:(NSInteger)index
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

@end
