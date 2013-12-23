//
//  JJJogTableViewCell.m
//  JogJournal
//
//  Created by Jamie McDaniel on 12/23/13.
//  Copyright (c) 2013 Curious Find. All rights reserved.
//

#import "JJJogTableViewCell.h"

@interface JJJogTableViewCell ()

@end

@implementation JJJogTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
