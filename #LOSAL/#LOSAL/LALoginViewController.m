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
#import <QuartzCore/QuartzCore.h>
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
//    [_validUserLabel setTextColor:[UIColor colorWithRed:0.251 green:0.78 blue:0.949 alpha:1]];
//    [_mobileNumberPrompt setTextColor:[UIColor colorWithRed:0.251 green:0.78 blue:0.949 alpha:1]];
//    [_phoneNumber setBackgroundColor:[UIColor colorWithRed:0.251 green:0.78 blue:0.949 alpha:1]];
    [[_phoneNumber layer]setBorderWidth:2];
    
    [[_phoneNumber layer]setBorderColor:[[UIColor colorWithRed:0.251 green:0.78 blue:0.949 alpha:1]CGColor]];
    
    [_phoneNumber setTextColor:[UIColor colorWithRed:0.251 green:0.78 blue:0.949 alpha:1]];
    [_verifyUserButton setBackgroundColor:[UIColor colorWithRed:0.251 green:0.78 blue:0.949 alpha:1]];
    [_retryButton setBackgroundColor:[UIColor colorWithRed:0.251 green:0.78 blue:0.949 alpha:1]];
    [_phoneNumber setValue:[UIColor colorWithRed:0.251 green:0.78 blue:0.949 alpha:1]
                forKeyPath:@"_placeholderLabel.textColor"];
    
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

    PFUser *user = [PFUser user];
    
    [self.storeManager verifyPhoneNumberIsValid:[_phoneNumber text] withCompletion:^(bool isValid) {
        if (isValid) {
            [_validUserLabel setText:@"Thanks! You will receive a text message from (562)-320-8034. Click the text link to complete the process."];
            [_mobileNumberPrompt setText:@"No text message? Email us and we'll see what the deal is, or click ""retry"" below. Otherwise click ""x"" in the right corner to close the screen."];
            self.phoneNumber.hidden = YES;
            [_verifyUserButton setHidden:YES];
            [_retryButton setHidden:NO];
            [self.storeManager sendRegistrationRequestForPhoneNumber:self.phoneNumber.text];
        }else{
            [_mobileNumberPrompt setText:@"Enter your mobile number"];
            
            [_validUserLabel setText:@"Oops! Did you miss the app registration? Your number wasn't recognized. Email us for access or retry below."];
            [_validUserLabel setHidden:YES];
            [_retryButton setHidden:NO];
            [_verifyUserButton setHidden:YES];
            [self.storeManager sendRegistrationRequestForPhoneNumber:[_phoneNumber text]];
        }
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_phoneNumber resignFirstResponder];
    return YES;
}
//- (IBAction)back:(id)sender {
//    
//    self.sendButton.hidden = NO;
//    self.phoneNumber.hidden = NO;
//    
//    self.backButton.hidden = YES;
//}

- (IBAction)backgroundTapped:(id)sender {
    [[self view]endEditing:YES];
}

- (void)loginWithPin:(NSString *)pin
{
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
