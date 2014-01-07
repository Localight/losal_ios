//
//  LACalendarSyncView.m
//  #LOSAL
//
//  Created by Justin Schottlaender on 12/3/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LACalendarSyncView.h"
#import <QuartzCore/QuartzCore.h>

@implementation LACalendarSyncView

- (id)initWithFrame:(CGRect)frame loginSuccess:(BOOL)loginSuccess
{
    self = [super initWithFrame:frame];
    if (self) {
        self.alpha = 0.5;
        self.backgroundColor = [UIColor colorWithRed:0.22f green:0.22f blue:0.22f alpha:1.00f];
        
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;

        if (loginSuccess) {
            // title label
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(55, 25, 170, 20)];
            label.text = @"Success!";
            [label setBackgroundColor:[UIColor clearColor]];
            label.textAlignment = NSTextAlignmentCenter;
            [label setTextColor:[UIColor whiteColor]];
            [label setFont:[UIFont fontWithName:@"RobotoSlab-Light" size:26]];
            [self addSubview:label];
        }

        // calendar icon
        UIImageView *calendarIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"calendar-blue-dot"]];
        CGSize calendarIconSize = CGSizeMake(80, 74);
        calendarIcon.frame = CGRectMake(frame.size.width/2 - calendarIconSize.width/2, 60, calendarIconSize.width, calendarIconSize.height);
        [self addSubview:calendarIcon];
        
        // main text
        UITextView *mainTextView = [[UITextView alloc] initWithFrame:CGRectMake(30, 140, frame.size.width-60, 90)];
        [mainTextView setText:@"Now sync major school events with your Calendar."];
        [mainTextView setBackgroundColor:[UIColor clearColor]];
        [mainTextView setTextAlignment:NSTextAlignmentCenter];
        [mainTextView setTextColor:[UIColor whiteColor]];
        [mainTextView setFont:[UIFont fontWithName:@"RobotoSlab-Light" size:20]];
        [mainTextView setEditable:NO];
        [self addSubview:mainTextView];

        // Sync Calendar button
        UIButton *syncButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [syncButton setTitle:@"Sync Calendar" forState:UIControlStateNormal];
        CGSize syncButtonSize = CGSizeMake(150, 32);
        syncButton.frame = CGRectMake(frame.size.width/2 - syncButtonSize.width/2, 245, syncButtonSize.width, syncButtonSize.height);
        [syncButton setBackgroundColor:[UIColor colorWithRed:0.251 green:0.78 blue:0.949 alpha:1]];
        [syncButton.titleLabel setFont:[UIFont fontWithName:@"RobotoSlab-Regular" size:20]];
        [syncButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        syncButton.layer.cornerRadius = 5;
        [syncButton addTarget:self action:@selector(syncCalendar) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:syncButton];
        
        // bottom text
        UITextView *bottomTextView = [[UITextView alloc] initWithFrame:CGRectMake(60, 290, 160, 50)];
        [bottomTextView setText:@"This will display school-wide events on your calendar app."];
        [bottomTextView setBackgroundColor:[UIColor clearColor]];
        [bottomTextView setTextAlignment:NSTextAlignmentCenter];
        [bottomTextView setTextColor:[UIColor whiteColor]];
        [bottomTextView setFont:[UIFont fontWithName:@"RobotoSlab-Light" size:10]];
        [bottomTextView setEditable:NO];
        [self addSubview:bottomTextView];
        
        // close button
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake(frame.size.width - 35, 10, 25, 25);
        [closeButton setBackgroundImage:[UIImage imageNamed:@"183_x-circle"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
    }
    return self;
}

- (void)syncCalendar
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"webcal://losal.tandemcal.com/index.php?type=export&action=ical&export_type=now_to_infinity&schools=6&activities=15&limit=none&date_start=2013-12-03&page=2"]];
    
    [self hide];
}

- (void)show
{
    self.transform = CGAffineTransformMakeScale(0.1, 0.1);
    self.alpha = 0;
    
    [UIView animateWithDuration:.3 animations:^{
        self.transform = CGAffineTransformMakeScale(1.1, 1.1);
        self.alpha = .9;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.1 animations:^{
            self.transform = CGAffineTransformMakeScale(1.0, 1.0);
        }];
        
    }];
}

- (void)hide
{
    [UIView animateWithDuration:.4 animations:^{
        self.transform = CGAffineTransformMakeScale(0.1, 0.1);
        self.alpha = 0;
    }];
}

@end
