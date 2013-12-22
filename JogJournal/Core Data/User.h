//
//  User.h
//  JogJournal
//
//  Created by Jamie McDaniel on 12/22/13.
//  Copyright (c) 2013 Curious Find. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Jog;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * facebookID;
@property (nonatomic, retain) NSData * facebookImage;
@property (nonatomic, retain) NSString * facebookName;
@property (nonatomic, retain) NSOrderedSet *jogs;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)insertObject:(Jog *)value inJogsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromJogsAtIndex:(NSUInteger)idx;
- (void)insertJogs:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeJogsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInJogsAtIndex:(NSUInteger)idx withObject:(Jog *)value;
- (void)replaceJogsAtIndexes:(NSIndexSet *)indexes withJogs:(NSArray *)values;
- (void)addJogsObject:(Jog *)value;
- (void)removeJogsObject:(Jog *)value;
- (void)addJogs:(NSOrderedSet *)values;
- (void)removeJogs:(NSOrderedSet *)values;
@end
