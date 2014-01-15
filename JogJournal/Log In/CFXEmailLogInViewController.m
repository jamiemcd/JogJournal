//
//  CFXEmailLogInViewController.m
//  JogJournal
//
//  Created by Jamie McDaniel on 12/19/13.
//  Copyright (c) 2013 Curious Find. All rights reserved.
//

#import "CFXEmailLogInViewController.h"
#import "UIFont+Custom.h"
#import "UIColor+Custom.h"
#import "CFXButton.h"
#import "CFXEmailResetPasswordController.h"
#import "CFXParseManager.h"
#import "SVProgressHUD.h"

@interface CFXEmailLogInViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *emailTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UILabel *forgotLabel;
@property (nonatomic, strong) UILabel *passwordLabel;
@property (nonatomic, strong) CFXButton *logInButton;

@property (nonatomic, strong) NSArray *viewConstraints;

@end

@implementation CFXEmailLogInViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        self.title = @"Log In";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self createUI];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.emailTextField becomeFirstResponder];
}

- (void)createUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    // emailTextField
    self.emailTextField = [[UITextField alloc] init];
    [self.emailTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.emailTextField.placeholder = @"Email";
    self.emailTextField.delegate = self;
    self.emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.emailTextField.spellCheckingType = UITextSpellCheckingTypeNo;
    [self.view addSubview:self.emailTextField];
    
    // passwordTextField
    self.passwordTextField = [[UITextField alloc] init];
    [self.passwordTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.passwordTextField.placeholder = @"Password";
    self.passwordTextField.delegate = self;
    self.passwordTextField.secureTextEntry = YES;
    self.passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.passwordTextField.spellCheckingType = UITextSpellCheckingTypeNo;
    [self.view addSubview:self.passwordTextField];
    
    // forgotLabel
    UIFont *font = [UIFont lightAppFontOfSize:16];
    UIColor *color = [UIColor blackColor];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentRight;
    NSDictionary *attributes = @{ NSFontAttributeName: font,
                                  NSForegroundColorAttributeName: color,
                                  NSParagraphStyleAttributeName: paragraphStyle};
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:@"Forgot your" attributes:attributes];
    self.forgotLabel = [[UILabel alloc] init];
    [self.forgotLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.forgotLabel.attributedText = attributedString;
    [self.view addSubview:self.forgotLabel];
    
    // passwordLabel
    color = [UIColor emailRed];
    paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    attributes = @{ NSFontAttributeName: font,
                    NSForegroundColorAttributeName: color,
                    NSParagraphStyleAttributeName: paragraphStyle};
    attributedString = [[NSAttributedString alloc] initWithString:@" password" attributes:attributes];
    self.passwordLabel = [[UILabel alloc] init];
    [self.passwordLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.passwordLabel.attributedText = attributedString;
    self.passwordLabel.userInteractionEnabled = YES;
    [self.view addSubview:self.passwordLabel];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(passwordLabelTapGestureRecognizerHandler:)];
    [self.passwordLabel addGestureRecognizer:tapGestureRecognizer];
    
    // LogInButton
    self.logInButton = [[CFXButton alloc] init];
    [self.logInButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.logInButton.color = [UIColor emailRed];
    self.logInButton.image = [UIImage imageNamed:@"email-logo"];
    self.logInButton.title = @"Log In";
    self.logInButton.enabled = NO;
    [self.logInButton addTarget:self action:@selector(logInButtonTouchDownHandler:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.logInButton];
    
    [self.view setNeedsUpdateConstraints];
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    
    if (self.viewConstraints)
    {
        [self.view removeConstraints:self.viewConstraints];
    }
    
    NSDictionary *views = @{ @"topLayoutGuide": self.topLayoutGuide,
                             @"emailTextField": self.emailTextField,
                             @"passwordTextField": self.passwordTextField,
                             @"forgotLabel": self.forgotLabel,
                             @"passwordLabel": self.passwordLabel,
                             @"logInButton": self.logInButton };
    
    NSMutableArray *constraints = [NSMutableArray array];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topLayoutGuide]-20-[emailTextField]-[passwordTextField]-[forgotLabel]-20-[logInButton(==60)]" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[emailTextField]-|" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[passwordTextField]-|" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[logInButton]-|" options:0 metrics:nil views:views]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self.forgotLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self.passwordLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self.passwordLabel attribute:NSLayoutAttributeBaseline relatedBy:NSLayoutRelationEqual toItem:self.forgotLabel attribute:NSLayoutAttributeBaseline multiplier:1.0 constant:0.0]];

    self.viewConstraints = [constraints copy];
    [self.view addConstraints:self.viewConstraints];
}

- (void)logInButtonTouchDownHandler:(CFXButton *)button
{
    [SVProgressHUD showWithStatus:@"Logging In..." maskType:SVProgressHUDMaskTypeBlack];
    __weak CFXEmailLogInViewController *weakSelf = self;
    [[CFXParseManager sharedManager] logInWithEmail:self.emailTextField.text password:self.passwordTextField.text withCallback:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            [SVProgressHUD showSuccessWithStatus:@"Log In Successful"];
        }
        else if (weakSelf)
        {
            [SVProgressHUD dismiss];
            NSString *title = @"Error";
            NSString *message = [error localizedDescription];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        }
    }];
}

- (void)passwordLabelTapGestureRecognizerHandler:(UITapGestureRecognizer *)tapGestureRecognizer
{
    CFXEmailResetPasswordController *emailResetPasswordController = [[CFXEmailResetPasswordController alloc] init];
    [self.navigationController pushViewController:emailResetPasswordController animated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	// the user pressed the "Done" button, so dismiss the keyboard
	[textField resignFirstResponder];
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // Because the textField's text property will not be changed until after this method returns, we need to figure out the text length this way
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    if (textField == self.emailTextField)
    {
        self.logInButton.enabled = newLength > 0 && [self.passwordTextField.text length] > 0;
    }
    else if (textField == self.passwordTextField)
    {
        self.logInButton.enabled = newLength > 0 && [self.emailTextField.text length] > 0;
    }
    
    return YES;
}

@end
