//
//  LASocialNetworksView.h
//  #LOSAL
//
//  Created by Joaquin Brown on 8/13/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LASocialManager.h"

typedef enum SocialNetworkType : NSInteger {
    SocialNetwork_Instagram,
    SocialNetwork_Twitter
} SocialNetworkType;

@interface LASocialNetworksView : UIView <LASocialManagerDelegate>

- (id)initWithFrame:(CGRect)frame socialNetworkType:(SocialNetworkType)socialNetworkType;

- (void)show;
- (void)hide;

@end
