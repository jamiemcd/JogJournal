//
//  JJParseManager.h
//  JogJournal
//
//  Created by Jamie McDaniel on 12/17/13.
//  Copyright (c) 2013 Curious Find. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PFUser;
@class User;

extern NSString * const JJParseManagerUserLogInCompleteNotification;

// Those who observe this notification will receive a dictionary of the latest data from the cloud when this is posted
extern NSString * const JJParseManagerFetchFromCloudCompleteNotification;

typedef void (^JJParseManagerCallback)(BOOL succeeded, NSError *error);
typedef void (^JJParseManagerFetchJogsForUserCallback)(NSArray *jogDictionaries, NSError *error);

@interface JJParseManager : NSObject

+ (JJParseManager *)sharedManager;

- (void)trackAppOpenedWithLaunchOptions:(NSDictionary *)launchOptions;

- (void)logInToFacebookWithCallback:(JJParseManagerCallback)callback;

- (void)logInWithEmail:(NSString *)email password:(NSString *)password withCallback:(JJParseManagerCallback)callback;

- (void)signUpWithEmail:(NSString *)email password:(NSString *)password withCallback:(JJParseManagerCallback)callback;

- (void)resetPasswordForEmail:(NSString *)email withCallback:(JJParseManagerCallback)callback;

- (void)logOut;

- (void)fetchJogsForUser:(User *)user withCallback:(JJParseManagerFetchJogsForUserCallback)callback;

- (void)saveJogsForUser:(User *)user;

@end
