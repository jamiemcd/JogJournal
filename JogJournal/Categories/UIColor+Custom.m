//
//  UIColor+Custom.m
//  Sightplan Client
//
//  Created by Jamie McDaniel on 7/18/13.
//  Copyright (c) 2013 Sightplan. All rights reserved.
//

#import "UIColor+Custom.h"

@implementation UIColor (Custom)

+ (UIColor *)colorWithHexString:(NSString *)hexString
{
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#" withString: @""] uppercaseString];
    CGFloat alpha, red, blue, green;
    switch ([colorString length])
    {
        case 3: // #RGB
            alpha = 1.0f;
            red   = [self colorComponentFrom:colorString start:0 length:1];
            green = [self colorComponentFrom:colorString start:1 length:1];
            blue  = [self colorComponentFrom:colorString start:2 length:1];
            break;
        case 4: // #ARGB
            alpha = [self colorComponentFrom:colorString start:0 length:1];
            red   = [self colorComponentFrom:colorString start:1 length:1];
            green = [self colorComponentFrom:colorString start:2 length:1];
            blue  = [self colorComponentFrom:colorString start:3 length:1];
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = [self colorComponentFrom:colorString start:0 length:2];
            green = [self colorComponentFrom:colorString start:2 length:2];
            blue  = [self colorComponentFrom:colorString start:4 length:2];
            break;
        case 8: // #AARRGGBB
            alpha = [self colorComponentFrom:colorString start:0 length:2];
            red   = [self colorComponentFrom:colorString start:2 length:2];
            green = [self colorComponentFrom:colorString start:4 length:2];
            blue  = [self colorComponentFrom:colorString start:6 length:2];
            break;
        default:
            [NSException raise:@"Invalid color value" format:@"Color value %@ is invalid.  It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", hexString];
            break;
    }
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (CGFloat)colorComponentFrom:(NSString *)string start:(NSUInteger)start length:(NSUInteger)length
{
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = (length == 2) ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString:fullHex] scanHexInt:&hexComponent];
    return hexComponent / 255.0;
}

+ (UIColor *)emergencyColor
{
    return [UIColor colorWithHexString:@"#F0222D"];
}

+ (UIColor *)pastDueColor
{
    return [UIColor colorWithHexString:@"#FFC300"];
}

+ (UIColor *)headerColor
{
    return [UIColor colorWithHexString:@"#EEEEEE"];
}

+ (UIColor *)headingTextColor
{
    return [UIColor blackColor];
}

+ (UIColor *)subheadingTextColor
{
    return [UIColor colorWithHexString:@"#55565A"];
}

+ (UIColor *)progressColor
{
    return [UIColor colorWithHexString:@"#0082CA"];
}

+ (UIColor *)progressDirectionColor
{
    return [UIColor colorWithHexString:@"8FC7E8"];
}

+ (UIColor *)pausedProgressColor
{
    return [UIColor colorWithHexString:@"#55565A"];
}

+ (UIColor *)pausedProgressDirectionColor
{
    return [UIColor colorWithHexString:@"CAC8C8"];
}

+ (UIColor *)completeColor
{
    return [UIColor colorWithHexString:@"77BC1F"];
}

+ (UIColor *)openColor
{
    return [UIColor colorWithHexString:@"#EEEEEE"];
}

+ (UIColor *)grayBorderColor
{
    return [UIColor colorWithHexString:@"CAC8C8"];
}

+ (UIColor *)accessoryColor
{
    return [UIColor colorWithHexString:@"CAC8C8"];
}

+ (UIColor *)mapMarkerBadgeColor
{
    return [UIColor colorWithHexString:@"#55565A"];
}

+ (UIColor *)buttonTintColor
{
    return [UIColor colorWithHexString:@"8FC7E8"];
}

+ (UIColor *)cellHighlightedColor
{
    return [UIColor colorWithHexString:@"D9D9D9"];
}

+ (UIColor *)cellSelectedColor
{
    return [UIColor colorWithHexString:@"D9D9D9"];
}

+ (UIColor *)recordRed
{
    return [UIColor colorWithHexString:@"F0222D"];
}

+ (UIColor *)controlColor
{
    return [UIColor colorWithHexString:@"#4287E0"];
}

+ (UIColor *)buttonBorderColor
{
    return [[UIColor whiteColor] colorWithAlphaComponent:0.5];
}

+ (UIColor *)sightWalkBlueColor
{
    return [UIColor colorWithHexString:@"#0082CA"];
}

+ (UIColor *)gridSelectColor
{
    return [UIColor colorWithHexString:@"#0082CA"];
}

+ (UIColor *)gridCircleStrokeColor
{
    return [UIColor colorWithHexString:@"#BEBBBB"];
}

+ (UIColor *)gridAndSelectorOverlayColor
{
    return [UIColor colorWithWhite:0 alpha:0.8];
}



@end
 