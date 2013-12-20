//
//  UIFont+Custom.h
//  Sightplan Client
//
//  Created by Jamie McDaniel on 8/28/13.
//  Copyright (c) 2013 Sightplan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (Custom)

+ (UIFont *)appFontOfSize:(CGFloat)fontSize;
+ (UIFont *)boldAppFontOfSize:(CGFloat)fontSize;
+ (UIFont *)boldItallicAppFontOfSize:(CGFloat)fontSize;
+ (UIFont *)mediumAppFontOfSize:(CGFloat)fontSize;
+ (UIFont *)lightAppFontOfSize:(CGFloat)fontSize;

@end
