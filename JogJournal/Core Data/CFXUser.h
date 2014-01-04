//
//  CFXUser.h
//  JogJournal
//
//  Created by Jamie McDaniel on 1/4/14.
//  Copyright (c) 2014 Curious Find. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CFXJog;

@interface CFXUser : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * facebookID;
@property (nonatomic, retain) NSData * facebookImage;
@property (nonatomic, retain) NSString * facebookName;
@property (nonatomic, retain) NSString * parseObjectID;
@property (nonatomic, retain) NSOrderedSet *jogs;
@end

@interface CFXUser (CoreDataGeneratedAccessors)

- (void)insertObject:(CFXJog *)value inJogsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromJogsAtIndex:(NSUInteger)idx;
- (void)insertJogs:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeJogsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInJogsAtIndex:(NSUInteger)idx withObject:(CFXJog *)value;
- (void)replaceJogsAtIndexes:(NSIndexSet *)indexes withJogs:(NSArray *)values;
- (void)addJogsObject:(CFXJog *)value;
- (void)removeJogsObject:(CFXJog *)value;
- (void)addJogs:(NSOrderedSet *)values;
- (void)removeJogs:(NSOrderedSet *)values;
@end
