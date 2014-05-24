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
@property (nonatomic, strong, readwrite) UISegmentedControl *segmentedControl;
@property (nonatomic, assign) DJWSegmentedViewControllerControlPlacement placement;
@property (nonatomic, assign, readwrite) NSInteger currentViewControllerIndex;
@property (nonatomic, assign) NSInteger previousViewControllerIndex;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeGestureRecognizerLeft;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeGestureRecognizerRight;
@end

@implementation DJWSegmentedViewController

- (instancetype)initWithControlPlacement:(DJWSegmentedViewControllerControlPlacement)placement
{
    if (self = [super init]) {
        _placement = placement;
        _animatedViewControllerTransitionAnimationEnabled = YES;
        _swipeGestureEnabled = NO;
        self.view.backgroundColor = [UIColor blackColor];
    }
    return self;
}

#pragma mark - Public

- (void)setCurrentViewControllerIndex:(NSInteger)currentViewControllerIndex animated:(BOOL)animated
{
    if (_currentViewControllerIndex == currentViewControllerIndex) return;
    if (currentViewControllerIndex >= 0 && currentViewControllerIndex < [self.dataSource numberOfViewControllers]) {
        [self setCurrentViewControllerIndex:currentViewControllerIndex];
    }
}

- (void)reload
{
    [self.segmentedControl removeAllSegments];

    NSInteger numberOfViewControllers = [self.dataSource numberOfViewControllers];
    for (NSInteger i = 0; i < numberOfViewControllers; i++) {
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

#pragma mark - View Controller Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.placement == DJWSegmentedViewControllerControlPlacementToolbar) {
        [self.navigationController setToolbarHidden:NO];
    }
}

#pragma mark - Private

- (void)addViewControllerViewAsViewAtIndex:(NSInteger)index
{
    UIView *previousSnapShot = [[self.view.subviews firstObject] snapshotViewAfterScreenUpdates:NO];
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
    [self addSwipeGestureRecognizersToView:viewControllerView];

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
        [UIView animateWithDuration:self.animatedViewControllerTransitionDuration delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            CGFloat originX = (direction == DJWSegmentedViewControllerTransitionDirectionLeft) ? view.frame.origin.x - xOffset : view.frame.origin.x + xOffset;
            view.frame = CGRectMake(originX, view.frame.origin.y, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame));
        } completion:^(BOOL finished) {
            if (callback) {
                callback();
            }
        }];
    }];
}

- (void)addSwipeGestureRecognizersToView:(UIView *)view
{
    if (self.isSwipeGestureEnabled) {
        [view addGestureRecognizer:_swipeGestureRecognizerLeft];
        [view addGestureRecognizer:_swipeGestureRecognizerRight];
    }
}

- (void)removePreviousViewController
{
    if (self.view.subviews.count == 0) {
        return;
    }
    
    UIViewController *currentViewController = [self.dataSource DJWSegmentedViewController:self viewControllerAtIndex:self.currentViewControllerIndex];
    [currentViewController removeFromParentViewController];
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self didMoveToParentViewController:self];
}

- (void)bounceViewControllerViewInDirection:(DJWSegmentedViewControllerTransitionDirection)direction
{
    UIView *view = [self.view.subviews firstObject];
    CGFloat offset = (direction == DJWSegmentedViewControllerTransitionDirectionLeft) ? -25.0 : 25.0;
    
    [UIView animateWithDuration:0.10 delay:0 options:kNilOptions animations:^{
        view.frame = CGRectOffset(view.frame, -offset, 0);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.4 options:kNilOptions animations:^{
            view.frame = CGRectOffset(view.frame, offset, 0);
        } completion:nil];
    }];
}

#pragma mark - Target Action

- (void)handleSwipeGestureRight:(UISwipeGestureRecognizer *)sender
{
    if (_currentViewControllerIndex - 1 != -1) {
        [self.segmentedControl setSelectedSegmentIndex:_currentViewControllerIndex - 1];
        [self.segmentedControl sendActionsForControlEvents:UIControlEventValueChanged];
    } else {
        [self bounceViewControllerViewInDirection:DJWSegmentedViewControllerTransitionDirectionLeft];
    }
}

- (void)handleSwipeGestureLeft:(UISwipeGestureRecognizer *)sender
{
    if (_currentViewControllerIndex + 1 != self.segmentedControl.numberOfSegments) {
        [self.segmentedControl setSelectedSegmentIndex:_currentViewControllerIndex + 1];
        [self.segmentedControl sendActionsForControlEvents:UIControlEventValueChanged];
    } else {
        [self bounceViewControllerViewInDirection:DJWSegmentedViewControllerTransitionDirectionRight];
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

- (NSTimeInterval)animatedViewControllerTransitionDuration
{
    if (!_animatedViewControllerTransitionDuration) {
        _animatedViewControllerTransitionDuration = 0.6;
    }
    return _animatedViewControllerTransitionDuration;
}

#pragma mark - Setters

- (void)setCurrentViewControllerIndex:(NSInteger)currentViewControllerIndex
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

- (void)setSwipeGestureEnabled:(BOOL)swipeGestureEnabled
{
    _swipeGestureEnabled = swipeGestureEnabled;
    
    if (_swipeGestureEnabled) {
        _swipeGestureRecognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGestureLeft:)];
        _swipeGestureRecognizerLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        _swipeGestureRecognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGestureRight:)];
        _swipeGestureRecognizerRight.direction = UISwipeGestureRecognizerDirectionRight;
    } else {
        _swipeGestureRecognizerRight = nil;
        _swipeGestureRecognizerLeft = nil;
    }
}

@end

@implementation UIViewController (DJWSegmentedViewController)

- (DJWSegmentedViewController *)segmentedViewController
{
    return ([self.parentViewController isKindOfClass:[DJWSegmentedViewController class]]) ? (DJWSegmentedViewController *)self.parentViewController : nil;
}

@end
