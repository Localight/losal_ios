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
@interface LALoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *validUserLabel;

@property (weak, nonatomic) IBOutlet UILabel *paragraph3;

@property (weak, nonatomic) IBOutlet UILabel *field1;

@property (nonatomic, weak) id<LALoginViewControllerDelegate>delegate;
@property (weak, nonatomic) IBOutlet UIButton *retryButton;
@property (weak, nonatomic) IBOutlet UIButton *verifyUserButton;

- (void)loginWithPin:(NSString *)pin;

@end
