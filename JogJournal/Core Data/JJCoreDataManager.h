//
//  JJCoreDataManager.h
//  JogJournal
//
//  Created by Jamie McDaniel on 12/17/13.
//  Copyright (c) 2013 Curious Find. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;
@class Jog;

// Those who observe this notification know it is ok to call methods on the CoreDataManager when this is posted
extern NSString * const JJCoreDataManagerReadyNotification;

extern NSString * const JJCoreDataManagerNewLocationAddedToActiveJog;

@interface JJCoreDataManager : NSObject

@property (nonatomic, strong, readonly) User *currentUser;
@property (nonatomic, strong, readonly) Jog *activeJog;

+ (JJCoreDataManager *)sharedManager;

- (void)saveContext:(BOOL)wait;

- (void)startNewJog;

- (void)completeActiveJog;

@end
