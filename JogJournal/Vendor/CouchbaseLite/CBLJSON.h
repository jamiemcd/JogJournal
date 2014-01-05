//
//  CBLJSON.h
//  CouchbaseLite
//
//  Created by Jens Alfke on 2/27/12.
//  Copyright (c) 2012-2013 Couchbase, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Useful extensions for JSON serialization/parsing. */
@interface CBLJSON : NSJSONSerialization

/** Encodes an NSDate as a string in ISO-8601 format. */
+ (NSString*) JSONObjectWithDate: (NSDate*)date;

/** Parses an ISO-8601 formatted date string to an NSDate object.
    If the object is not a string, or not valid ISO-8601, it returns nil. */
+ (NSDate*) dateWithJSONObject: (id)jsonObject;

/** Parses an ISO-8601 formatted date string to an absolute time (timeSinceReferenceDate).
    If the object is not a string, or not valid ISO-8601, it returns a NAN value. */
+ (CFAbsoluteTime) absoluteTimeWithJSONObject: (id)jsonObject;

@end







