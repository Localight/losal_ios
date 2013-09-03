//
//  LAIntroVerifyViewController.h
//  #LOSAL
//
//  Created by Jeffrey Algera on 9/3/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LAIntroVerifyViewControllerDelegate <NSObject>

- (void)wantsToCloseView;

@end

@interface LAIntroVerifyViewController : UIViewController

@property (nonatomic, weak) id<LAIntroVerifyViewControllerDelegate>delegate;

@end
