//
//  CFXMainViewController.m
//  JogJournal
//
//  Created by Jamie McDaniel on 12/17/13.
//  Copyright (c) 2013 Curious Find. All rights reserved.
//

#import "CFXMainViewController.h"
#import "CFXWelcomeViewController.h"
#import "CFXJogViewController.h"
#import "CFXCompletedJogsViewController.h"
#import "CFXStatisticsViewController.h"
#import "CFXParseManager.h"
#import "CFXCoreDataManager.h"
#import "CFXButton.h"
#import "UIFont+Custom.h"
#import "UIColor+Custom.h"

@interface CFXMainViewController ()

@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) CFXButton *startNewJogButton;
@property (nonatomic, strong) CFXButton *completedJogsButton;
@property (nonatomic, strong) CFXButton *statisticsButton;
@property (nonatomic, strong) CFXButton *logOutButton;

@property (nonatomic, strong) CFXWelcomeViewController *welcomeViewController;

@property (nonatomic, strong) NSArray *viewConstraints;

@end

@implementation CFXMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self createUI];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    [self updateUI];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([CFXCoreDataManager sharedManager].currentUser)
    {
        
    }
    else
    {
        [self presentWelcomeViewController:NO];
    }
}

- (void)createUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    // logoImageView
    self.logoImageView = [[UIImageView alloc] init];
    [self.logoImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.logoImageView.image = [UIImage imageNamed:@"logo-small"];
    [self.view addSubview:self.logoImageView];
    
    // startNewJogButton
    self.startNewJogButton = [[CFXButton alloc] init];
    [self.startNewJogButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.startNewJogButton.color = [UIColor jogJournalGreen];
    self.startNewJogButton.image = [UIImage imageNamed:@"timer-logo"];
    self.startNewJogButton.title = @"Start a New Jog";
    [self.startNewJogButton addTarget:self action:@selector(startNewJogButtonTouchDownHandler:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.startNewJogButton];

    // completedJogsButton
    self.completedJogsButton = [[CFXButton alloc] init];
    [self.completedJogsButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.completedJogsButton.color = [UIColor jogJournalGreen];
    self.completedJogsButton.image = [UIImage imageNamed:@"journal-logo"];
    self.completedJogsButton.title = @"View My Completed Jogs";
    [self.completedJogsButton addTarget:self action:@selector(completedJogsButtonTouchDownHandler:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.completedJogsButton];
    
    // statisticsButton
    self.statisticsButton = [[CFXButton alloc] init];
    [self.statisticsButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.statisticsButton.color = [UIColor jogJournalGreen];
    self.statisticsButton.image = [UIImage imageNamed:@"statistics-logo"];
    self.statisticsButton.title = @"View My Statistics";
    [self.statisticsButton addTarget:self action:@selector(statisticsButtonTouchDownHandler:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.statisticsButton];
    
    // logOutButton
    self.logOutButton = [[CFXButton alloc] init];
    [self.logOutButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.logOutButton.color = [UIColor jogJournalGreen];
    self.logOutButton.image = [UIImage imageNamed:@"logout-logo"];
    self.logOutButton.title = @"Log Out";
    [self.logOutButton addTarget:self action:@selector(logOutButtonTouchDownHandler:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.logOutButton];
    
    [self.view setNeedsUpdateConstraints];
}

- (void)updateUI
{
    self.startNewJogButton.title = [CFXCoreDataManager sharedManager].activeJog ? @"Active Jog in Progress" : @"Start a New Jog";
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    
    if (self.viewConstraints)
    {
        [self.view removeConstraints:self.viewConstraints];
    }
    
    NSDictionary *views = @{ @"logoImageView": self.logoImageView,
                             @"startNewJogButton": self.startNewJogButton,
                             @"completedJogsButton": self.completedJogsButton,
                             @"statisticsButton": self.statisticsButton,
                             @"logOutButton": self.logOutButton };
    
    NSMutableArray *constraints = [NSMutableArray array];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self.logoImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:-150.0]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[logoImageView]" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[startNewJogButton(==60)]-15-[completedJogsButton(==60)]-15-[statisticsButton(==60)]-15-[logOutButton(==60)]-20-|" options:0 metrics:nil views:views]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self.logoImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[startNewJogButton]-|" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[completedJogsButton]-|" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[statisticsButton]-|" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[logOutButton]-|" options:0 metrics:nil views:views]];
    
    self.viewConstraints = [constraints copy];
    [self.view addConstraints:self.viewConstraints];
}

- (void)presentWelcomeViewController:(BOOL)animated
{
    self.welcomeViewController = [[CFXWelcomeViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.welcomeViewController];
    [self presentViewController:navigationController animated:animated completion:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(parseManagerUserLogInCompleteNotificationHandler:) name:CFXParseManagerUserLogInCompleteNotification object:nil];
}

- (void)startNewJogButtonTouchDownHandler:(CFXButton *)button
{
    self.navigationController.navigationBarHidden = NO;
    CFXJogViewController *jogViewController = [[CFXJogViewController alloc] init];
    [self.navigationController pushViewController:jogViewController animated:YES];
}

- (void)completedJogsButtonTouchDownHandler:(CFXButton *)button
{
    self.navigationController.navigationBarHidden = NO;
    CFXCompletedJogsViewController *completedJogsViewController = [[CFXCompletedJogsViewController alloc] init];
    completedJogsViewController.user = [CFXCoreDataManager sharedManager].currentUser;
    [self.navigationController pushViewController:completedJogsViewController animated:YES];
}

- (void)statisticsButtonTouchDownHandler:(CFXButton *)button
{
    self.navigationController.navigationBarHidden = NO;
    CFXStatisticsViewController *statisticsViewController = [[CFXStatisticsViewController alloc] init];
    [self.navigationController pushViewController:statisticsViewController animated:YES];
}

- (void)logOutButtonTouchDownHandler:(CFXButton *)button
{
    [[CFXParseManager sharedManager] logOut];
    [self presentWelcomeViewController:YES];
}

- (void)parseManagerUserLogInCompleteNotificationHandler:(NSNotification *)notification
{
    if (self.welcomeViewController)
    {
        // We want a 1.25 second delay before dismissing the welcomeViewController so the user can see the login status change to "Login Successful"
        double delayInSeconds = 1.25;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
