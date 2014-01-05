//
//  CBLJSON.m
//  CouchbaseLite
//
//  Created by Jens Alfke on 2/27/12.
//  Copyright (c) 2012-2013 Couchbase, Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
//  except in compliance with the License. You may obtain a copy of the License at
//    http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.

#import "CBLJSON.h"
#import "CBLParseDate.h"

@implementation CBLJSON


static NSTimeInterval k1970ToReferenceDate;


+ (void) initialize {
    if (self == [CBLJSON class]) {
        k1970ToReferenceDate = [[NSDate dateWithTimeIntervalSince1970: 0.0]
                                                    timeIntervalSinceReferenceDate];
    }
}

#pragma mark - DATE CONVERSION:

// These functions are not thread-safe, nor are the NSDateFormatter instances they return.
// Make sure that this function and the formatter are called on only one thread at a time.
static NSDateFormatter* getISO8601Formatter() {
    static NSDateFormatter* sFormatter;
    if (!sFormatter) {
        // Thanks to DenNukem's answer in http://stackoverflow.com/questions/399527/
        sFormatter = [[NSDateFormatter alloc] init];
        sFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
        sFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        sFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        sFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    }
    return sFormatter;
}

+ (NSString*) JSONObjectWithDate: (NSDate*)date {
    if (!date)
        return nil;
    @synchronized(self) {
        return [getISO8601Formatter() stringFromDate: date];
    }
}

+ (CFAbsoluteTime) absoluteTimeWithJSONObject: (id)jsonObject {
    NSString *string;
    if ([jsonObject isKindOfClass:[NSString class]])
    {
        string = (NSString *)jsonObject;
    }
    if (!string)
        return NAN;
    return CBLParseISO8601Date(string.UTF8String) + k1970ToReferenceDate;
}

+ (NSDate*) dateWithJSONObject: (id)jsonObject {
    NSTimeInterval t = [self absoluteTimeWithJSONObject: jsonObject];
    return isnan(t) ? nil : [NSDate dateWithTimeIntervalSinceReferenceDate: t];
}

@end