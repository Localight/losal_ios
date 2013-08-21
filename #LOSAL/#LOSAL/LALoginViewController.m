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

@interface LALoginViewController ()

@property (strong, nonatomic) LAStoreManager *storeManager;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumber;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) LAAppDelegate *appDelegate;
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
	
    self.storeManager = [LAStoreManager sharedManager];
    
    self.appDelegate = (LAAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.appDelegate.loginViewController = self;
}

- (IBAction)skip:(id)sender {
    [self dismiss];
}

- (IBAction)send:(id)sender {

    [self.storeManager verifyPhoneNumberIsValid:self.phoneNumber.text withCompletion:^(bool isValid) {
        if (isValid) {
            self.sendButton.hidden = YES;
            self.phoneNumber.hidden = YES;
            
            self.backButton.hidden = NO;
            
            [self.storeManager sendRegistrationRequestForPhoneNumber:self.phoneNumber.text];
        }
    }];
}

- (IBAction)back:(id)sender {
    
    self.sendButton.hidden = NO;
    self.phoneNumber.hidden = NO;
    
    self.backButton.hidden = YES;
}

- (void)loginWithPin:(NSString *)pin {
    if ([self.storeManager loginWithPhoneNumber:self.phoneNumber.text pinNumber:pin]) {
        [self dismiss];
    }
}

- (void)dismiss {
    self.appDelegate.loginViewController = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
