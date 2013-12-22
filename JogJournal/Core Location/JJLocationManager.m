//
//  JJLocationManager.m
//  JogJournal
//
//  Created by Jamie McDaniel on 12/20/13.
//  Copyright (c) 2013 Curious Find. All rights reserved.
//

#import "JJLocationManager.h"

#define requiredGPSAccuracyForLocationToBeConsideredAccurate 10.0 // in meters
#define timeIntervalForLocationToBeConsideredFresh 30.0 // in seconds
#define locationCallbackTimeoutTime 10.0 // in seconds

@interface JJLocationManager () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (nonatomic) BOOL updatingLocations;

// An array of blocks. The blocks will be of type JJLocationManagerGetLocationUpdateCallback
@property (nonatomic, strong) NSMutableArray *locationUpdateCallbacks;

// An array of blocks. The blocks will be of type JJLocationManagerGetContinuousLocationUpdatesCallback
@property (nonatomic, strong) NSMutableArray *continuousLocationUpdatesCallbacks;

// If the location has not been updated by CoreLocation in a certain amount of time and
// we have callbacks, then we go ahead and execute the callbacks with self.location
@property (nonatomic, strong) NSTimer *locationCallbackTimeoutTimer;

@end

@implementation JJLocationManager

+ (JJLocationManager *)sharedManager
{
    static dispatch_once_t onceToken;
    static JJLocationManager *sharedInstance = nil;
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
        self.locationUpdateCallbacks = [NSMutableArray array];
        self.continuousLocationUpdatesCallbacks = [NSMutableArray array];
        
        // make sure location services are enabled
        if ([CLLocationManager locationServicesEnabled])
        {
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.delegate = self;
            self.locationManager.activityType = CLActivityTypeFitness;
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            self.locationManager.distanceFilter = kCLDistanceFilterNone;
        }
        
        //        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackgroundNotificationHandler:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        //        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActiveNotificationHandler:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationDidEnterBackgroundNotificationHandler:(NSNotification *)notification
{
    [self stopUpdatingLocation];
}

- (void)applicationDidBecomeActiveNotificationHandler:(NSNotification *)notification
{
    [self startUpdatingLocation];
}

- (BOOL)locationMeetsRequiredAccuracy:(CLLocation *)location
{
    return (self.location && self.location.horizontalAccuracy <= requiredGPSAccuracyForLocationToBeConsideredAccurate) ? YES : NO;
}

- (void)getLocationUpdateWithCallback:(JJLocationManagerGetLocationUpdateCallback)callback
{
    [self.locationUpdateCallbacks addObject:callback];
    [self startLocationCallbackTimeoutTimer];
    if (!self.updatingLocations)
    {
        [self startUpdatingLocation];
    }
}

- (void)getContinuousLocationUpdatesWithCallback:(JJLocationManagerGetContinuousLocationUpdatesCallback)callback
{
    [self.continuousLocationUpdatesCallbacks addObject:callback];
    [self startLocationCallbackTimeoutTimer];
    if (!self.updatingLocations)
    {
        [self startUpdatingLocation];
    }
}

- (void)startUpdatingLocation
{
    [self.locationManager startUpdatingLocation];
    self.updatingLocations = YES;
}

- (void)stopUpdatingLocation
{
    [self.locationManager stopUpdatingLocation];
    self.updatingLocations = NO;
}

- (void)startLocationCallbackTimeoutTimer
{
    // We only want to start the locationCallbackTimeoutTimer if there are any callbacks and we aren't already timing
    if (!self.locationCallbackTimeoutTimer && ([self.locationUpdateCallbacks count] || [self.continuousLocationUpdatesCallbacks count]))
    {
        // Ensure that the locationCallbackTimeoutTimer runs on the main run loop (or else we are responsible for starting the runloop for the other thread).
        // Also, we do another check before creating the timer, in case the startLocationCallbackTimeoutTimer method was called again before this block runs on the main thread.
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!self.locationCallbackTimeoutTimer)
            {
                self.locationCallbackTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:locationCallbackTimeoutTime target:self selector:@selector(locationCallbackTimeoutTimerCompleteHandler:) userInfo:nil repeats:NO];
            }
        });
    }
}

- (void)stopLocationCallbackTimeoutTimer
{
    [self.locationCallbackTimeoutTimer invalidate];
    self.locationCallbackTimeoutTimer = nil;
}

- (void)locationCallbackTimeoutTimerCompleteHandler:(NSTimer *)timer
{
    [self stopLocationCallbackTimeoutTimer];
    [self executeLocationCallbacks];
}

- (void)executeLocationCallbacks
{
    BOOL requiredAccuracyMet = [self locationMeetsRequiredAccuracy:self.location];
    for (JJLocationManagerGetLocationUpdateCallback callback in self.locationUpdateCallbacks)
    {
        callback(self.location, requiredAccuracyMet);
    }
    // We don't keep locationUpdateCallbacks around after we have new location data
    [self.locationUpdateCallbacks removeAllObjects];
    
    // We do keep continuousLocationUpdatesCallbacks around unless we are told to stop in the callback
    NSMutableArray *callbacksToRemove = [NSMutableArray array];
    for (JJLocationManagerGetContinuousLocationUpdatesCallback callback in self.continuousLocationUpdatesCallbacks)
    {
        BOOL stop = NO;
        callback(self.location, requiredAccuracyMet, &stop);
        if (stop)
        {
            NSLog(@"Stopping a continuousLocationUpdatesCallback");
            [callbacksToRemove addObject:callback];
        }
    }
    
    for (JJLocationManagerGetContinuousLocationUpdatesCallback callback in callbacksToRemove)
    {
        [self.continuousLocationUpdatesCallbacks removeObject:callback];
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"locationManager:didUpdateLocations:");
    CLLocation *location = (CLLocation *)[locations lastObject];
    
    //Make sure the location is fresh
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:location.timestamp];
    if (CLLocationCoordinate2DIsValid(location.coordinate) && location.timestamp && timeInterval < timeIntervalForLocationToBeConsideredFresh)
    {
        self.location = location;
        [self executeLocationCallbacks];
        [self stopLocationCallbackTimeoutTimer];
    }
    
    // If we have determined we are a GPS device and currently have no callbacks, then we can stop updating our location to save battery life
    if ([self.continuousLocationUpdatesCallbacks count] == 0)
    {
        [self stopUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if ([error code] == kCLErrorDenied)
    {
        // Ask user to enable location services?
    }
    else
    {
        
    }
    NSLog(@"locationManager failed with error: %@", error.localizedDescription);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    // Need to handle the user changing Location Services Enabled/Disabled in iOS device Settings
}

@end
