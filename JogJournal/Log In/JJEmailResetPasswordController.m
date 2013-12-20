//
//  JJEmailResetPasswordController.m
//  JogJournal
//
//  Created by Jamie McDaniel on 12/19/13.
//  Copyright (c) 2013 Curious Find. All rights reserved.
//

#import "JJEmailResetPasswordController.h"
#import "UIFont+Custom.h"
#import "UIColor+Custom.h"
#import "JJButton.h"
#import "JJParseManager.h"
#import "SVProgressHUD.h"

@interface JJEmailResetPasswordController () <UITextFieldDelegate>

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UITextField *emailTextField;
@property (nonatomic, strong) JJButton *resetPasswordButton;

@property (nonatomic, strong) NSArray *viewConstraints;

@end

@implementation JJEmailResetPasswordController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = @"Reset Password";
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
    
    [self.emailTextField becomeFirstResponder];
}

- (void)createUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    // label
    UIFont *font = [UIFont lightAppFontOfSize:16];
    UIColor *color = [UIColor blackColor];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *attributes = @{ NSFontAttributeName: font,
                                  NSForegroundColorAttributeName: color,
                                  NSParagraphStyleAttributeName: paragraphStyle};
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:@"Enter your email address and we will send you a password reset link" attributes:attributes];
    self.label = [[UILabel alloc] init];
    [self.label setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.label.numberOfLines = 0;
    self.label.attributedText = attributedString;
    [self.view addSubview:self.label];
    
    // emailTextField
    self.emailTextField = [[UITextField alloc] init];
    [self.emailTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.emailTextField.placeholder = @"Email";
    self.emailTextField.delegate = self;
    self.emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.emailTextField.spellCheckingType = UITextSpellCheckingTypeNo;
    [self.view addSubview:self.emailTextField];
    
    // ResetPasswordButton
    self.resetPasswordButton = [[JJButton alloc] init];
    [self.resetPasswordButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.resetPasswordButton.color = [UIColor emailRed];
    self.resetPasswordButton.image = [UIImage imageNamed:@"email-logo"];
    self.resetPasswordButton.title = @"Reset Password";
    self.resetPasswordButton.enabled = NO;
    [self.resetPasswordButton addTarget:self action:@selector(resetPasswordButtonTouchDownHandler:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.resetPasswordButton];
    
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
                             @"label": self.label,
                             @"emailTextField": self.emailTextField,
                             @"resetPasswordButton": self.resetPasswordButton };
    
    NSMutableArray *constraints = [NSMutableArray array];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topLayoutGuide]-20-[label]-[emailTextField]-20-[resetPasswordButton(==60)]" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[label]-|" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[emailTextField]-|" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[resetPasswordButton]-|" options:0 metrics:nil views:views]];
    
    self.viewConstraints = [constraints copy];
    [self.view addConstraints:self.viewConstraints];
}

- (void)resetPasswordButtonTouchDownHandler:(JJButton *)button
{
    [SVProgressHUD showWithStatus:@"Sending Password Reset Request..." maskType:SVProgressHUDMaskTypeBlack];
    __weak JJEmailResetPasswordController *weakSelf = self;
    [[JJParseManager sharedManager] resetPasswordForEmail:self.emailTextField.text withCallback:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            [SVProgressHUD showSuccessWithStatus:@"Password Reset Request Successful"];
            NSMutableAttributedString *attributedString = [weakSelf.label.attributedText mutableCopy];
            NSMutableString *string = [attributedString mutableString];
            [string setString:@"Please check your inbox for the email to reset your password"];
            weakSelf.label.attributedText = attributedString;
            weakSelf.emailTextField.enabled = NO;
            weakSelf.resetPasswordButton.enabled = NO;
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
        self.resetPasswordButton.enabled = newLength > 0;
    }

    return YES;
}

@end
