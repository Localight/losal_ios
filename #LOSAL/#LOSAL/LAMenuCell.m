//
//  LAMenuCell.m
//  #LOSAL
//
//  Created by James Orion Hall on 8/19/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LAMenuCell.h"

@implementation LAMenuCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
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
