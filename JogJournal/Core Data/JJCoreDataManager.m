//
//  JJCoreDataManager.m
//  JogJournal
//
//  Created by Jamie McDaniel on 12/17/13.
//  Copyright (c) 2013 Curious Find. All rights reserved.
//

#import "JJCoreDataManager.h"

@interface JJCoreDataManager ()

// The ManagedObjectContext that runs on the main (UI) thread. When any external object uses the JJCoreDataManager API, we only
// return NSManagedObject instances that are connected to this ManagedObjectContext.
@property (nonatomic, strong) NSManagedObjectContext *mainManagedObjectContext;

// The ManagedObjectContext that runs on a private thread and will not block the UI
@property (nonatomic, strong) NSManagedObjectContext *backgroundManagedObjectContext;

@end

@implementation JJCoreDataManager

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

@end
