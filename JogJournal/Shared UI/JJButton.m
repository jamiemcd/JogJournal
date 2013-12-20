//
//  JJButton.m
//  JogJournal
//
//  Created by Jamie McDaniel on 12/18/13.
//  Copyright (c) 2013 Curious Find. All rights reserved.
//

#import "JJButton.h"
#import "UIFont+Custom.h"

@interface JJButton ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *label;

@property (nonatomic, strong) NSArray *internalConstraints;

@end

@implementation JJButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.imageView = [[UIImageView alloc] init];
        [self.imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.imageView];
        
        self.label = [[UILabel alloc] init];
        [self.label setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.label];
        
        [self updateUI];
    }

    return self;
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    [self updateUI];
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    [self updateUI];
}

- (void)setColor:(UIColor *)color
{
    _color = color;
    [self updateUI];
}

- (void)setHighlighted:(BOOL)highlighted
{
    super.highlighted = highlighted;
    self.backgroundColor = highlighted ? [self.color colorWithAlphaComponent:0.2] : [UIColor clearColor];
}

- (void)setEnabled:(BOOL)enabled
{
    super.enabled = enabled;
    [self updateUI];
}

- (void)updateUI
{
    UIColor *color = self.color ? self.color : [UIColor blackColor];
    self.alpha = self.enabled ? 1.0 : 0.4;
    
    self.layer.cornerRadius = 10;
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = 1;
    
    self.imageView.image = self.image;
    
    if (self.title)
    {
        UIFont *font = [UIFont boldAppFontOfSize:15];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        
        NSDictionary *attributes = @{ NSFontAttributeName: font,
                                      NSForegroundColorAttributeName: color,
                                      NSParagraphStyleAttributeName: paragraphStyle };
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:self.title attributes:attributes];
        
        self.label.attributedText = attributedString;
    }
    else
    {
        self.label.text = nil;
    }
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    if (self.internalConstraints)
    {
        [self removeConstraints:self.internalConstraints];
    }
    
    NSDictionary *views = @{ @"imageView": self.imageView,
                             @"label": self.label };
    
    NSMutableArray *constraints = [NSMutableArray array];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[imageView(==40)]-20-[label]-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    self.internalConstraints = [constraints copy];
    [self addConstraints:self.internalConstraints];
}


@end
