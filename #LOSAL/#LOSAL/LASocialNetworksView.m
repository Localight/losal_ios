//
//  LASocialNetworksView.m
//  #LOSAL
//
//  Created by Joaquin Brown on 8/13/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LASocialNetworksView.h"
#import <QuartzCore/QuartzCore.h>

CGPoint lastTouchLocation;
CGRect originalFrame;
BOOL isShown;

@implementation LASocialNetworksView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        originalFrame = frame;
        
        self.alpha = 0;
        self.backgroundColor = [UIColor blackColor];
        
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 20, frame.size.width, 20)];
        label.text = @"Activate your social networks";
        [label setBackgroundColor:[UIColor clearColor]];
        label.textAlignment = NSTextAlignmentCenter;
        [label setTextColor:[UIColor whiteColor]];
        [label setFont:[UIFont fontWithName:@"Roboto-Light" size:15]];
        [self addSubview:label];
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake(10, frame.size.height - 45, frame.size.width - 20, 35);
        [closeButton setTitle:@"Close" forState:UIControlStateNormal];
        [closeButton.titleLabel setFont:[UIFont fontWithName:@"Roboto-Light" size:15]];
        [closeButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
    }
    return self;
}

#pragma mark Custom alert methods

- (void)show
{
    NSLog(@"show");
    isShown = YES;
    self.transform = CGAffineTransformMakeScale(0.1, 0.1);
    self.alpha = 0;

    [UIView animateWithDuration:.2 animations:^{
        self.transform = CGAffineTransformMakeScale(1.1, 1.1);
        self.alpha = .85;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.1 animations:^{
            self.transform = CGAffineTransformMakeScale(1.0, 1.0);
        }];
        
    }];
}

- (void)hide
{
    NSLog(@"hide");
    isShown = NO;
    
    [UIView animateWithDuration:.2 animations:^{
        self.transform = CGAffineTransformMakeScale(0.1, 0.1);
        self.alpha = 0;
    }];
}

- (void)toggle
{
    if (isShown) {
        [self hide];
    } else {
        [self show];
    }
}

#pragma mark Touch methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    lastTouchLocation = [touch locationInView:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint newTouchLocation = [touch locationInView:self];
    CGRect currentFrame = self.frame;
    
    CGFloat deltaX = lastTouchLocation.x - newTouchLocation.x;
    CGFloat deltaY = lastTouchLocation.y - newTouchLocation.y;
    
    self.frame = CGRectMake(currentFrame.origin.x - deltaX, currentFrame.origin.y - deltaY, currentFrame.size.width, currentFrame.size.height);
    lastTouchLocation = [touch locationInView:self];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

@end
