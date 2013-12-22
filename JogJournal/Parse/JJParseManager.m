//
//  JJParseManager.m
//  JogJournal
//
//  Created by Jamie McDaniel on 12/17/13.
//  Copyright (c) 2013 Curious Find. All rights reserved.
//

#import "JJParseManager.h"
#import <Parse/Parse.h>

#pragma mark - App ID and Client Key

NSString *const JJParseAppID = @"cji3PMaiHDPCtZpzfbjrL4BWuGO9HtNpJfwrFQ46";
NSString *const JJParseClientKey = @"h2qH7HoTzpHXTtXWqWVWe4vLDjM1un5tDgviqfoX";

#pragma mark - User Class

// Field keys
NSString *const JJUserFacebookIDKey = @"facebookID";
NSString *const JJUserFacebookNameKey = @"facebookName";

#pragma mark - Jog Class
// Class key
NSString *const JJJogClassKey = @"Jog";

// Field keys
NSString *const JJJogUserKey = @"user";
NSString *const JJJogStartDateKey = @"startDate";
NSString *const JJJogCompletionDateKey = @"completionDate";

@implementation JJParseManager

NSString * const JJParseManagerUserLogInCompleteNotification = @"JJParseManagerUserLogInCompleteNotification";

+ (JJParseManager *)sharedManager
{
    static dispatch_once_t onceToken;
    static JJParseManager *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [Parse setApplicationId:JJParseAppID clientKey:JJParseClientKey];
        [PFFacebookUtils initializeFacebook];
        
        // By default, any newly created PFObjects belongs to the current user (i.e. only the current user can read/write their data)
        PFACL *defaultACL = [PFACL ACL];
        [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    }
    
    return self;
}

- (void)trackAppOpenedWithLaunchOptions:(NSDictionary *)launchOptions
{
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
}

- (void)logInToFacebookWithCallback:(JJParseManagerCallback)callback
{
    [PFFacebookUtils logInWithPermissions:nil block:^(PFUser *user, NSError *error) {
        if (user)
        {
            // We need to store the user's facebook ID
            [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error)
                {
                    // result is a dictionary with the user's Facebook data
                    NSDictionary *userData = (NSDictionary *)result;
                    NSString *facebookID = userData[@"id"];
                    NSString *facebookName = userData[@"name"];
                    //NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
                    [[PFUser currentUser] setObject:facebookID forKey:JJUserFacebookIDKey];
                    [[PFUser currentUser] setObject:facebookName forKey:JJUserFacebookNameKey];
                    [[PFUser currentUser] saveInBackground];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:JJParseManagerUserLogInCompleteNotification object:self];
                }
            }];
        }
    }];
}

- (void)logInWithEmail:(NSString *)email password:(NSString *)password withCallback:(JJParseManagerCallback)callback
{
    email = [email lowercaseString];
    [PFUser logInWithUsernameInBackground:email password:password block:^(PFUser *user, NSError *error) {
        if (user)
        {
            callback(YES, error);
            [[NSNotificationCenter defaultCenter] postNotificationName:JJParseManagerUserLogInCompleteNotification object:self];
        }
        else
        {
            callback(NO, error);
        }
    }];
}

- (void)signUpWithEmail:(NSString *)email password:(NSString *)password withCallback:(JJParseManagerCallback)callback
{
    email = [email lowercaseString];
    PFUser *user = [PFUser user];
    user.username = email;
    user.email = email;
    user.password = password;
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:JJParseManagerUserLogInCompleteNotification object:self];
        }
        callback(succeeded, error);
    }];
}

- (void)resetPasswordForEmail:(NSString *)email withCallback:(JJParseManagerCallback)callback
{
    email = [email lowercaseString];
    [PFUser requestPasswordResetForEmailInBackground:email block:^(BOOL succeeded, NSError *error) {
        callback(succeeded, error);
    }];
}

- (void)logOut
{
    [PFUser logOut];
}


@end
