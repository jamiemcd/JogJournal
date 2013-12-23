//
//  Location.h
//  JogJournal
//
//  Created by Jamie McDaniel on 12/22/13.
//  Copyright (c) 2013 Curious Find. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Jog;

@interface Location : NSManagedObject

@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * parseObjectID;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) Jog *jog;

@end
