//
//  CFXJog+AdditionalMethods.m
//  JogJournal
//
//  Created by Jamie McDaniel on 12/21/13.
//  Copyright (c) 2013 Curious Find. All rights reserved.
//

#import "CFXJog+AdditionalMethods.h"

@implementation CFXJog (AdditionalMethods)

- (NSString *)durationString
{
    NSTimeInterval timeInterval = [self.endDate timeIntervalSinceDate:self.startDate];
    NSInteger duration = (NSInteger)timeInterval;
    NSInteger hours = (duration / 3600);
    NSInteger minutes = (duration / 60) % 60;
    NSInteger seconds = duration % 60;
    if (hours > 0)
    {
        return [NSString stringWithFormat:@"%02lih %02lim %02lis", (long)hours, (long)minutes, (long)seconds];
    }
    else if (minutes > 0)
    {
        return [NSString stringWithFormat:@"%02lim %02lis", (long)minutes, (long)seconds];
    }
    else
    {
        return [NSString stringWithFormat:@"%02lis", (long)seconds];
    }
}

- (NSString *)distanceString
{
    double miles = [self.distanceInMeters integerValue] * 0.000621371;
    if (miles > 0.1)
    {
        return [NSString stringWithFormat:@"%.02fmi", miles];
    }
    else
    {
        int feet = [self.distanceInMeters integerValue] * 3.28084;
        return [NSString stringWithFormat:@"%ift", feet];
    }
}

- (NSString *)averageSpeedString
{
    NSTimeInterval timeInterval = [self.endDate timeIntervalSinceDate:self.startDate];

    double averageSpeedInMetersPerSecond = [self.distanceInMeters doubleValue] / timeInterval;
    double averageSpeedInMilesPerHour = averageSpeedInMetersPerSecond * 2.23694;
    
    return [NSString stringWithFormat:@"%.02fmi/h", averageSpeedInMilesPerHour];
}

@end
