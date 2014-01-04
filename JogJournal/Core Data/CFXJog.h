//
//  CFXJog.h
//  JogJournal
//
//  Created by Jamie McDaniel on 1/4/14.
//  Copyright (c) 2014 Curious Find. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CFXLocation, CFXUser;

@interface CFXJog : NSManagedObject

@property (nonatomic, retain) NSNumber * distanceInMeters;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSString * parseObjectID;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSOrderedSet *locations;
@property (nonatomic, retain) CFXUser *user;
@end

@interface CFXJog (CoreDataGeneratedAccessors)

- (void)insertObject:(CFXLocation *)value inLocationsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromLocationsAtIndex:(NSUInteger)idx;
- (void)insertLocations:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeLocationsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInLocationsAtIndex:(NSUInteger)idx withObject:(CFXLocation *)value;
- (void)replaceLocationsAtIndexes:(NSIndexSet *)indexes withLocations:(NSArray *)values;
- (void)addLocationsObject:(CFXLocation *)value;
- (void)removeLocationsObject:(CFXLocation *)value;
- (void)addLocations:(NSOrderedSet *)values;
- (void)removeLocations:(NSOrderedSet *)values;
@end
