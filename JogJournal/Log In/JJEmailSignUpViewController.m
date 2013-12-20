//
//  JJEmailSignUpViewController.m
//  JogJournal
//
//  Created by Jamie McDaniel on 12/19/13.
//  Copyright (c) 2013 Curious Find. All rights reserved.
//

#import "JJEmailSignUpViewController.h"
#import "UIFont+Custom.h"
#import "UIColor+Custom.h"
#import "JJButton.h"
#import "JJParseManager.h"

@interface JJEmailSignUpViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *emailTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) JJButton *signUpButton;

@property (nonatomic, strong) NSArray *viewConstraints;

@end

@implementation JJEmailSignUpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = @"Sign Up";
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
    
    // signUpButton
    self.signUpButton = [[JJButton alloc] init];
    [self.signUpButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.signUpButton.color = [UIColor emailRed];
    self.signUpButton.image = [UIImage imageNamed:@"email-logo"];
    self.signUpButton.title = @"Sign Up";
    self.signUpButton.enabled = NO;
    [self.signUpButton addTarget:self action:@selector(signUpButtonTouchDownHandler:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.signUpButton];
    
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
                             @"signUpButton": self.signUpButton };
    
    NSMutableArray *constraints = [NSMutableArray array];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topLayoutGuide]-20-[emailTextField]-[passwordTextField]-20-[signUpButton(==60)]" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[emailTextField]-|" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[passwordTextField]-|" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[signUpButton]-|" options:0 metrics:nil views:views]];
    
    self.viewConstraints = [constraints copy];
    [self.view addConstraints:self.viewConstraints];
}

- (void)signUpButtonTouchDownHandler:(JJButton *)button
{
    __weak JJEmailSignUpViewController *weakSelf = self;
    [[JJParseManager sharedManager] signUpWithEmail:self.emailTextField.text password:self.passwordTextField.text withCallback:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            [weakSelf.navigationController popToRootViewControllerAnimated:YES];
        }
        else if (weakSelf)
        {
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
        self.signUpButton.enabled = newLength > 0 && [self.passwordTextField.text length] > 0;
    }
    else if (textField == self.passwordTextField)
    {
        self.signUpButton.enabled = newLength > 0 && [self.emailTextField.text length] > 0;
    }
    
    return YES;
}

@end
