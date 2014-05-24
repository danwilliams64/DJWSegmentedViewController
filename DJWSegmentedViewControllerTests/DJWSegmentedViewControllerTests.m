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

@property (nonatomic, assign) NSInteger test_numberOfViewControllers;
@property (nonatomic, strong) NSArray *test_viewControllers;
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

- (DJWSegmentedViewController *)createSegmentedControllerWithPlacement:(DJWSegmentedViewControllerControlPlacement)placement
{
    self.test_numberOfViewControllers = 3;
    self.test_viewControllers = @[[TestViewController new],
                                  [TestViewController new],
                                  [TestViewController new]];
    
    self.segmentedViewController = [[DJWSegmentedViewController alloc] initWithControlPlacement:placement];
    self.segmentedViewController.dataSource = self;
    self.segmentedViewController.delegate = self;

    return self.segmentedViewController;
}

- (void)testSegmentedControlAddedToNavigationBar
{
    self.segmentedViewController = [self createSegmentedControllerWithPlacement:DJWSegmentedViewControllerControlPlacementNavigationBar];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.segmentedViewController];
    
    XCTAssertEqual(nav.topViewController.navigationItem.titleView, self.segmentedViewController.segmentedControl, @"The title view of the navigation controller's topViewController should equal the segmented control of the segmented view controller.");
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

- (void)testCreateSegmentedViewControllerWith3Segments
{
    self.segmentedViewController = [self createSegmentedControllerWithPlacement:DJWSegmentedViewControllerControlPlacementNavigationBar];
    XCTAssertTrue(self.segmentedViewController.segmentedControl.numberOfSegments == 3, @"There should be 3 segments in the segmented control.");
}

- (void)testSetViewControllerToDisplayViewControllerAtIndex2
{
    self.segmentedViewController = [self createSegmentedControllerWithPlacement:DJWSegmentedViewControllerControlPlacementNavigationBar];
    [self.segmentedViewController setCurrentViewControllerIndex:2 animated:NO];
    XCTAssertTrue(self.segmentedViewController.currentViewControllerIndex == 2, @"The segmented view controller's current index should be 2.");
}

- (void)testViewControllerAtIndex2
{
    self.segmentedViewController = [self createSegmentedControllerWithPlacement:DJWSegmentedViewControllerControlPlacementNavigationBar];
    UIViewController *index2ViewController = self.test_viewControllers[2];

    [self.segmentedViewController setCurrentViewControllerIndex:2 animated:NO];
    XCTAssertEqual(self.segmentedViewController.currentViewController, index2ViewController, @"The segmented view controller should return a viewController equal to index2ViewController.");
}

- (void)testSegmentedControlTitleShouldEqualGivenTitle
{
    self.segmentedViewController = [self createSegmentedControllerWithPlacement:DJWSegmentedViewControllerControlPlacementNavigationBar];
    NSString *segment0Title = [self.segmentedViewController.segmentedControl titleForSegmentAtIndex:0];
    XCTAssertEqual(segment0Title, [self DJWSegmentedViewController:self.segmentedViewController segmentedControlTitleForIndex:0], @"The segmented control's title for segment 0 should equal 'First'.");
}

- (NSInteger)numberOfViewControllers
{
    return self.test_numberOfViewControllers;
}

- (UIViewController *)DJWSegmentedViewController:(DJWSegmentedViewController *)segmentedViewController viewControllerAtIndex:(NSInteger)index
{
    return self.test_viewControllers[index];
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
