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

// Notifications
extern NSString * const CFXParseManagerUserLogInCompleteNotification;

// User Dictionary keys
extern NSString *const CFXParseManagerUserDictionaryFacebookIDKey; // value is an NSString
extern NSString *const CFXParseManagerUserDictionaryFacebookNameKey; // value is an NSString

// Jog Dictionary keys
extern NSString *const CFXParseManagerJogDictionaryUUIDKey; // value is an NSString
extern NSString *const CFXParseManagerJogDictionaryParseObjectIDKey; // value is an NSString
extern NSString *const CFXParseManagerJogDictionaryUserKey; // value is an NSString
extern NSString *const CFXParseManagerJogDictionaryStartDateKey; // value is an NSDate
extern NSString *const CFXParseManagerJogDictionaryEndDateKey; // value is an NSDate
extern NSString *const CFXParseManagerJogDictionaryDistanceInMetersKey; // value is an NSNumber
extern NSString *const CFXParseManagerJogDictionaryLocationsKey; // value is an array of dictionary objects, each containing the keys listed under Location Dictionary keys

// Location Dictionary keys
extern NSString *const CFXParseManagerLocationDictionaryLatitudeKey; // value is an NSNumber
extern NSString *const CFXParseManagerLocationDictionaryLongitudeKey; // value is an NSNumber
extern NSString *const CFXParseManagerLocationDictionaryTimestampKey; // value is an NSDate

typedef void (^CFXParseManagerCallback)(BOOL succeeded, NSError *error);

// jogDictionaries is an array of dictionary objects. Each dictionary contains the keys listed above under Jog Dictionary keys.
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
