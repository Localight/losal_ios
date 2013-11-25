//
//  LASocialNetworksView.m
//  #LOSAL
//
//  Created by Joaquin Brown on 8/13/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LASocialNetworksView.h"

@interface LASocialNetworksView () 

@property (nonatomic, strong) LASocialManager *socialManager;
@property SocialNetworkType socialNetwork;

@end

@implementation LASocialNetworksView

- (id)initWithFrame:(CGRect)frame socialNetworkType:(SocialNetworkType)socialNetworkType
{
    self = [super initWithFrame:frame];
    if (self) {
        self.socialNetwork = socialNetworkType;
        
        self.alpha = 0.5;
        self.backgroundColor = [UIColor colorWithRed:0.22f green:0.22f blue:0.22f alpha:1.00f];
        
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        
        // Get social manager
        self.socialManager = [LASocialManager sharedManager];
        self.socialManager.delegate = self;
        
        NSString *socialTitle = nil;
        NSString *socialIconFileName = nil;
        
        if (self.socialNetwork == SocialNetwork_Instagram) {
            socialTitle = @"Connect Instagram";
            socialIconFileName = @"instagramSocialLink";
        }
        else if (self.socialNetwork == SocialNetwork_Twitter) {
            socialTitle = @"Connect Twitter";
            socialIconFileName = @"twitterSocialLink";
        }
        
        // title Label
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(55, 25, 170, 20)];
        label.text = socialTitle;
        [label setBackgroundColor:[UIColor clearColor]];
        label.textAlignment = NSTextAlignmentCenter;
        [label setTextColor:[UIColor whiteColor]];
        [label setFont:[UIFont fontWithName:@"RobotoSlab-Regular" size:15]];
        [self addSubview:label];
        
        // social icon
        UIImageView *socialIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:socialIconFileName]];
        CGSize socialIconSize = CGSizeMake(46, 46);
        socialIcon.frame = CGRectMake(frame.size.width/2 - socialIconSize.width/2, 53, socialIconSize.width, socialIconSize.height);
        [self addSubview:socialIcon];
        
        // bounding box tap button for social label + logo
        UIButton *boundingBox = [UIButton buttonWithType:UIButtonTypeCustom];
        boundingBox.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, label.frame.size.width, 80);
        [boundingBox setBackgroundColor:[UIColor clearColor]];
        [boundingBox addTarget:self action:@selector(linkWithSocialService) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:boundingBox];
        
        // blue line
        UIView *blueLine = [[UIView alloc] initWithFrame:CGRectMake(40, 110, frame.size.width-80, 1)];
        [blueLine setBackgroundColor:[UIColor colorWithRed:0.20f green:0.71f blue:0.90f alpha:1.00f]];
        [self addSubview:blueLine];
        
        // privacy note
        UITextView *privacyView = [[UITextView alloc] initWithFrame:CGRectMake(30, 115, frame.size.width-60, 60)];
        [privacyView setText:@"The #LOSAL APP uses Localism! to protect your privacy and unite our community. Your private information is not shared."];
        [privacyView setBackgroundColor:[UIColor clearColor]];
        [privacyView setTextAlignment:NSTextAlignmentCenter];
        [privacyView setTextColor:[UIColor whiteColor]];
        [privacyView setFont:[UIFont fontWithName:@"Roboto-Light" size:10]];
        [privacyView setEditable:NO];
        [self addSubview:privacyView];
        
        // close button
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

- (void)linkWithSocialService
{
    if (self.socialNetwork == SocialNetwork_Instagram)
        [self linkInstagram];
    else if (self.socialNetwork == SocialNetwork_Twitter)
        [self linkTwitter];
}

#pragma mark UI Methods
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

- (void)linkInstagram
{
    if ([self.socialManager instagramSessionIsValid])
        [self.socialManager instagramLogout];
    else
        [self.socialManager instagramLogin];
}

- (void)linkTwitter
{
    if ([self.socialManager twitterSessionIsValid])
        [self.socialManager twitterLogout];
    else
        [self.socialManager twitterLogin];
}

#pragma mark Instagram Delegate Methods
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

#pragma mark Twitter Delegate Methods
- (void)twitterDidLogin
{
    // we've successfully paired with Twitter, hide this view & report success
    [self hide];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Connected to Twitter"
                                                        message:@"You've successfully connected #LOSAL to Twitter."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)twitterDidLogout
{
    // note: we're not currently handling Twitter logouts anywhere
}

- (void)twitterDidReceiveAnError:(NSString *)errorMessage
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Twitter Failure"
                                                        message:errorMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

@end
