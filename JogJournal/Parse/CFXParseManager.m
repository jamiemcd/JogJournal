//
//  CFXParseManager.m
//  JogJournal
//
//  Created by Jamie McDaniel on 12/17/13.
//  Copyright (c) 2013 Curious Find. All rights reserved.
//

#import "CFXParseManager.h"
#import <Parse/Parse.h>
#import "CFXUser+AdditionalMethods.h"
#import "CFXJog+AdditionalMethods.h"
#import "CFXLocation+AdditionalMethods.h"
#import "CFXCoreDataManager.h"
#import "CBLJSON.h"

static NSString *const ParseAppID = @"cji3PMaiHDPCtZpzfbjrL4BWuGO9HtNpJfwrFQ46";
static NSString *const ParseClientKey = @"h2qH7HoTzpHXTtXWqWVWe4vLDjM1un5tDgviqfoX";

// Additional field keys for the PFUser class
static NSString *const ParseUserFacebookIDKey = @"facebookID";
static NSString *const ParseUserFacebookNameKey = @"facebookName";

// Jog Class
static NSString *const ParseJogClassName = @"Jog";
static NSString *const ParseJogUUIDKey = @"uuid";
static NSString *const ParseJogUserKey = @"user";
static NSString *const ParseJogStartDateKey = @"startDate";
static NSString *const ParseJogEndDateKey = @"endDate";
static NSString *const ParseJogDistanceInMetersKey = @"distanceInMeters";
static NSString *const ParseJogLocationsFileKey = @"locationsFile";

// Keys for locationsFile JSON data
static NSString *const ParseLocationLatitudeKey = @"latitude";
static NSString *const ParseLocationLongitudeKey = @"longitude";
static NSString *const ParseLocationTimestampKey = @"timestamp";

@interface CFXParseManager ()

@end

@implementation CFXParseManager

NSString *const CFXParseManagerUserLogInCompleteNotification = @"com.curiousfind.jogjournal.CFXParseManagerUserLogInCompleteNotification";

// User Dictionary keys
NSString *const CFXParseManagerUserDictionaryFacebookIDKey = @"facebookID";
NSString *const CFXParseManagerUserDictionaryFacebookNameKey = @"facebookName";

// Jog Dictionary keys
NSString *const CFXParseManagerJogDictionaryUUIDKey = @"uuid";
NSString *const CFXParseManagerJogDictionaryParseObjectIDKey = @"parseObjectID";
NSString *const CFXParseManagerJogDictionaryUserKey = @"user";
NSString *const CFXParseManagerJogDictionaryStartDateKey = @"startDate";
NSString *const CFXParseManagerJogDictionaryEndDateKey = @"endDate";
NSString *const CFXParseManagerJogDictionaryDistanceInMetersKey = @"distanceInMeters";
NSString *const CFXParseManagerJogDictionaryLocationsKey = @"locations";

// Location Dictionary keys
NSString *const CFXParseManagerLocationDictionaryLatitudeKey = @"latitude";
NSString *const CFXParseManagerLocationDictionaryLongitudeKey = @"longitude";
NSString *const CFXParseManagerLocationDictionaryTimestampKey = @"timestamp";

+ (CFXParseManager *)sharedManager
{
    static dispatch_once_t onceToken;
    static CFXParseManager *sharedInstance = nil;
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
        [Parse setApplicationId:ParseAppID clientKey:ParseClientKey];
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

- (void)logInToFacebookWithCallback:(CFXParseManagerCallback)callback
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
                    [[PFUser currentUser] setObject:facebookID forKey:ParseUserFacebookIDKey];
                    [[PFUser currentUser] setObject:facebookName forKey:ParseUserFacebookNameKey];
                    [[PFUser currentUser] saveInBackground];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:CFXParseManagerUserLogInCompleteNotification object:self];
                }
            }];
        }
    }];
}

- (void)logInWithEmail:(NSString *)email password:(NSString *)password withCallback:(CFXParseManagerCallback)callback
{
    email = [email lowercaseString];
    [PFUser logInWithUsernameInBackground:email password:password block:^(PFUser *user, NSError *error) {
        if (user)
        {
            callback(YES, error);
            [[NSNotificationCenter defaultCenter] postNotificationName:CFXParseManagerUserLogInCompleteNotification object:self];
        }
        else
        {
            callback(NO, error);
        }
    }];
}

- (void)signUpWithEmail:(NSString *)email password:(NSString *)password withCallback:(CFXParseManagerCallback)callback
{
    email = [email lowercaseString];
    PFUser *user = [PFUser user];
    user.username = email;
    user.email = email;
    user.password = password;
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:CFXParseManagerUserLogInCompleteNotification object:self];
        }
        callback(succeeded, error);
    }];
}

- (void)resetPasswordForEmail:(NSString *)email withCallback:(CFXParseManagerCallback)callback
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

- (void)fetchJogsForUser:(CFXUser *)user withCallback:(CFXParseManagerFetchJogsForUserCallback)callback;
{
    // Only the current user can access their jogs, so do a quick check to make sure the user object passed in matches the current user logged into Parse
    if (![user.parseObjectID isEqualToString:[PFUser currentUser].objectId])
    {
        return;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:ParseJogClassName];
    [query whereKey:ParseJogUserKey equalTo:[PFUser currentUser]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *jogObjects, NSError *error) {
        // We will build an array of dictionaries. Each dictionary contains all the information about a jog.
        // We will then execute the callback, passing the array of dictionaries as an argument. We could
        // just pass in the array of PFObjects, but I like to keep all Parse classes contained within the
        // ParseManager. That way if you ever need to switch BaaS (Backend as a Service) providers, it should be easier.
        NSMutableArray *jogDictionaries = [NSMutableArray array];
        NSUInteger jogObjectsCount = [jogObjects count];
        __block NSUInteger jogObjectsLocationDataFetchCompleteCount = 0;
        for (PFObject *jogObject in jogObjects)
        {
            // We have the job info from the query, but the jog's location data is stored in a file. We need to get that data and then we can create the jogDictionary.
            PFFile *locationsFile = jogObject[ParseJogLocationsFileKey];
            [locationsFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                jogObjectsLocationDataFetchCompleteCount++;
                NSError *jsonError = nil;
                
                // First, we get an array of dictionary objects from the JSON. These dictionary objects will have keys ParseLocationLatitudeKey, ParseLocationLongitudeKey, and ParseLocationTimestampKey.
                NSArray *parseLocationDictionaries = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                
                // When we execute our callback, we use the keys defined in our public API, which are CFXParseManagerLocationDictionaryLatitudeKey, CFXParseManagerLocationDictionaryLongitudeKey, and CFXParseManagerLocationDictionaryTimestampKey
                NSMutableArray *locationDictionaries = [NSMutableArray array];
                for (NSDictionary *parseLocationDictionary in parseLocationDictionaries)
                {
                    NSDate *timestamp = [CBLJSON dateWithJSONObject:parseLocationDictionary[ParseLocationTimestampKey]];
                    NSDictionary *locationDictionary = @{ CFXParseManagerLocationDictionaryLatitudeKey: parseLocationDictionary[ParseLocationLatitudeKey],
                                                          CFXParseManagerLocationDictionaryLongitudeKey: parseLocationDictionary[ParseLocationLongitudeKey],
                                                          CFXParseManagerLocationDictionaryTimestampKey: timestamp };
                    [locationDictionaries addObject:locationDictionary];
                }
                NSDictionary *jogDictionary = @{ CFXParseManagerJogDictionaryParseObjectIDKey: jogObject.objectId,
                                                 CFXParseManagerJogDictionaryUUIDKey: jogObject[ParseJogUUIDKey],
                                                 CFXParseManagerJogDictionaryDistanceInMetersKey: jogObject[ParseJogDistanceInMetersKey],
                                                 CFXParseManagerJogDictionaryStartDateKey: jogObject[ParseJogStartDateKey],
                                                 CFXParseManagerJogDictionaryEndDateKey: jogObject[ParseJogEndDateKey],
                                                 CFXParseManagerJogDictionaryLocationsKey: locationDictionaries };
                
                [jogDictionaries addObject:jogDictionary];
                if (jogObjectsLocationDataFetchCompleteCount == jogObjectsCount)
                {
                    callback(jogDictionaries, error);
                }
            }];
        }
    }];
}

- (void)saveJogsForUser:(CFXUser *)user
{
    // Only the current user can save jogs, so do a quick check to make sure the user object passed in matches the current user logged into Parse
    if (![user.parseObjectID isEqualToString:[PFUser currentUser].objectId])
    {
        return;
    }
    
    // This dictionary will have key-value pairs where the key is Jog.uuid and the value is the full Jog object.
    // This is so we can quickly set the Jog.parseObjectID property once the save is complete, without having to
    // loop over an array searching for the correct Jog
    NSMutableDictionary *jogsDictionary = [NSMutableDictionary dictionary];
    
    // First, we loop through the user's jogs. If a jog is complete, it will have a parseObjectID if it has already been saved to Parse.
    NSMutableArray *completedJogsWithNoParseObjectID = [NSMutableArray array];
    for (CFXJog *jog in user.jogs)
    {
        if (jog.endDate && !jog.parseObjectID)
        {
            [completedJogsWithNoParseObjectID addObject:jog];
        }
    }
    
    // The jogObjects array will contain PFObject instances for all the jogs being saved to Parse
    NSMutableArray *jogObjects = [NSMutableArray array];
    
    for (CFXJog *jog in completedJogsWithNoParseObjectID)
    {
        jogsDictionary[jog.uuid] = jog;
        PFObject *jogObject = [PFObject objectWithClassName:ParseJogClassName];
        jogObject[ParseJogUUIDKey] = jog.uuid;
        jogObject[ParseJogStartDateKey] = jog.startDate;
        jogObject[ParseJogEndDateKey] = jog.endDate;
        jogObject[ParseJogDistanceInMetersKey] = jog.distanceInMeters;
        jogObject[ParseJogUserKey] = [PFUser currentUser];
        
        // The jogLocationDictionaries array will contain dictionaries where each dictionary contains the information for a Location
        NSMutableArray *jogLocationDictionaries = [NSMutableArray array];
        for (CFXLocation *location in jog.locations)
        {
            NSMutableDictionary *locationDictionary = [NSMutableDictionary dictionary];
            locationDictionary[ParseLocationLatitudeKey] = location.latitude;
            locationDictionary[ParseLocationLongitudeKey] = location.longitude;
            locationDictionary[ParseLocationTimestampKey] = [CBLJSON JSONObjectWithDate:location.timestamp];
            [jogLocationDictionaries addObject:locationDictionary];
        }
        
        // Now convert the jogLocationDictionaries array into JSON to store as a PFFile
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jogLocationDictionaries options:0 error:&error];
        PFFile *file = [PFFile fileWithName:@"locations.json" data:jsonData];
        
        jogObject[ParseJogLocationsFileKey] = file;
        [jogObjects addObject:jogObject];
    }
    
    [PFObject saveAllInBackground:jogObjects block:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            // Now that the save is complete, set the parseObjectID on all the CFXJog instances.
            for (PFObject *jogObject in jogObjects)
            {
                NSString *uuid = jogObject[ParseJogUUIDKey];
                CFXJog *jog = jogsDictionary[uuid];
                jog.parseObjectID = jogObject.objectId;
            }
            [[CFXCoreDataManager sharedManager] saveContext:NO];
        }
    }];
}


@end
