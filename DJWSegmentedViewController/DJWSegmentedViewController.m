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
@property (nonatomic, strong, readwrite) UIPageControl *pageControl;
@property (nonatomic, strong, readwrite) UIBarButtonItem *backBarButtonItem;
@property (nonatomic, strong, readwrite) UIBarButtonItem *forwardBarButtonItem;
@property (nonatomic, assign) DJWSegmentedViewControllerControlPlacement placement;
@property (nonatomic, assign) DJWSegmentedViewControllerControlType type;
@property (nonatomic, assign, readwrite) NSInteger currentViewControllerIndex;
@property (nonatomic, assign) NSInteger previousViewControllerIndex;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeGestureRecognizerLeft;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeGestureRecognizerRight;
@end

@implementation DJWSegmentedViewController

- (instancetype)initWithControlPlacement:(DJWSegmentedViewControllerControlPlacement)placement
{
    return [self initWithControlPlacement:placement controlType:DJWSegmentedViewControllerControlTypeSegmentedControl];
}

- (instancetype)initWithControlPlacement:(DJWSegmentedViewControllerControlPlacement)placement controlType:(DJWSegmentedViewControllerControlType)controlType
{
    if (self = [super init]) {
        _placement = placement;
        _type = controlType;
        _animatedViewControllerTransitionAnimationEnabled = YES;
        _swipeGestureEnabled = NO;
        self.view.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (BOOL)shouldAutomaticallyForwardRotationMethods
{
    return YES;
}

#pragma mark - Public

- (void)setCurrentViewControllerIndex:(NSInteger)currentViewControllerIndex animated:(BOOL)animated
{
    if (_currentViewControllerIndex == currentViewControllerIndex) return;
    if (currentViewControllerIndex >= 0 && currentViewControllerIndex < [self.dataSource numberOfViewControllers]) {
        if (!animated) {
            [UIView setAnimationsEnabled:NO];
        }
        [self.segmentedControl setSelectedSegmentIndex:currentViewControllerIndex];
        [self.segmentedControl sendActionsForControlEvents:UIControlEventValueChanged];
        [UIView setAnimationsEnabled:YES];
    }
}

- (void)reload
{
    [self.segmentedControl removeAllSegments];

    NSInteger numberOfViewControllers = [self.dataSource numberOfViewControllers];
    for (NSInteger i = 0; i < numberOfViewControllers; i++) {
        NSString *title = [self.dataSource DJWSegmentedViewController:self segmentedControlTitleForIndex:i];
        [self.segmentedControl insertSegmentWithTitle:title atIndex:i animated:NO];
        [self.segmentedControl sizeToFit];
        [self.segmentedControl setSelectedSegmentIndex:0];
        self.pageControl.numberOfPages++;
        [self.pageControl sizeToFit];
    }
    

    switch (self.placement) {
        case DJWSegmentedViewControllerControlPlacementNavigationBar:
        {
            self.navigationItem.titleView = (self.type == DJWSegmentedViewControllerControlTypeSegmentedControl) ? self.segmentedControl : self.pageControl;
            break;
        }
        case DJWSegmentedViewControllerControlPlacementToolbar:
        {
            if (_type == DJWSegmentedViewControllerControlTypePageControl) {
                self.backBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(handleSwipeGestureRight:)];
                self.forwardBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(handleSwipeGestureLeft:)];
            } else {
                self.backBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
                self.forwardBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

            }
            self.toolbarItems = @[self.backBarButtonItem,
                                  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                  [[UIBarButtonItem alloc] initWithCustomView:(self.type == DJWSegmentedViewControllerControlTypeSegmentedControl) ? self.segmentedControl : self.pageControl],
                                  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                  self.forwardBarButtonItem];
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
    if ([self.delegate respondsToSelector:@selector(DJWSegmentedViewController:willMoveToViewControllerAtIndex:)]) {
        [self.delegate DJWSegmentedViewController:self willMoveToViewControllerAtIndex:index];
    }
    
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
    if (previousSnapShot) viewControllerView.frame = CGRectMake(0, 0, CGRectGetWidth(previousSnapShot.frame), CGRectGetHeight(previousSnapShot.frame));
    CGRect startFrame = CGRectOffset(viewControllerView.frame, (direction == DJWSegmentedViewControllerTransitionDirectionLeft) ? CGRectGetWidth(viewControllerView.bounds) : -CGRectGetWidth(viewControllerView.bounds), 0);
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
        if ([self.delegate respondsToSelector:@selector(DJWSegmentedViewController:didMoveToViewControllerAtIndex:)]) {
            [self.delegate DJWSegmentedViewController:self didMoveToViewControllerAtIndex:index];
        }
    }];
    
    [UIView setAnimationsEnabled:YES];
}

- (void)animateViewsControllersForInitialDisplay:(NSArray *)views inDirection:(DJWSegmentedViewControllerTransitionDirection)direction withXOffset:(CGFloat)xOffset withCompletionCallback:(void(^)())callback;
{
    [views enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        [UIView animateWithDuration:self.animatedViewControllerTransitionDuration delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            CGFloat originX = (direction == DJWSegmentedViewControllerTransitionDirectionLeft) ? view.frame.origin.x - xOffset : view.frame.origin.x + xOffset;
            view.frame = CGRectMake(originX, view.frame.origin.y, CGRectGetWidth(view.bounds), CGRectGetHeight(view.bounds));
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

- (UIPageControl *)pageControl
{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectZero];
    }
    return _pageControl;
}

- (NSTimeInterval)animatedViewControllerTransitionDuration
{
    if (!_animatedViewControllerTransitionDuration) {
        _animatedViewControllerTransitionDuration = 0.6;
    }
    return _animatedViewControllerTransitionDuration;
}

- (UIViewController *)currentViewController
{
    return [self.dataSource DJWSegmentedViewController:self viewControllerAtIndex:self.currentViewControllerIndex];
}

#pragma mark - Setters

- (void)setCurrentViewControllerIndex:(NSInteger)currentViewControllerIndex
{
    _currentViewControllerIndex = currentViewControllerIndex;
    [self.segmentedControl setSelectedSegmentIndex:_currentViewControllerIndex];
    self.pageControl.currentPage = _currentViewControllerIndex;
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

#pragma mark - Categories

@implementation UIViewController (DJWSegmentedViewController)

- (DJWSegmentedViewController *)segmentedViewController
{
    return ([self.parentViewController isKindOfClass:[DJWSegmentedViewController class]]) ? (DJWSegmentedViewController *)self.parentViewController : nil;
}

@end
