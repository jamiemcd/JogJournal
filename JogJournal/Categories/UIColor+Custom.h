//
//  UIColor+Custom.h
//  JogJournal
//
//  Created by Jamie McDaniel on 12/18/13.
//  Copyright (c) 2013 Curious Find. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Custom)

+ (UIColor *)colorWithHexString:(NSString *)hexString;

+ (UIColor *)jogJournalBlue;
+ (UIColor *)jogJournalGreen;
+ (UIColor *)jogJournalBrown;
+ (UIColor *)facebookBlue;
+ (UIColor *)emailRed;

@end
