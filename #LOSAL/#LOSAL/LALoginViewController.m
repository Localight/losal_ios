//
//  LALoginViewController.m
//  #LOSAL
//
//  Created by Joaquin Brown on 8/12/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LALoginViewController.h"
#import "LAStoreManager.h"
#import "LAAppDelegate.h"
#import "LAIntroOverviewViewController.h"
@interface LALoginViewController ()

@property (strong, nonatomic) LAStoreManager *storeManager;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumber;
@property (strong, nonatomic) LAAppDelegate *appDelegate;
- (IBAction)closeButtonPressed:(id)sender;
- (IBAction)send:(id)sender;
@end

@implementation LALoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_retryButton setHidden:YES];
    [_paragraph3 setHidden:YES];
    [_field1 setHidden:YES];
    self.storeManager = [LAStoreManager sharedManager];
    
    self.appDelegate = (LAAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.appDelegate.loginViewController = self;
}

//- (IBAction)skip:(id)sender {
//    [self dismiss];
//}

- (IBAction)closeButtonPressed:(id)sender
{
    [self.delegate wantsToCloseView];
}

- (IBAction)send:(id)sender {

    [self.storeManager verifyPhoneNumberIsValid:[_phoneNumber text] withCompletion:^(bool isValid) {
        if (isValid) {
            
            self.phoneNumber.hidden = YES;
            [self.storeManager sendRegistrationRequestForPhoneNumber:self.phoneNumber.text];
        }else{
            [_validUserLabel setHidden:YES];
            [_retryButton setHidden:NO];
            [_verifyUserButton setHidden:YES];
            [self.storeManager sendRegistrationRequestForPhoneNumber:[_phoneNumber text]];
        }
    }];
}

//- (IBAction)back:(id)sender {
//    
//    self.sendButton.hidden = NO;
//    self.phoneNumber.hidden = NO;
//    
//    self.backButton.hidden = YES;
//}

- (void)loginWithPin:(NSString *)pin {
    if ([self.storeManager loginWithPhoneNumber:self.phoneNumber.text pinNumber:pin]) {
        [self dismiss];
    }
}

- (void)dismiss {
    self.appDelegate.loginViewController = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)dealloc
{
    self.delegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
