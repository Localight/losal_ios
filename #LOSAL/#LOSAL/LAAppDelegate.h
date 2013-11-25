//
//  LAAppDelegate.h
//  #LOSAL
//
//  Created by James Orion Hall on 7/27/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LALoginViewController.h"

@interface LAAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) LALoginViewController *loginViewController;

@end