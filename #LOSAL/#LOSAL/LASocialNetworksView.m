//
//  LASocialNetworksView.m
//  #LOSAL
//
//  Created by Joaquin Brown on 8/13/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LASocialNetworksView.h"
#import <QuartzCore/QuartzCore.h>

@interface LASocialNetworksView () 

@property (nonatomic, strong) LASocialManager *socialManager;

- (void)instagram;

@end

@implementation LASocialNetworksView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.alpha = 0.5;
        self.backgroundColor = [UIColor colorWithRed:0.22f green:0.22f blue:0.22f alpha:1.00f];
        
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        
        // Get social manager
        self.socialManager = [LASocialManager sharedManager];
        self.socialManager.delegate = self;
        
        // Title Label
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(55, 25, 170, 20)];
        label.text = @"Connect Instagram";
        [label setBackgroundColor:[UIColor clearColor]];
        label.textAlignment = NSTextAlignmentCenter;
        [label setTextColor:[UIColor whiteColor]];
        [label setFont:[UIFont fontWithName:@"RobotoSlab-Regular" size:15]];
        [self addSubview:label];
        
        // Instagram icon
        UIImageView *instagramIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"instagramSocialLink"]];
        CGSize instagramIconSize = CGSizeMake(46, 46);
        instagramIcon.frame = CGRectMake(frame.size.width/2 - instagramIconSize.width/2, 53, instagramIconSize.width, instagramIconSize.height);
        [self addSubview:instagramIcon];
        
        // bounding box tap button for Instagram label + logo
        UIButton *boundingBox = [UIButton buttonWithType:UIButtonTypeCustom];
        boundingBox.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, label.frame.size.width, 80);
        [boundingBox setBackgroundColor:[UIColor clearColor]];
        [boundingBox addTarget:self action:@selector(instagram) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:boundingBox];
        
        // Blue line
        UIView *blueLine = [[UIView alloc] initWithFrame:CGRectMake(40, 110, frame.size.width-80, 1)];
        [blueLine setBackgroundColor:[UIColor colorWithRed:0.20f green:0.71f blue:0.90f alpha:1.00f]];
        [self addSubview:blueLine];
        
        // Privacy note
        UITextView *privacyView = [[UITextView alloc] initWithFrame:CGRectMake(30, 115, frame.size.width-60, 60)];
        [privacyView setText:@"The #LOSAL APP uses Localism! to protect your privacy and unite our community. Your private information is not shared."];
        [privacyView setBackgroundColor:[UIColor clearColor]];
        [privacyView setTextAlignment:NSTextAlignmentCenter];
        [privacyView setTextColor:[UIColor whiteColor]];
        [privacyView setFont:[UIFont fontWithName:@"Roboto-Light" size:10]];
        [privacyView setEditable:NO];
        [self addSubview:privacyView];
        
        // Close button
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake(frame.size.width - 35, 10, 25, 25);
        [closeButton setBackgroundImage:[UIImage imageNamed:@"183_x-circle"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        
        // Localism logo
        UIImageView *localismLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"localism-wht-smaller"]];
        CGSize localismLogoSize = CGSizeMake(150, 49);
        localismLogo.frame = CGRectMake(frame.size.width/2 - localismLogoSize.width/2, 180, localismLogoSize.width, localismLogoSize.height);
        [self addSubview:localismLogo];
    }
    return self;
}

#pragma UI Methods
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

#pragma INSTAGRAM
- (void)instagram
{
    if ([self.socialManager instagramSessionIsValid]) {
        [self.socialManager instagramLogout];
    } else {
        [self.socialManager instagramLogin];
    }
}

#pragma INSTAGRAM Delegates
- (void)instagramDidLogin
{
    // we've successfully paired with Instagram, hide this view & report success
    [self hide];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Connected to Instagram"
                                                        message:@"You've successfully connected #LOSAL to Instagram."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)instagramDidLogout
{
    // note: we're not currently handling Instagram logouts anywhere
}

- (void)instagramDidLoad:(id)result
{
    NSLog(@"Received result %@", result);
}

- (void)instagramDidReceiveAnError
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Instagram Failure"
                                                        message:@"Failed to connect #LOSAL to Instagram."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

@end
