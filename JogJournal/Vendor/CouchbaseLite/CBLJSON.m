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
#import "CBLBase64.h"

@implementation CBLJSON


static NSTimeInterval k1970ToReferenceDate;


+ (void) initialize {
    if (self == [CBLJSON class]) {
        k1970ToReferenceDate = [[NSDate dateWithTimeIntervalSince1970: 0.0]
                                                    timeIntervalSinceReferenceDate];
    }
}


+ (NSData *)dataWithJSONObject:(id)object
                       options:(NSJSONWritingOptions)options
                         error:(NSError **)error
{
    if ((options & CBLJSONWritingAllowFragments)
            && ![object isKindOfClass: [NSDictionary class]]
            && ![object isKindOfClass: [NSArray class]]) {
        // NSJSONSerialization won't write fragments, so if I get one wrap it in an array first:
        object = [[NSArray alloc] initWithObjects: &object count: 1];
        NSData* json = [super dataWithJSONObject: object 
                                         options: (options & ~CBLJSONWritingAllowFragments)
                                           error: NULL];
        return [json subdataWithRange: NSMakeRange(1, json.length - 2)];
    } else {
        return [super dataWithJSONObject: object options: options error: error];
    }
}


+ (NSString*) stringWithJSONObject:(id)obj
                           options:(CBLJSONWritingOptions)opt
                             error:(NSError **)error
{
    NSData *data = [self dataWithJSONObject: obj options: opt error: error];
    return [[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding];
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


#pragma mark - BASE64:


+ (NSString*) base64StringWithData: (NSData*)data {
    return data ? [CBLBase64 encode: data] : nil;
}

+ (NSData*) dataWithBase64String: (id)jsonObject {
    if (![jsonObject isKindOfClass: [NSString class]])
        return nil;
    return [CBLBase64 decode: jsonObject];
}


#pragma mark - JSON POINTER:


// Resolves a JSON-Pointer string, returning the pointed-to value:
// http://tools.ietf.org/html/draft-ietf-appsawg-json-pointer-04
+ (id) valueAtPointer: (NSString*)pointer inObject: (id)object {
    NSScanner* scanner = [NSScanner scannerWithString: pointer];
    scanner.charactersToBeSkipped = [NSCharacterSet characterSetWithCharactersInString: @"/"];

    while (!scanner.isAtEnd) {
        if ([object isKindOfClass: [NSDictionary class]]) {
            NSString* key;
            if (![scanner scanUpToString: @"/" intoString: &key])
                return nil;
            key = [key stringByReplacingOccurrencesOfString: @"~1" withString: @"/"];
            key = [key stringByReplacingOccurrencesOfString: @"~0" withString: @"~"];
            object = [object objectForKey: key];
            if (!object)
                return nil;
        } else if ([object isKindOfClass: [NSArray class]]) {
            int index;
            if (![scanner scanInt: &index] || index < 0 || index >= (int)[object count])
                return nil;
            object = [object objectAtIndex: index];
        } else {
            return nil;
        }
    }
    return object;
}


@end



#pragma mark - LAZY ARRAY:


@implementation CBLLazyArrayOfJSON
{
    NSMutableArray* _array;
}

- (instancetype) initWithMutableArray: (NSMutableArray*)array {
    self = [super init];
    if (self) {
        _array = array;
    }
    return self;
}

- (NSUInteger)count {
    return _array.count;
}

- (id)objectAtIndex:(NSUInteger)index {
    id obj = [_array objectAtIndex: index];
    if ([obj isKindOfClass: [NSData class]]) {
        obj = [CBLJSON JSONObjectWithData: obj options: CBLJSONReadingAllowFragments
                                   error: nil];
        [_array replaceObjectAtIndex: index withObject: obj];
    }
    return obj;
}

@end



