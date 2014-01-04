//
//  CFXCoreDataManager.h
//  JogJournal
//
//  Created by Jamie McDaniel on 12/17/13.
//  Copyright (c) 2013 Curious Find. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CFXUser;
@class CFXJog;

// Those who observe this notification know it is ok to call methods on the CoreDataManager when this is posted
extern NSString * const CFXCoreDataManagerReadyNotification;

// This notification is posted when a new location is added to the activeJog.locations array
extern NSString * const CFXCoreDataManagerNewLocationAddedToActiveJog;

@interface CFXCoreDataManager : NSObject

@property (nonatomic, strong, readonly) CFXUser *currentUser;
@property (nonatomic, strong, readonly) CFXJog *activeJog;

+ (CFXCoreDataManager *)sharedManager;

- (void)saveContext:(BOOL)wait;

// Call this method to start a new jog and have it receive location data
- (void)startNewJog;

// Call this method to complete the active jog
- (void)completeActiveJog;

@end
