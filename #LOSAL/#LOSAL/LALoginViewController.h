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

@property (weak, nonatomic) IBOutlet UILabel *validUserLabel;
@property (weak, nonatomic) IBOutlet UILabel *mobileNumberPrompt;

@property (nonatomic, weak) id<LALoginViewControllerDelegate>delegate;
@property (weak, nonatomic) IBOutlet UIButton *retryButton;
@property (weak, nonatomic) IBOutlet UIButton *verifyUserButton;

@property (weak, nonatomic) IBOutlet UITextField *phoneNumber;

- (IBAction)closeButtonPressed:(id)sender;
- (IBAction)verifyUser:(id)sender;

- (IBAction)backgroundTapped:(id)sender;

//- (void)loginWithPin:(NSString *)pin;

@end
