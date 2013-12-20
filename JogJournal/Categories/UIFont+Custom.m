//
//  UIFont+Custom.m
//  Sightplan Client
//
//  Created by Jamie McDaniel on 8/28/13.
//  Copyright (c) 2013 Sightplan. All rights reserved.
//

#import "UIFont+Custom.h"

@implementation UIFont (Custom)

+ (UIFont *)appFontOfSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"HelveticaNeue" size:fontSize];
}

+ (UIFont *)boldAppFontOfSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"HelveticaNeue-Bold" size:fontSize];
}

+ (UIFont *)boldItallicAppFontOfSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:fontSize];
}

+ (UIFont *)mediumAppFontOfSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"HelveticaNeue-Medium" size:fontSize];
}

+ (UIFont *)lightAppFontOfSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:fontSize];
}

@end
