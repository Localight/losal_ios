//
//  LASocialNetworksView.h
//  #LOSAL
//
//  Created by Joaquin Brown on 8/13/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LASocialManager.h"

@interface LASocialNetworksView : UIView <LASocialManagerDelegate>

- (void)show;
- (void)hide;

@end
