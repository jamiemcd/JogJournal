//
//  CFXLocationManager.h
//  JogJournal
//
//  Created by Jamie McDaniel on 12/20/13.
//  Copyright (c) 2013 Curious Find. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void (^CFXLocationManagerGetLocationUpdateCallback)(CLLocation *location, BOOL requiredAccuracyMet);
typedef void (^CFXLocationManagerGetContinuousLocationUpdatesCallback)(CLLocation *location, BOOL requiredAccuracyMet, BOOL *stop);

@interface CFXLocationManager : NSObject

@property (strong, nonatomic) CLLocation *location;

+ (CFXLocationManager *)sharedManager;

/*! When this method is called, the internal CLLocationManager starts receiving location updates (if it is not already). The callback is executed one time when an updated location is received.
 *
 @param callback  The block to execute once an updated location is received
 @return
 *
 */
- (void)getLocationUpdateWithCallback:(CFXLocationManagerGetLocationUpdateCallback)callback;

/*! When this method is called, the internal CLLocationManager starts receiving location updates (if it is not already). The callback is executed every time an updated location is received
 *  until the stop parameter in the callback is set to YES.
 *
 @param callback  The block to execute once an updated location is received
 @return
 *
 */
- (void)getContinuousLocationUpdatesWithCallback:(CFXLocationManagerGetContinuousLocationUpdatesCallback)callback;

@end
