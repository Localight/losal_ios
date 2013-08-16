//
//  LASocialNetworksView.m
//  #LOSAL
//
//  Created by Joaquin Brown on 8/13/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LASocialNetworksView.h"
#import <QuartzCore/QuartzCore.h>
#import "LASocialManager.h"

@interface LASocialNetworksView () 

@property (nonatomic, strong) LASocialManager *socialManager;
@property (nonatomic, strong) UIButton *twitterButton;
@property (nonatomic, strong) UIButton *facebookButton;
@property (nonatomic, strong) UIButton *instagramButton;

- (void)twitter;
- (void)facebook;
- (void)instagram;

@end

@implementation LASocialNetworksView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.alpha = 0;
        self.backgroundColor = [UIColor blackColor];
        
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        
        // Get social manager
        self.socialManager = [LASocialManager sharedManager];
        self.socialManager.delegate = self;
        
        // Title Label
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, frame.size.width-40, 20)];
        label.text = @"Activate your social networks";
        [label setBackgroundColor:[UIColor clearColor]];
        label.textAlignment = NSTextAlignmentCenter;
        [label setTextColor:[UIColor whiteColor]];
        [label setFont:[UIFont fontWithName:@"Roboto-Light" size:15]];
        [self addSubview:label];
        
        // Blue line 1
        UIView *blueLine1 = [[UIView alloc] initWithFrame:CGRectMake(40, 40, frame.size.width-80, 1)];
        [blueLine1 setBackgroundColor:[UIColor blueColor]];
        [self addSubview:blueLine1];
        
        // Twitter
        self.twitterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.twitterButton.frame = CGRectMake(frame.size.width/2, 50, frame.size.width/2 - 20, 40);
        [self.twitterButton setTitle:@"Twitter" forState:UIControlStateNormal];
        [self.twitterButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [self setButton:self.twitterButton active:[self.socialManager twitterSessionIsValid]];
        [self.twitterButton.titleLabel setFont:[UIFont fontWithName:@"Roboto-Light" size:17]];
        [self.twitterButton addTarget:self action:@selector(twitter) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.twitterButton];
        
        // Facebook
        self.facebookButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.facebookButton.frame = CGRectMake(frame.size.width/2, 110, frame.size.width/2 - 20, 40);
        [self.facebookButton setTitle:@"Facebook" forState:UIControlStateNormal];
        [self.facebookButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [self setButton:self.facebookButton active:[self.socialManager facebookSessionIsValid]];
        [self.facebookButton.titleLabel setFont:[UIFont fontWithName:@"Roboto-Light" size:17]];
        [self.facebookButton addTarget:self action:@selector(facebook) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.facebookButton];
        
        // Instagramr
        self.instagramButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.instagramButton.frame = CGRectMake(frame.size.width/2, 170, frame.size.width/2 - 20, 40);
        [self.instagramButton setTitle:@"Instagram" forState:UIControlStateNormal];
        [self.instagramButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [self setButton:self.instagramButton active:[self.socialManager instagramSessionIsValid]];
        [self.instagramButton.titleLabel setFont:[UIFont fontWithName:@"Roboto-Light" size:17]];
        [self.instagramButton addTarget:self action:@selector(instagram) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.instagramButton];
        
        // Blue line 2
        UIView *blueLine2 = [[UIView alloc] initWithFrame:CGRectMake(40, 230, frame.size.width-80, 1)];
        [blueLine2 setBackgroundColor:[UIColor blueColor]];
        [self addSubview:blueLine2];
        
        // Privacy note
        UITextView *privacyView = [[UITextView alloc] initWithFrame:CGRectMake(30, 240, frame.size.width-60, 60)];
        [privacyView setText:@"The #LOSAL APP uses Localism! to protect your privacy and unite our community. Your private information is not shared."];
        [privacyView setBackgroundColor:[UIColor clearColor]];
        [privacyView setTextAlignment:NSTextAlignmentCenter];
        [privacyView setTextColor:[UIColor grayColor]];
        [privacyView setFont:[UIFont fontWithName:@"Roboto-Light" size:10]];
        [privacyView setEditable:NO];
        [self addSubview:privacyView];
        
        // Close button
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake(10, 310, frame.size.width - 20, 35);
        [closeButton setTitle:@"Close" forState:UIControlStateNormal];
        [closeButton.titleLabel setFont:[UIFont fontWithName:@"Roboto-Light" size:15]];
        [closeButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        
    }
    return self;
}

#pragma UI Methods
- (void)show
{
    NSLog(@"show");
    self.transform = CGAffineTransformMakeScale(0.1, 0.1);
    self.alpha = 0;
    
    [self.socialManager twitterLogin];
    [self.socialManager facebookLogin];
    
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
    NSLog(@"hide");
    
    [UIView animateWithDuration:.4 animations:^{
        self.transform = CGAffineTransformMakeScale(0.1, 0.1);
        self.alpha = 0;
    }];
}
- (void)setButton:(UIButton *)button active:(BOOL)active {
    dispatch_queue_t callerQueue = dispatch_get_main_queue();
    dispatch_async(callerQueue, ^{
        if (active) {
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        } else {
            [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        }
    });
}

- (void)displayAlertMessage:(NSString *)alertMessage {
    dispatch_queue_t callerQueue = dispatch_get_main_queue();
    dispatch_async(callerQueue, ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                     message:alertMessage
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [alertView show];
    });
}

#pragma TWITTER
- (void)twitter {
    if ([self.socialManager twitterSessionIsValid]) {
        [self.socialManager twitterLogout];
    } else {
        [self.socialManager twitterLogin];
    }
}

#pragma TWITTER Delegates
- (void)twitterDidLogin {
    [self setButton:self.twitterButton active:YES];
}

- (void)twitterDidLogout {
    [self setButton:self.twitterButton active:NO];
}
- (void)twitterDidReceiveAnError:(NSString *)errorMessage {
    [self displayAlertMessage:errorMessage];
}

#pragma FACEBOOK
- (void)facebook {
    if ([self.socialManager facebookSessionIsValid]) {
        [self.socialManager facebookLogout];
    } else {
        [self.socialManager facebookLogin];
    }
}

#pragma FACEBOOK Delegates
- (void)facebookDidLogin {
    [self setButton:self.facebookButton active:YES];
}

- (void)facebookDidLogout {
    [self setButton:self.facebookButton active:NO];
}
- (void)facebookDidReceiveAnError {
    [self displayAlertMessage:@"Please go to settings and create a facebook account."];
}


#pragma INSTAGRAM
- (void)instagram {
    if ([self.socialManager instagramSessionIsValid]) {
        [self.socialManager instagramLogout];
    } else {
        [self.socialManager instagramLogin];
    }
}
#pragma INSTAGRAM Delegates
- (void)instagramDidLogin {
    [self setButton:self.instagramButton active:YES];
}
- (void)instagramDidLogout {
    [self setButton:self.instagramButton active:NO];
}
- (void)instagramDidLoad:(id)result {
    NSLog(@"Received restul %@", result);
}
- (void)instagramDidReceiveAnError {
    [self displayAlertMessage:@"Something went wrong. Press OK and retry to try again."];
}

@end
