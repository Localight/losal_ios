//
//  LALoginViewController.h
//  #LOSAL
//
//  Created by Joaquin Brown on 8/12/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LALoginViewControllerDelegate <NSObject>

- (void)wantsToCloseView;

@end

@interface LALoginViewController : UIViewController<UITextFieldDelegate>

@property (nonatomic, weak) id<LALoginViewControllerDelegate>delegate;
@property (nonatomic, copy) void (^dismissBlock)(void);

@end
