//
//  UIFont+Custom.m
//  JogJournal
//
//  Created by Jamie McDaniel on 12/18/13.
//  Copyright (c) 2013 Curious Find. All rights reserved.
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
