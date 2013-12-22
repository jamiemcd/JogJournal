//
//  JJCoreDataManager.m
//  JogJournal
//
//  Created by Jamie McDaniel on 12/17/13.
//  Copyright (c) 2013 Curious Find. All rights reserved.
//

#import "JJCoreDataManager.h"
#import "User+AdditionalMethods.h"
#import "Jog+AdditionalMethods.h"
#import "Location+AdditionalMethods.h"
#import "JJLocationManager.h"
#import "JJParseManager.h"
#import <Parse/Parse.h>

@interface JJCoreDataManager ()

// The ManagedObjectContext that runs on the main (UI) thread. When any external object uses the JJCoreDataManager API, we only
// return NSManagedObject instances that are connected to this ManagedObjectContext.
@property (nonatomic, strong) NSManagedObjectContext *mainManagedObjectContext;

// The ManagedObjectContext that runs on a private thread and will not block the UI
@property (nonatomic, strong) NSManagedObjectContext *backgroundManagedObjectContext;

@property (nonatomic, strong, readwrite) Jog *activeJog;

@end

@implementation JJCoreDataManager

NSString * const JJCoreDataManagerReadyNotification = @"JJCoreDataManagerReadyNotification";
NSString * const JJCoreDataManagerNewLocationAddedToActiveJog = @"JJCoreDataManagerNewLocationAddedToActiveJog";

+ (JJCoreDataManager *)sharedManager
{
    static dispatch_once_t onceToken;
    static JJCoreDataManager *sharedInstance = nil;
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
        [self initializeCoreDataStack];
    }
    
    return self;
}

- (void)saveContext:(BOOL)wait
{
    if ([self.mainManagedObjectContext hasChanges])
    {
        [self.mainManagedObjectContext performBlockAndWait:^{
            NSError *error;
            [self.mainManagedObjectContext save:&error];
            if (error)
            {
                NSLog(@"Error saving main ManagedObjectContext: %@\n%@", [error localizedDescription], [error userInfo]);
            }
        }];
    }
    
    void (^saveBackgroundManagedObjectContext) (void) = ^{
        NSError *error = nil;
        [self.backgroundManagedObjectContext save:&error];
        if (error)
        {
            NSLog(@"Error saving background ManagedObjectContext: %@\n%@", [error localizedDescription], [error userInfo]);
        }
        else
        {
            NSLog(@"background ManagedObjectContext saved");
        }
    };
    
    if ([self.backgroundManagedObjectContext hasChanges])
    {
        if (wait)
        {
            [self.backgroundManagedObjectContext performBlockAndWait:saveBackgroundManagedObjectContext];
        }
        else
        {
            [self.backgroundManagedObjectContext performBlock:saveBackgroundManagedObjectContext];
        }
    }
}

- (void)initializeCoreDataStack
{
    NSURL *dataModelURL = [[NSBundle mainBundle] URLForResource:@"JogJournal" withExtension:@"momd"];
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:dataModelURL];
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    
    self.backgroundManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [self.backgroundManagedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];
    
    self.mainManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [self.mainManagedObjectContext setParentContext:self.backgroundManagedObjectContext];
    
    // Attach the persistent store coordinator without blocking the UI (it is potentially an expensive operation if doing a migration)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *urls = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
        NSURL *storeURL = [urls lastObject];
        storeURL = [storeURL URLByAppendingPathComponent:@"JogJournal.sqlite"];
        
        NSError *error = nil;
        NSPersistentStore *persistentStore = [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
        if (!persistentStore)
        {
            NSLog(@"Error adding persistent store to coordinator %@\n%@", [error localizedDescription], [error userInfo]);
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self contextInitialized];
        });
    });
}

- (void)contextInitialized;
{
    [self startUp];
}

- (void)startUp
{

}

- (User *)currentUser
{
    User *user;
    PFUser *currentParseUser = [PFUser currentUser];
    if (currentParseUser)
    {
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
        NSPredicate *predicate;
        if (currentParseUser[@"facebookID"])
        {
            predicate = [NSPredicate predicateWithFormat:@"facebookID == %@", currentParseUser[@"facebookID"]];
        }
        else
        {
            predicate = [NSPredicate predicateWithFormat:@"email == %@", currentParseUser.email];
        }
        [request setPredicate:predicate];
        NSError *error;
        NSArray *result = [self.mainManagedObjectContext executeFetchRequest:request error:&error];
        if (!result)
        {
            // handle error
        }
        else
        {
            user = [result lastObject];
        }
        
        if (!user)
        {
            // There is not a core data representation of the current Parse user, so we need to create one
            user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:self.mainManagedObjectContext];
            user.email = currentParseUser.email;
            user.facebookID = currentParseUser[@"facebookID"];
            user.facebookName = currentParseUser[@"facebookName"];
        }
    }
    
    return user;
}

- (void)startNewJog
{
    Jog *jog = [NSEntityDescription insertNewObjectForEntityForName:@"Jog" inManagedObjectContext:self.mainManagedObjectContext];
    jog.user = self.currentUser;
    jog.startDate = [NSDate date];
    self.activeJog = jog;
    
    __weak JJCoreDataManager *weakSelf = self;
    [[JJLocationManager sharedManager] getContinuousLocationUpdatesWithCallback:^(CLLocation *location, BOOL requiredAccuracyMet, BOOL *stop) {
        if (!weakSelf || !weakSelf.activeJog)
        {
            // Either This JJCoreDataManager no longer exists or the activeJog no longer exists, so stop continuous location updates.
            *stop = YES;
        }
        if (requiredAccuracyMet)
        {
            [weakSelf addLocationToActiveJog:location];
        }
    }];
}

- (void)completeActiveJog
{
    self.activeJog.endDate = [NSDate date];
    
    // Determine the distance
    NSSortDescriptor *sortDescriptor  = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    NSArray *sortedLocations = [[self.activeJog.locations array] sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    NSUInteger distanceInMeters = 0;
    CLLocation *previousLocation;
    for (Location *jogLocation in sortedLocations)
    {
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[jogLocation.latitude doubleValue] longitude:[jogLocation.longitude doubleValue]];
        if (previousLocation)
        {
            distanceInMeters += [location distanceFromLocation:previousLocation];
        }
        previousLocation = location;
    }
    self.activeJog.distanceInMeters = @(distanceInMeters);
    
    [self saveContext:NO];
    self.activeJog = nil;
}

- (void)addLocationToActiveJog:(CLLocation *)location
{
    Location *jogLocation = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:self.mainManagedObjectContext];
    jogLocation.latitude = @(location.coordinate.latitude);
    jogLocation.longitude = @(location.coordinate.longitude);
    jogLocation.timestamp = location.timestamp;
    jogLocation.jog = self.activeJog;
    [[NSNotificationCenter defaultCenter] postNotificationName:JJCoreDataManagerNewLocationAddedToActiveJog object:self];
}

@end
