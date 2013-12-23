//
//  JJParseManager.m
//  JogJournal
//
//  Created by Jamie McDaniel on 12/17/13.
//  Copyright (c) 2013 Curious Find. All rights reserved.
//

#import "JJParseManager.h"
#import <Parse/Parse.h>
#import "User+AdditionalMethods.h"
#import "Jog+AdditionalMethods.h"
#import "Location+AdditionalMethods.h"
#import "JJCoreDataManager.h"

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
NSString *const JJJogUUIDKey = @"uuid";
NSString *const JJJogUserKey = @"user";
NSString *const JJJogStartDateKey = @"startDate";
NSString *const JJJogEndDateKey = @"endDate";
NSString *const JJJogDistanceInMetersKey = @"distanceInMeters";
NSString *const JJJogLocationsKey = @"locations";

#pragma mark - Location Class
// Class key
NSString *const JJLocationClassKey = @"Location";

// Field keys
NSString *const JJLocationUUIDKey = @"uuid";
NSString *const JJLocationLatitudeKey = @"latitude";
NSString *const JJLocationLongitudeKey = @"longitude";
NSString *const JJLocationTimestampKey = @"timestamp";

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

- (void)fetchJogsForUser:(User *)user withCallback:(JJParseManagerFetchJogsForUserCallback)callback;
{
    // Only the current user can access their jogs, so do a quick check to make sure the user object passed in matches the current user logged into Parse
    if (user.parseObjectID != [PFUser currentUser].objectId)
    {
//        return;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:JJJogClassKey];
    [query whereKey:JJJogUserKey equalTo:[PFUser currentUser]];
    [query includeKey:JJJogLocationsKey];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray *jogDictionaries = [NSMutableArray array];
        for (PFObject *jogObject in objects)
        {   NSMutableArray *locationDictionaries = [NSMutableArray array];
            for (PFObject *locationObject in jogObject[JJJogLocationsKey])
            {
                NSDictionary *locationDictionary = @{ @"parseObjectID": locationObject.objectId,
                                                      @"uuid": locationObject[JJLocationUUIDKey],
                                                      @"latitude": locationObject[JJLocationLatitudeKey],
                                                      @"longitude": locationObject[JJLocationLongitudeKey],
                                                      @"timestamp": locationObject[JJLocationTimestampKey] };
                [locationDictionaries addObject:locationDictionary];
                
            }
            NSDictionary *jogDictionary = @{ @"parseObjectID": jogObject.objectId,
                                             @"uuid": jogObject[JJJogUUIDKey],
                                             @"distanceInMeters": jogObject[JJJogDistanceInMetersKey],
                                             @"startDate": jogObject[JJJogStartDateKey],
                                             @"endDate": jogObject[JJJogEndDateKey],
                                             @"locations": locationDictionaries };
            [jogDictionaries addObject:jogDictionary];
        }
        
        
        callback(jogDictionaries, error);
    }];
}

- (void)saveJogsForUser:(User *)user
{
    // Only the current user can save jogs, so do a quick check to make sure the user object passed in matches the current user logged into Parse
    if (user.parseObjectID != [PFUser currentUser].objectId)
    {
        return;
    }
    
    // These dictionaries will have keys that are the Jog.uuid and Location.uuid
    // This is so we can quickly set their parseObjectID property once the save is complete
    NSMutableDictionary *jogsDictionary = [NSMutableDictionary dictionary];
    NSMutableDictionary *locationsDictionary = [NSMutableDictionary dictionary];
    
    // First, we loop through the user's jogs. If a jog is complete, it will have a parseObjectID if it has already been saved to Parse.
    NSMutableArray *completedJogsWithNoParseObjectID = [NSMutableArray array];
    for (Jog *jog in user.jogs)
    {
        if (jog.endDate && !jog.parseObjectID)
        {
            [completedJogsWithNoParseObjectID addObject:jog];
        }
    }
    
    // The jogObjects array will contain PFObject instances for jogs
    NSMutableArray *jogObjects = [NSMutableArray array];
    
    // The locationObjects array will contain PFObject instances for locations
    NSMutableArray *locationObjects = [NSMutableArray array];
    
    for (Jog *jog in completedJogsWithNoParseObjectID)
    {
        jogsDictionary[jog.uuid] = jog;
        PFObject *jogObject = [PFObject objectWithClassName:JJJogClassKey];
        jogObject[JJJogUUIDKey] = jog.uuid;
        jogObject[JJJogStartDateKey] = jog.startDate;
        jogObject[JJJogEndDateKey] = jog.endDate;
        jogObject[JJJogDistanceInMetersKey] = jog.distanceInMeters;
        jogObject[JJJogUserKey] = [PFUser currentUser];
        
        for (Location *location in jog.locations)
        {
            locationsDictionary[location.uuid] = location;
            PFObject *locationObject = [PFObject objectWithClassName:JJLocationClassKey];
            locationObject[JJLocationUUIDKey] = location.uuid;
            locationObject[JJLocationLatitudeKey] = location.latitude;
            locationObject[JJLocationLongitudeKey] = location.longitude;
            locationObject[JJLocationTimestampKey] = location.timestamp;
            [locationObjects addObject:locationObject];
        }
        
        jogObject[JJJogLocationsKey] = locationObjects;
        [jogObjects addObject:jogObject];
    }
    
    [PFObject saveAllInBackground:jogObjects block:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            for (PFObject *jogObject in jogObjects)
            {
                NSString *uuid = jogObject[JJJogUUIDKey];
                Jog *jog = jogsDictionary[uuid];
                jog.parseObjectID = jogObject.objectId;
            }
            for (PFObject *locationObject in locationObjects)
            {
                NSString *uuid = locationObject[JJLocationUUIDKey];
                Location *location = locationsDictionary[uuid];
                location.parseObjectID = locationObject.objectId;
            }
            [[JJCoreDataManager sharedManager] saveContext:NO];
        }
    }];
}


@end
