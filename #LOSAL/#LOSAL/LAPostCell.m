//
//  LAPostCell.m
//  #LOSAL
//
//  Created by James Orion Hall on 8/6/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LAPostCell.h"

@implementation LAPostCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.icon setFont:[UIFont fontWithName:@"icomoon" size:30.0f]];
    [self.userNameLabel setFont:[UIFont fontWithName:@"Roboto-Light" size:15]];
    [self.messageArea setFont:[UIFont fontWithName:@"Roboto-Regular" size:15]];
    [self.dateAndGradeLabel setFont:[UIFont fontWithName:@"Roboto-Light" size:11]];
    [self.messageArea setTextColor:[UIColor whiteColor]];
}

@end
