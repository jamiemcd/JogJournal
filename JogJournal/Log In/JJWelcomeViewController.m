//
//  JJWelcomeViewController.m
//  JogJournal
//
//  Created by Jamie McDaniel on 12/18/13.
//  Copyright (c) 2013 Curious Find. All rights reserved.
//

#import "JJWelcomeViewController.h"
#import "JJButton.h"
#import "UIFont+Custom.h"
#import "UIColor+Custom.h"
#import "JJParseManager.h"
#import "JJEmailSignUpViewController.h"
#import "JJEmailLogInViewController.h"

@interface JJWelcomeViewController ()

@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) JJButton *facebookConnectButton;
@property (nonatomic, strong) JJButton *emailSignUpButton;
@property (nonatomic, strong) UIView *emailLogInContainerView;
@property (nonatomic, strong) UILabel *alreadySignedUpLabel;
@property (nonatomic, strong) UILabel *emailLogInLabel;

@property (nonatomic, strong) NSArray *viewConstraints;

@end

@implementation JJWelcomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {

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
    
    // facebookConnectButton
    self.facebookConnectButton = [[JJButton alloc] init];
    [self.facebookConnectButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.facebookConnectButton.color = [UIColor facebookBlue];
    self.facebookConnectButton.image = [UIImage imageNamed:@"facebook-logo"];
    self.facebookConnectButton.title = @"Connect With Facebook";
    [self.facebookConnectButton addTarget:self action:@selector(facebookConnectButtonTouchDownHandler:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.facebookConnectButton];
    
    // emailSignUpButton
    self.emailSignUpButton = [[JJButton alloc] init];
    [self.emailSignUpButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.emailSignUpButton.color = [UIColor emailRed];
    self.emailSignUpButton.image = [UIImage imageNamed:@"email-logo"];
    self.emailSignUpButton.title = @"Sign Up with Email";
    [self.emailSignUpButton addTarget:self action:@selector(emailSignUpButtonTouchDownHandler:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.emailSignUpButton];
    
    // emailLogInContainerView
    self.emailLogInContainerView = [[UIView alloc] init];
    [self.emailLogInContainerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.emailLogInContainerView];
    
    // alreadySignedUpLabel
    font = [UIFont lightAppFontOfSize:16];
    color = [UIColor blackColor];
    attributes = @{ NSFontAttributeName: font,
                    NSForegroundColorAttributeName: color };
    attributedString = [[NSAttributedString alloc] initWithString:@"Already signed up?" attributes:attributes];
    self.alreadySignedUpLabel = [[UILabel alloc] init];
    [self.alreadySignedUpLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.alreadySignedUpLabel.attributedText = attributedString;
    [self.emailLogInContainerView addSubview:self.alreadySignedUpLabel];
    
    // emailLogInLabel
    color = [UIColor emailRed];
    attributes = @{ NSFontAttributeName: font,
                    NSForegroundColorAttributeName: color };
    attributedString = [[NSAttributedString alloc] initWithString:@" Log in now!" attributes:attributes];
    self.emailLogInLabel = [[UILabel alloc] init];
    [self.emailLogInLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.emailLogInLabel.attributedText = attributedString;
    self.emailLogInLabel.userInteractionEnabled = YES;
    [self.emailLogInContainerView addSubview:self.emailLogInLabel];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(emailLogInLabelTapGestureRecognizerHandler:)];
    [self.emailLogInLabel addGestureRecognizer:tapGestureRecognizer];
    
    [self.view setNeedsUpdateConstraints];
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    
    if (self.viewConstraints)
    {
        [self.view removeConstraints:self.viewConstraints];
    }
    
    // We don't have to worry about anyone else adding constraints to our internal emailLogInContainerView, so we can just remove all of its constraints
    [self.emailLogInContainerView removeConstraints:self.emailLogInContainerView.constraints];
    
    NSDictionary *views = @{ @"logoImageView": self.logoImageView,
                             @"titleLabel": self.titleLabel,
                             @"facebookConnectButton": self.facebookConnectButton,
                             @"emailSignUpButton": self.emailSignUpButton,
                             @"emailLogInContainerView": self.emailLogInContainerView,
                             @"alreadySignedUpLabel": self.alreadySignedUpLabel,
                             @"emailLogInLabel": self.emailLogInLabel };
    
    // First, the constraints to be added to self.emailLogInContainerView
    NSMutableArray *constraints = [NSMutableArray array];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[alreadySignedUpLabel][emailLogInLabel]|" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[alreadySignedUpLabel]|" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[emailLogInLabel]|" options:0 metrics:nil views:views]];
    [self.emailLogInContainerView addConstraints:[constraints copy]];
    
    // Now the constraints that will be added to self.view
    constraints = [NSMutableArray array];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self.logoImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:-120.0]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[logoImageView]-15-[titleLabel]" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[facebookConnectButton(==60)]-15-[emailSignUpButton(==60)]-15-[emailLogInContainerView]-|" options:0 metrics:nil views:views]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self.logoImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[titleLabel]-|" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[facebookConnectButton]-|" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[emailSignUpButton]-|" options:0 metrics:nil views:views]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self.emailLogInContainerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    
    self.viewConstraints = [constraints copy];
    [self.view addConstraints:self.viewConstraints];
}

- (void)facebookConnectButtonTouchDownHandler:(JJButton *)button
{
    [[JJParseManager sharedManager] logInToFacebookWithCallback:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else
        {
            NSString *title = @"Error";
            NSString *message = [error localizedDescription];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        }
    }];
}

- (void)emailSignUpButtonTouchDownHandler:(JJButton *)button
{
    // navigate after a short delay so the user can see the button highlight
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.navigationController.navigationBarHidden = NO;
        JJEmailSignUpViewController *emailSignUpViewController = [[JJEmailSignUpViewController alloc] init];
        [self.navigationController pushViewController:emailSignUpViewController animated:YES];
    });
}

- (void)emailLogInLabelTapGestureRecognizerHandler:(UITapGestureRecognizer *)tapGestureRecognizer
{
    self.navigationController.navigationBarHidden = NO;
    JJEmailLogInViewController *emailLogInViewController = [[JJEmailLogInViewController alloc] init];
    [self.navigationController pushViewController:emailLogInViewController animated:YES];
}

@end
