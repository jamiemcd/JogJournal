//
//  CFXParseManager.h
//  JogJournal
//
//  Created by Jamie McDaniel on 12/17/13.
//  Copyright (c) 2013 Curious Find. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PFUser;
@class CFXUser;

extern NSString * const CFXParseManagerUserLogInCompleteNotification;

typedef void (^CFXParseManagerCallback)(BOOL succeeded, NSError *error);
typedef void (^CFXParseManagerFetchJogsForUserCallback)(NSArray *jogDictionaries, NSError *error);

@interface CFXParseManager : NSObject

+ (CFXParseManager *)sharedManager;

- (void)trackAppOpenedWithLaunchOptions:(NSDictionary *)launchOptions;

- (void)logInToFacebookWithCallback:(CFXParseManagerCallback)callback;

- (void)logInWithEmail:(NSString *)email password:(NSString *)password withCallback:(CFXParseManagerCallback)callback;

- (void)signUpWithEmail:(NSString *)email password:(NSString *)password withCallback:(CFXParseManagerCallback)callback;

- (void)resetPasswordForEmail:(NSString *)email withCallback:(CFXParseManagerCallback)callback;

- (void)logOut;

- (void)fetchJogsForUser:(CFXUser *)user withCallback:(CFXParseManagerFetchJogsForUserCallback)callback;

- (void)saveJogsForUser:(CFXUser *)user;

@end
