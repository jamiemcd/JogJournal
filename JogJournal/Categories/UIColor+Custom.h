//
//  UIColor+Custom.h
//  Sightplan Client
//
//  Created by Jamie McDaniel on 7/18/13.
//  Copyright (c) 2013 Sightplan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Custom)

+ (UIColor *)colorWithHexString:(NSString *)hexString;

+ (UIColor *)emergencyColor;
+ (UIColor *)pastDueColor;
+ (UIColor *)headerColor;
+ (UIColor *)headingTextColor;
+ (UIColor *)subheadingTextColor;
+ (UIColor *)progressColor;
+ (UIColor *)progressDirectionColor;
+ (UIColor *)pausedProgressColor;
+ (UIColor *)pausedProgressDirectionColor;
+ (UIColor *)completeColor;
+ (UIColor *)openColor;
+ (UIColor *)grayBorderColor;
+ (UIColor *)accessoryColor;
+ (UIColor *)mapMarkerBadgeColor;
+ (UIColor *)buttonTintColor;
+ (UIColor *)cellHighlightedColor;
+ (UIColor *)cellSelectedColor;
+ (UIColor *)recordRed;
+ (UIColor *)controlColor;
+ (UIColor *)buttonBorderColor;
+ (UIColor *)sightWalkBlueColor;
+ (UIColor *)gridSelectColor;
+ (UIColor *)gridCircleStrokeColor;
+ (UIColor *)gridAndSelectorOverlayColor;

@end
