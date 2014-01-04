//
//  CFXLocation.h
//  JogJournal
//
//  Created by Jamie McDaniel on 1/4/14.
//  Copyright (c) 2014 Curious Find. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CFXJog;

@interface CFXLocation : NSManagedObject

@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) CFXJog *jog;

@end
