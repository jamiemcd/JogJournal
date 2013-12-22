//
//  Jog+AdditionalMethods.m
//  JogJournal
//
//  Created by Jamie McDaniel on 12/21/13.
//  Copyright (c) 2013 Curious Find. All rights reserved.
//

#import "Jog+AdditionalMethods.h"

@implementation Jog (AdditionalMethods)

- (NSString *)durationString
{
    NSTimeInterval timeInterval = [self.endDate timeIntervalSinceDate:self.startDate];
    NSInteger duration = (NSInteger)timeInterval;
    NSInteger hours = (duration / 3600);
    NSInteger minutes = (duration / 60) % 60;
    NSInteger seconds = duration % 60;
    if (hours > 0)
    {
        return [NSString stringWithFormat:@"%02ih %02im %02is", hours, minutes, seconds];
    }
    else if (minutes > 0)
    {
        return [NSString stringWithFormat:@"%02im %02is", minutes, seconds];
    }
    else
    {
        return [NSString stringWithFormat:@"%02is", seconds];
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

@end
