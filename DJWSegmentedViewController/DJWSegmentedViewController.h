//
//  DJWSegmentedViewController.h
//  DJWSegmentedViewController
//
//  Created by Dan Williams on 17/05/2014.
//  Copyright (c) 2014 Dan Williams. All rights reserved.
//

@import UIKit;

@class DJWSegmentedViewController;

@protocol DJWSegmentedViewControllerDataSource <NSObject>

- (NSUInteger)numberOfViewControllers;
- (UIViewController *)DJWSegmentedViewController:(DJWSegmentedViewController *)segmentedViewController viewControllerAtIndex:(NSUInteger)index;
- (NSString *)DJWSegmentedViewController:(DJWSegmentedViewController *)segmentedViewController segmentedControlTitleForIndex:(NSUInteger)index;

@end

@protocol DJWSegmentedViewControllerDelegate <NSObject>
@optional
- (void)DJWSegmentedViewController:(DJWSegmentedViewController *)segmentedViewController didMoveToViewControllerAtIndex:(NSUInteger)newIndex;

@end

typedef NS_ENUM(NSUInteger, DJWSegmentedViewControllerControlPlacement)
{
    DJWSegmentedViewControllerControlPlacementNavigationBar,
    DJWSegmentedViewControllerControlPlacementToolbar
};


@interface DJWSegmentedViewController : UIViewController

@property (nonatomic, weak) id <DJWSegmentedViewControllerDataSource> dataSource;
@property (nonatomic, weak) id <DJWSegmentedViewControllerDelegate> delegate;
@property (nonatomic, assign, readonly) NSUInteger currentViewControllerIndex;

- (instancetype)initWithControlPlacement:(DJWSegmentedViewControllerControlPlacement)placement;

- (void)reload;

@end
