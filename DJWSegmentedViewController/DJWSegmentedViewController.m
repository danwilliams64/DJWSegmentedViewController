//
//  DJWSegmentedViewController.m
//  DJWSegmentedViewController
//
//  Created by Dan Williams on 17/05/2014.
//  Copyright (c) 2014 Dan Williams. All rights reserved.
//

#import "DJWSegmentedViewController.h"

@interface DJWSegmentedViewController ()
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, assign) DJWSegmentedViewControllerControlPlacement placement;
@property (nonatomic, assign, readwrite) NSUInteger currentViewControllerIndex;
@end

@implementation DJWSegmentedViewController

- (instancetype)initWithControlPlacement:(DJWSegmentedViewControllerControlPlacement)placement
{
    if (self = [super init]) {
        self.placement = placement;
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
    [self removeCurrentViewControllerView];
    
    UIViewController *viewController = [self.dataSource DJWSegmentedViewController:self viewControllerAtIndex:index];
    if (!viewController) {
        [[NSException exceptionWithName:@"View Controller is nil" reason:@"The view controller returned from DJWSegmentedViewController:viewControllerAtIndex is nil." userInfo:nil] raise];
        return;
    }
    
    [self addChildViewController:viewController];
    [self.view addSubview:viewController.view];
    [self didMoveToParentViewController:self];
    
    [self.delegate DJWSegmentedViewController:self didMoveToViewControllerAtIndex:index];
}

- (void)removeCurrentViewControllerView
{
    if (self.view.subviews.count == 0) {
        return;
    }
    
    UIViewController *currentViewController = [self.dataSource DJWSegmentedViewController:self viewControllerAtIndex:self.currentViewControllerIndex];
    [currentViewController removeFromParentViewController];
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self didMoveToParentViewController:self];
}

#pragma mark - Target Action

- (void)segmentedControlValueChanged:(UISegmentedControl *)sender
{
    NSInteger index = sender.selectedSegmentIndex;
    [self addViewControllerViewAsViewAtIndex:index];
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
    [self addViewControllerViewAsViewAtIndex:_currentViewControllerIndex];
}

- (void)setDataSource:(id<DJWSegmentedViewControllerDataSource>)dataSource
{
    _dataSource = dataSource;
    [self reload];
    self.currentViewControllerIndex = 0;
}

@end
