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
#import "KeychainItemWrapper.h"
#import <QuartzCore/QuartzCore.h>

@interface LALoginViewController ()

@property (strong, nonatomic) LAAppDelegate *appDelegate;

@property (weak) IBOutlet UIImageView *messageTouchImage;
@property (weak, nonatomic) IBOutlet UILabel *validUserLabel;
@property (weak, nonatomic) IBOutlet UILabel *mobileNumberPrompt;
@property (weak, nonatomic) IBOutlet UIButton *verifyUserButton;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumber;

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
    
    [[_phoneNumber layer] setBorderWidth:2];
    [[_phoneNumber layer] setBorderColor:[[UIColor colorWithRed:0.251 green:0.78 blue:0.949 alpha:1]CGColor]];
    [_phoneNumber setTextColor:[UIColor colorWithRed:0.251 green:0.78 blue:0.949 alpha:1]];
    [_phoneNumber setValue:[UIColor colorWithRed:0.251 green:0.78 blue:0.949 alpha:1] forKeyPath:@"_placeholderLabel.textColor"];
    
    [_verifyUserButton setBackgroundColor:[UIColor colorWithRed:0.251 green:0.78 blue:0.949 alpha:1]];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedDismissNotification:)
                                                 name:@"loggedInDismiss"
                                               object:nil];
}

- (IBAction)closeButtonPressed:(id)sender
{
    [self.delegate wantsToCloseView];
}

- (IBAction)verifyUser:(id)sender
{
    // clear the keyboard if necessary
    [self.phoneNumber resignFirstResponder];

    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:[_phoneNumber text]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        int count = 0;
        if ((!error) && (objects.count > 0)) {
            KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"YourAppLogin"
                                                                                    accessGroup:nil];
            
            [keychainItem setObject:[_phoneNumber text] forKey:(__bridge id)(kSecAttrAccount)];
            
            [[_verifyUserButton titleLabel]setText:@"Retry"];
            
            // change the Retry button appearance to appear disabled
            [_verifyUserButton setBackgroundColor:[UIColor colorWithRed:0.25f green:0.24f blue:0.24f alpha:1.00f]];
            [_verifyUserButton.titleLabel setTextColor:[UIColor colorWithRed:0.95f green:0.95f blue:0.95f alpha:1.00f]];
            
            [_messageTouchImage setHidden:NO];
            
            NSLog(@"This user has a number in the DataBase");
            
            [_validUserLabel setText:@"Thanks! You will receive a text message from (562)-320-8034. Click the text link to complete the process."];\
            [_validUserLabel setTextColor:[UIColor colorWithRed:0.251 green:0.78 blue:0.949 alpha:1]];
            [_mobileNumberPrompt setText:@"No text message? Email us or click ""retry"" below. Otherwise click ""x"" in the right corner to close the screen."];
            [_mobileNumberPrompt setTextColor:[UIColor whiteColor]];

            [[LAStoreManager defaultStore]sendRegistrationRequestForPhoneNumber:[keychainItem objectForKey:(__bridge id)(kSecAttrAccount)]];
            [[[LAStoreManager defaultStore]currentUser]setUserVerified:YES];
        }
        else {
            [_mobileNumberPrompt setText:@"Enter your mobile number"];
            
            [_validUserLabel setText:@"Oops! Did you miss the app registration? Your number wasn't recognized. Email us for access or retry below."];
            [_validUserLabel setTextColor:[UIColor colorWithRed:0.251 green:0.78 blue:0.949 alpha:1]];
            [_mobileNumberPrompt setTextColor:[UIColor whiteColor]];
            
            while (count > 2) {
                count ++;
                [self verifyUser:sender];
            }
            
            [[[LAStoreManager defaultStore]currentUser]setUserVerified:NO];
            
            // see if this failed phone number exists in the FailedLogin table already
            PFQuery *failedLoginQuery = [PFQuery queryWithClassName:@"FailedLogin"];
            [failedLoginQuery whereKey:@"phoneNumber" equalTo:_phoneNumber.text];
            
            [failedLoginQuery findObjectsInBackgroundWithBlock:^(NSArray *failedLogins, NSError *failedLoginError) {
                if (failedLogins.count == 0) {
                    // this is a new phone number, so commit the failed phone number to the database table
                    PFObject *failedLogin = [PFObject objectWithClassName:@"FailedLogin"];
                    [failedLogin setObject:_phoneNumber.text forKey:@"phoneNumber"];
                    [failedLogin saveEventually];
                }
            }];
            
            NSLog(@"This user does not have a number in the DataBase and the error is: %@, %@", error, [error userInfo]);
         }
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_phoneNumber resignFirstResponder];
    return YES;
}

- (IBAction)backgroundTapped:(id)sender
{
    [[self view]endEditing:YES];
}

- (void)receivedDismissNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"loggedInDismiss"]) {
        [self.delegate wantsToCloseView];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
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
