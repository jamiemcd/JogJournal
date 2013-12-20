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

@interface JJWelcomeViewController ()

@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) JJButton *facebookLogInButton;
@property (nonatomic, strong) JJButton *emailLogInButton;

@property (nonatomic, strong) NSArray *viewConstraints;

@end

@implementation JJWelcomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.toolbarHidden = YES;
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
    
    // facebookLogInButton
    self.facebookLogInButton = [[JJButton alloc] init];
    [self.facebookLogInButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.facebookLogInButton.color = [UIColor facebookBlue];
    self.facebookLogInButton.image = [UIImage imageNamed:@"facebook-logo"];
    self.facebookLogInButton.title = @"Log In With Facebook";
    [self.facebookLogInButton addTarget:self action:@selector(facebookLogInButtonTouchDownHandler:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.facebookLogInButton];
    
    // emailLogInButton
    self.emailLogInButton = [[JJButton alloc] init];
    [self.emailLogInButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.emailLogInButton.color = [UIColor emailRed];
    self.emailLogInButton.image = [UIImage imageNamed:@"email-logo"];
    self.emailLogInButton.title = @"Log In With Email";
    [self.emailLogInButton addTarget:self action:@selector(emailLogInButtonTouchDownHandler:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.emailLogInButton];
    
    
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
                             @"facebookLogInButton": self.facebookLogInButton,
                             @"emailLogInButton": self.emailLogInButton };
    
    NSMutableArray *constraints = [NSMutableArray array];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-60-[logoImageView]-20-[titleLabel]-(>=20@750)-[facebookLogInButton(==60)]-20-[emailLogInButton(==60)]-|" options:0 metrics:nil views:views]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self.logoImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[titleLabel]-|" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[facebookLogInButton]-|" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[emailLogInButton]-|" options:0 metrics:nil views:views]];
    
    self.viewConstraints = [constraints copy];
    [self.view addConstraints:self.viewConstraints];
}

- (void)facebookLogInButtonTouchDownHandler:(JJButton *)button
{
    [[JJParseManager sharedManager] logInToFacebook];
}

- (void)emailLogInButtonTouchDownHandler:(JJButton *)button
{

}

@end
