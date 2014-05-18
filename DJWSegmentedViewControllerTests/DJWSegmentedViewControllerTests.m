//
//  DJWSegmentedViewControllerTests.m
//  DJWSegmentedViewControllerTests
//
//  Created by Dan Williams on 17/05/2014.
//  Copyright (c) 2014 Dan Williams. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DJWSegmentedViewController.h"

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



- (void)testSegmentedControlAddedToNavigationBar
{
    self.segmentedViewController = [[DJWSegmentedViewController alloc] initWithControlPlacement:DJWSegmentedViewControllerControlPlacementNavigationBar];
    self.segmentedViewController.dataSource = self;
    self.segmentedViewController.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.segmentedViewController];
}

@end
