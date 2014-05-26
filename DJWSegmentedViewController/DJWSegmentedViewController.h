//
//  DJWSegmentedViewController.h
//  DJWSegmentedViewController
//
//  Created by Dan Williams on 17/05/2014.
//  Copyright (c) 2014 Dan Williams. All rights reserved.
//

@import UIKit;
@class DJWSegmentedViewController;

#pragma mark - DataSource and Delegate Protocols

@protocol DJWSegmentedViewControllerDataSource <NSObject>

@required
/**
 *  The number of viewControllers the view is responsible for managing.
 */
- (NSInteger)numberOfViewControllers;

/**
 *  Supply the DJWSegmentedViewController instance with a view Controller for display, at the given index.
 *
 *  @param segmentedViewController The DJWSegmentedViewController.
 *  @param index                   Index of required viewController.
 *
 *  @return The view controller for display.
 */
- (UIViewController *)DJWSegmentedViewController:(DJWSegmentedViewController *)segmentedViewController viewControllerAtIndex:(NSInteger)index;

/**
 *  Supply the DJWSegmentedViewController instance with a title for display in the segmented control.
 *
 *  @param segmentedViewController The DJWSegmentedViewController
 *  @param index                   Index of required title.
 *
 *  @return The title for display on the segmented control.
 */
- (NSString *)DJWSegmentedViewController:(DJWSegmentedViewController *)segmentedViewController segmentedControlTitleForIndex:(NSInteger)index;

@end

@protocol DJWSegmentedViewControllerDelegate <NSObject>

@optional

/**
 *  Notifies the delegate that the DJWSegmentedViewController did move to display the view controller at index specified.
 *
 *  @param segmentedViewController The DJWSegmentedViewController
 *  @param newIndex                Index of the viewController now being shown.
 */
- (void)DJWSegmentedViewController:(DJWSegmentedViewController *)segmentedViewController didMoveToViewControllerAtIndex:(NSInteger)newIndex;

/**
 *  Notifies the delegate that the DJWSegmentedViewController will move to dislay the view controller at the specified index.
 *
 *  @param segmentedViewController The DJWSegmentedViewController
 *  @param newIndex                Index of the viewController about to be shown.
 */
- (void)DJWSegmentedViewController:(DJWSegmentedViewController *)segmentedViewController willMoveToViewControllerAtIndex:(NSInteger)newIndex;

@end

#pragma mark - ENUMs

typedef NS_ENUM(NSUInteger, DJWSegmentedViewControllerControlPlacement)
{
    DJWSegmentedViewControllerControlPlacementNavigationBar,
    DJWSegmentedViewControllerControlPlacementToolbar
};

#pragma mark - Public Interface

@interface DJWSegmentedViewController : UIViewController

@property (nonatomic, weak) id <DJWSegmentedViewControllerDataSource> dataSource;
@property (nonatomic, weak) id <DJWSegmentedViewControllerDelegate> delegate;
/**
 *  Access to the segmentedControl to provide custom styling. Not set until a dataSource is set, and the number of segments is greater than 0. (read-only)
 */
@property (nonatomic, strong, readonly) UISegmentedControl *segmentedControl;
/**
 *  The displayed view controller's index.
 */
@property (nonatomic, assign, readonly) NSInteger currentViewControllerIndex;
/**
 *  Enables a swipe gesture to switch between view controllers. Defaults to `NO`.
 */
@property (nonatomic, assign, getter = isSwipeGestureEnabled) BOOL swipeGestureEnabled;
/**
 *  Enables the viewController transition animation. Defaults to `YES`.
 */
@property (nonatomic, assign) BOOL animatedViewControllerTransitionAnimationEnabled;
/**
 *  The duration that the animation takes to complete. Defaults to `0.6`.
 */
@property (nonatomic, assign) NSTimeInterval animatedViewControllerTransitionDuration;

@property (nonatomic, weak) UIViewController *currentViewController;

#pragma mark - Instance Methods

/**
 *  Instantiates a new instance of DJWSegmentedViewController with the specified segmented control placement. The instance should be displayed within a Navigation Controller.
 *
 *  @param placement See DJWSegmentedViewControllerPlacement ENUM for possible values.
 *
 *  @return Instance of DJWSegmentedViewController
 */
- (instancetype)initWithControlPlacement:(DJWSegmentedViewControllerControlPlacement)placement;
/**
 *  Set the current view controller for display, optionally, this transition can be animated.
 *
 *  @param currentViewControllerIndex Index of new view controler to display.
 *  @param animated                   Animate the transition.
 */
- (void)setCurrentViewControllerIndex:(NSInteger)currentViewControllerIndex animated:(BOOL)animated;
/**
 *  Reloads the view controller, and returns the `currentViewControllerIndex` value to `0`.
 */
- (void)reload;

@end

#pragma mark - Categories

@interface UIViewController (DJWSegmentedViewController)

/**
 *  If this view controller has been shown from a DJWSegmentedViewController, return it. Otherwise, this is set to nil. (read-only)
 */
@property (nonatomic, strong, readonly) DJWSegmentedViewController *segmentedViewController;

@end
