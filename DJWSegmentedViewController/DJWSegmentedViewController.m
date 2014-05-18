//
//  DJWSegmentedViewController.m
//  DJWSegmentedViewController
//
//  Created by Dan Williams on 17/05/2014.
//  Copyright (c) 2014 Dan Williams. All rights reserved.
//

#import "DJWSegmentedViewController.h"

typedef NS_ENUM(NSUInteger, DJWSegmentedViewControllerTransitionDirection) {
    DJWSegmentedViewControllerTransitionDirectionLeft,
    DJWSegmentedViewControllerTransitionDirectionRight
};

@interface DJWSegmentedViewController ()
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, assign) DJWSegmentedViewControllerControlPlacement placement;
@property (nonatomic, assign, readwrite) NSUInteger currentViewControllerIndex;
@property (nonatomic, assign) NSUInteger previousViewControllerIndex;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeGestureRecogniserLeft;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeGestureRecogniserRight;
@end

@implementation DJWSegmentedViewController

- (instancetype)initWithControlPlacement:(DJWSegmentedViewControllerControlPlacement)placement
{
    if (self = [super init]) {
        self.placement = placement;
        _swipeGestureEnabled = YES;
        _animatedViewControllerTransitionAnimationEnabled = YES;
        _swipeGestureRecogniserLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
        _swipeGestureRecogniserLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        _swipeGestureRecogniserRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
        _swipeGestureRecogniserRight.direction = UISwipeGestureRecognizerDirectionRight;
    }
    return self;
}

#pragma mark - Public

- (void)reload
{
    [self.segmentedControl removeAllSegments];

    NSUInteger numberOfViewControllers = [self.dataSource numberOfViewControllers];
    for (NSUInteger i = 0; i < numberOfViewControllers; i++) {
        NSString *title = [self.dataSource DJWSegmentedViewController:self segmentedControlTitleForIndex:i];
        [self.segmentedControl insertSegmentWithTitle:title atIndex:i animated:NO];
    }
    
    [self.segmentedControl sizeToFit];
    [self.segmentedControl setSelectedSegmentIndex:0];
    
    switch (self.placement) {
        case DJWSegmentedViewControllerControlPlacementNavigationBar:
        {
            self.navigationItem.titleView = self.segmentedControl;
            break;
        }
        case DJWSegmentedViewControllerControlPlacementToolbar:
        {
            [self.navigationController setToolbarHidden:NO];
            UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            self.toolbarItems = @[flexibleSpace,
                                  [[UIBarButtonItem alloc] initWithCustomView:self.segmentedControl],
                                  flexibleSpace];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Private




- (void)addViewControllerViewAsViewAtIndex:(NSInteger)index
{
    UIView *previousSnapShot = [self.view.subviews.firstObject snapshotViewAfterScreenUpdates:NO];
    [self removePreviousViewController];
    [self.view addSubview:previousSnapShot];
    
    DJWSegmentedViewControllerTransitionDirection direction = (self.previousViewControllerIndex < index) ?  DJWSegmentedViewControllerTransitionDirectionLeft : DJWSegmentedViewControllerTransitionDirectionRight;

    UIViewController *viewController = [self.dataSource DJWSegmentedViewController:self viewControllerAtIndex:index];
    if (!viewController) {
        [[NSException exceptionWithName:@"View Controller is nil" reason:@"The view controller returned from DJWSegmentedViewController:viewControllerAtIndex is nil." userInfo:nil] raise];
        return;
    }
    
    [self addChildViewController:viewController];
    UIView *viewControllerView = viewController.view;
    CGRect startFrame = CGRectOffset(viewControllerView.frame, (direction == DJWSegmentedViewControllerTransitionDirectionLeft) ? CGRectGetWidth(viewControllerView.frame) : -CGRectGetWidth(viewControllerView.frame), 0);
    viewControllerView.frame = startFrame;
    [self.view addSubview:viewControllerView];
    [self didMoveToParentViewController:self];
    
    if (!previousSnapShot || !self.animatedViewControllerTransitionAnimationEnabled) {
        [UIView setAnimationsEnabled:NO];
        previousSnapShot = [UIView new];
    }
    
    [self animateViewsControllersForInitialDisplay:@[previousSnapShot, viewControllerView] inDirection:direction withXOffset:CGRectGetWidth(viewControllerView.frame) withCompletionCallback:^{
        [previousSnapShot removeFromSuperview];
        [self.delegate DJWSegmentedViewController:self didMoveToViewControllerAtIndex:index];
    }];
    
    [UIView setAnimationsEnabled:YES];
}

- (void)animateViewsControllersForInitialDisplay:(NSArray *)views inDirection:(DJWSegmentedViewControllerTransitionDirection)direction withXOffset:(CGFloat)xOffset withCompletionCallback:(void(^)())callback;
{
    [views enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            CGFloat originX = (direction == DJWSegmentedViewControllerTransitionDirectionLeft) ? view.frame.origin.x - xOffset : view.frame.origin.x + xOffset;
            view.frame = CGRectMake(originX, view.frame.origin.y, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame));
        } completion:^(BOOL finished) {
            if (callback) {
                callback();
            }
        }];
    }];
}

- (void)removePreviousViewController
{
    if (self.view.subviews.count == 0) {
        return;
    }
    
    UIViewController *currentViewController = [self.dataSource DJWSegmentedViewController:self viewControllerAtIndex:self.currentViewControllerIndex];
    [currentViewController removeFromParentViewController];
    [self didMoveToParentViewController:self];
}

#pragma mark - Target Action

- (void)handleSwipeGesture:(UISwipeGestureRecognizer *)sender
{
    switch (sender.direction) {
        case UISwipeGestureRecognizerDirectionLeft:
        {
            if (self.currentViewControllerIndex + 1 != self.segmentedControl.numberOfSegments - 1) {
                self.currentViewControllerIndex++;
            }
        }
        case UISwipeGestureRecognizerDirectionRight:
        {
            if (self.currentViewControllerIndex - 1 != 0) {
                self.currentViewControllerIndex--;
            }
        }
            
        default:
            break;
    }
}

- (void)segmentedControlValueChanged:(UISegmentedControl *)sender
{
    NSInteger index = sender.selectedSegmentIndex;
    self.previousViewControllerIndex = _currentViewControllerIndex;
    self.currentViewControllerIndex = index;
}

#pragma mark - Getters

- (UISegmentedControl *)segmentedControl
{
    if (!_segmentedControl) {
        _segmentedControl = [[UISegmentedControl alloc] initWithFrame:CGRectZero];
        [_segmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _segmentedControl;
}

#pragma mark - Setters

- (void)setCurrentViewControllerIndex:(NSUInteger)currentViewControllerIndex
{
    _currentViewControllerIndex = currentViewControllerIndex;
    [self.segmentedControl setSelectedSegmentIndex:_currentViewControllerIndex];
    [self addViewControllerViewAsViewAtIndex:_currentViewControllerIndex];
}

- (void)setDataSource:(id<DJWSegmentedViewControllerDataSource>)dataSource
{
    _dataSource = dataSource;
    [self reload];
    self.currentViewControllerIndex = 0;
}

@end
