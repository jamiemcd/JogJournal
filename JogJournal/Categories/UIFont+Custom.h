//
//  UIFont+Custom.h
//  JogJournal
//
//  Created by Jamie McDaniel on 12/18/13.
//  Copyright (c) 2013 Curious Find. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (Custom)

+ (UIFont *)appFontOfSize:(CGFloat)fontSize;
+ (UIFont *)boldAppFontOfSize:(CGFloat)fontSize;
+ (UIFont *)boldItallicAppFontOfSize:(CGFloat)fontSize;
+ (UIFont *)mediumAppFontOfSize:(CGFloat)fontSize;
+ (UIFont *)lightAppFontOfSize:(CGFloat)fontSize;

@end
