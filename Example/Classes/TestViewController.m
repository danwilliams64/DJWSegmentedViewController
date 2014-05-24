//
//  TestViewController.m
//  DJWSegmentedViewController
//
//  Created by Dan Williams on 17/05/2014.
//  Copyright (c) 2014 Dan Williams. All rights reserved.
//

#import "TestViewController.h"
#import "DJWSegmentedViewController.h"

@interface TestViewController ()

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *jumpToVCButton;

@end

@implementation TestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _label = [UILabel new];
    _label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:_label];
    
    _jumpToVCButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:_jumpToVCButton];
    [_jumpToVCButton setTitle:@"Move to Two." forState:UIControlStateNormal];
    [_jumpToVCButton sizeToFit];
    _jumpToVCButton.center = CGPointMake(self.view.center.x, self.view.center.y + 50);
    _jumpToVCButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [_jumpToVCButton addTarget:self action:@selector(jumpToThirdViewController:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)dealloc
{
    NSLog(@"TestViewController deallocated");
}

#pragma mark - Target/Action

- (void)jumpToThirdViewController:(UIButton *)sender
{
    [self.segmentedViewController setCurrentViewControllerIndex:1 animated:YES];
}

#pragma mark - Setters

- (void)setString:(NSString *)string
{
    _string = string;
    self.label.text = _string;
    [self.label sizeToFit];
    self.label.center = self.view.center;
}

@end
