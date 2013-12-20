//
//  JJMainViewController.m
//  JogJournal
//
//  Created by Jamie McDaniel on 12/17/13.
//  Copyright (c) 2013 Curious Find. All rights reserved.
//

#import "JJMainViewController.h"
#import "JJWelcomeViewController.h"
#import "JJParseManager.h"
#import "JJButton.h"
#import "UIFont+Custom.h"
#import "UIColor+Custom.h"

@interface JJMainViewController ()

@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) JJButton *startNewJogButton;
@property (nonatomic, strong) JJButton *logOutButton;

@property (nonatomic, strong) JJWelcomeViewController *welcomeViewController;

@property (nonatomic, strong) NSArray *viewConstraints;

@end

@implementation JJMainViewController

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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([[JJParseManager sharedManager] isUserLoggedIn])
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
    
    // titleLabel
    UIFont *font = [UIFont lightAppFontOfSize:36];
    UIColor *color = [UIColor blackColor];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{ NSFontAttributeName: font,
                                  NSForegroundColorAttributeName: color,
                                  NSParagraphStyleAttributeName: paragraphStyle };
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:@"Jog Journal" attributes:attributes];
    
    self.titleLabel = [[UILabel alloc] init];
    [self.titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.attributedText = attributedString;
    [self.view addSubview:self.titleLabel];
    
    // startNewJogButton
    self.startNewJogButton = [[JJButton alloc] init];
    [self.startNewJogButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.startNewJogButton.color = [UIColor jogJournalGreen];
    self.startNewJogButton.image = [UIImage imageNamed:@"timer-logo"];
    self.startNewJogButton.title = @"Start a New Jog";
    [self.startNewJogButton addTarget:self action:@selector(startNewJogButtonTouchDownHandler:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.startNewJogButton];
    
    // logOutButton
    self.logOutButton = [[JJButton alloc] init];
    [self.logOutButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.logOutButton.color = [UIColor jogJournalGreen];
    self.logOutButton.image = [UIImage imageNamed:@"logout-logo"];
    self.logOutButton.title = @"Log Out";
    [self.logOutButton addTarget:self action:@selector(logOutButtonTouchDownHandler:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.logOutButton];
    
    [self.view setNeedsUpdateConstraints];
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    
    if (self.viewConstraints)
    {
        [self.view removeConstraints:self.viewConstraints];
    }
    
    NSDictionary *views = @{ @"logoImageView": self.logoImageView,
                             @"titleLabel": self.titleLabel,
                             @"startNewJogButton": self.startNewJogButton,
                             @"logOutButton": self.logOutButton };
    
    NSMutableArray *constraints = [NSMutableArray array];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-60-[logoImageView]-20-[titleLabel]-(>=20@750)-[startNewJogButton(==60)]-20-[logOutButton(==60)]-20-|" options:0 metrics:nil views:views]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self.logoImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[titleLabel]-|" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[startNewJogButton]-|" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[logOutButton]-|" options:0 metrics:nil views:views]];
    
    self.viewConstraints = [constraints copy];
    [self.view addConstraints:self.viewConstraints];
}

- (void)presentWelcomeViewController:(BOOL)animated
{
    self.welcomeViewController = [[JJWelcomeViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.welcomeViewController];
    [self presentViewController:navigationController animated:animated completion:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(parseManagerUserLogInCompleteNotificationHandler:) name:JJParseManagerUserLogInCompleteNotification object:nil];
}

- (void)startNewJogButtonTouchDownHandler:(JJButton *)button
{
    NSLog(@"New Jog");
}

- (void)logOutButtonTouchDownHandler:(JJButton *)button
{
    [[JJParseManager sharedManager] logOut];
    [self presentWelcomeViewController:YES];
}

- (void)parseManagerUserLogInCompleteNotificationHandler:(NSNotification *)notification
{
    if (self.welcomeViewController)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
