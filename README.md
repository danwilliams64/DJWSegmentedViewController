# DJWSegmentedViewController

A container view controller that manages multiple view controllers, which are swapped between using a segmented control. 

The segmented control can be placed either in the navigation bar, as a navigation controller's titleView property, or alternatively, in the toolbar.

Ideal for use in applications that utilise a tabBarController, and is similar to the approach Apple uses in it's App Store app.

## Demo

![Screenshot](https://raw.githubusercontent.com/danwilliams64/DJWSegmentedViewController/master/Screenshots/DJWSegmentedViewControllerDemo1.gif)

## Usage

Create a new instance of DJWSegmentedViewController, utilising the designated initialiser, ```objective-c - (instancetype)initWithControlPlacement:(DJWSegmentedViewControllerControlPlacement)placement;```, and then set its dataSource, and optionally, its delegate.

### Creation

```objective-c
DJWSegmentedViewController *segmentedViewController = [[DJWSegmentedViewController alloc] initWithControlPlacement:DJWSegmentedViewControllerControlPlacementNavigationBar];
segmentedViewController.dataSource = self;
segmentedViewController.delegate = self;
```

### DataSource

Implement the required dataSource methods:

```objective-c
- (NSInteger)numberOfViewControllers;

- (UIViewController *)DJWSegmentedViewController:(DJWSegmentedViewController *)segmentedViewController viewControllerAtIndex:(NSInteger)index;

- (NSString *)DJWSegmentedViewController:(DJWSegmentedViewController *)segmentedViewController segmentedControlTitleForIndex:(NSInteger)index;
```

### Delegate

Both delegate methods are optional:

```objective-c
- (void)DJWSegmentedViewController:(DJWSegmentedViewController *)segmentedViewController willMoveToViewControllerAtIndex:(NSInteger)newIndex;

- (void)DJWSegmentedViewController:(DJWSegmentedViewController *)segmentedViewController didMoveToViewControllerAtIndex:(NSInteger)newIndex;
```

## Installation

Simply add `DJWSegmentedViewController` to your Podfile if you're using Cocoapods. Alternatively, add `DJWActionSheet.h` and `DJWActionSheet.m` to your project. Included in this repository is a demo application, showing the project in action.
