//
//  DJWSegmentedViewControllerTests.m
//  DJWSegmentedViewControllerTests
//
//  Created by Dan Williams on 17/05/2014.
//  Copyright (c) 2014 Dan Williams. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DJWSegmentedViewController.h"
#import "TestViewController.h"

@interface DJWSegmentedViewControllerTests : XCTestCase <DJWSegmentedViewControllerDataSource, DJWSegmentedViewControllerDelegate>

@property (nonatomic, strong) DJWSegmentedViewController *segmentedViewController;
@end

@implementation DJWSegmentedViewControllerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
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

- (DJWSegmentedViewController *)createSegmentedControllerWithPlacement:(DJWSegmentedViewControllerControlPlacement)placement
{
    self.segmentedViewController = [[DJWSegmentedViewController alloc] initWithControlPlacement:placement];
    self.segmentedViewController.dataSource = self;
    self.segmentedViewController.delegate = self;

    return self.segmentedViewController;
}

- (void)testSegmentedControlAddedToNavigationBar
{
    self.segmentedViewController = [self createSegmentedControllerWithPlacement:DJWSegmentedViewControllerControlPlacementNavigationBar];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.segmentedViewController];
    
    XCTAssertTrue([nav.topViewController.navigationItem.titleView isEqual:self.segmentedViewController.segmentedControl], @"The title view of the navigation controller's topViewController should equal the segmented control of the segmented view controller.");
}

- (void)testSegmentedControlAddedToToolbar
{
    self.segmentedViewController = [self createSegmentedControllerWithPlacement:DJWSegmentedViewControllerControlPlacementToolbar];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.segmentedViewController];


    __block UISegmentedControl *foundSegmentedControl;
    [nav.topViewController.toolbarItems enumerateObjectsUsingBlock:^(UIBarButtonItem *button, NSUInteger idx, BOOL *stop) {
        if ([button.customView isEqual:self.segmentedViewController.segmentedControl]) {
            foundSegmentedControl = (UISegmentedControl *)button.customView;
            *stop = YES;
        }
    }];
    
    XCTAssertNotNil(foundSegmentedControl, @"The navigation controller's topViewController's toolbarItems should contain a bar button item with the segmented control as its customView.");
}

@end
