//
//  JJStatisticsViewController.m
//  JogJournal
//
//  Created by Jamie McDaniel on 12/20/13.
//  Copyright (c) 2013 Curious Find. All rights reserved.
//

#import "JJStatisticsViewController.h"

@interface JJStatisticsViewController ()

@property (nonatomic, strong) NSArray *viewConstraints;

@end

@implementation JJStatisticsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = @"My Statistics";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self createUI];
}

- (void)createUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    [self.view setNeedsUpdateConstraints];
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    
    if (self.viewConstraints)
    {
        [self.view removeConstraints:self.viewConstraints];
    }
    
    /*
    NSDictionary *views = @{ @"mapView": self.mapView };
    
    NSMutableArray *constraints = [NSMutableArray array];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mapView]|" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mapView]|" options:0 metrics:nil views:views]];
    
    self.viewConstraints = [constraints copy];
    [self.view addConstraints:self.viewConstraints];
     */
    
}


@end
