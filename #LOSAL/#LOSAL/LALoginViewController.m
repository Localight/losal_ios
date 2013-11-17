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
#import "KeychainItemWrapper.h"
#import <Security/Security.h>

@interface LALoginViewController ()

@property (strong, nonatomic) LAAppDelegate *appDelegate;

@property (weak) IBOutlet UIImageView *messageTouchImage;

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
    
//    [_validUserLabel setTextColor:[UIColor colorWithRed:0.251 green:0.78 blue:0.949 alpha:1]];
//    [_mobileNumberPrompt setTextColor:[UIColor colorWithRed:0.251 green:0.78 blue:0.949 alpha:1]];
//    [_phoneNumber setBackgroundColor:[UIColor colorWithRed:0.251 green:0.78 blue:0.949 alpha:1]];
    [[_phoneNumber layer]setBorderWidth:2];
    
    [[_phoneNumber layer]setBorderColor:[[UIColor colorWithRed:0.251 green:0.78 blue:0.949 alpha:1]CGColor]];
    
    [_phoneNumber setTextColor:[UIColor colorWithRed:0.251 green:0.78 blue:0.949 alpha:1]];
    [_verifyUserButton setBackgroundColor:[UIColor colorWithRed:0.251 green:0.78 blue:0.949 alpha:1]];
    [_phoneNumber setValue:[UIColor colorWithRed:0.251 green:0.78 blue:0.949 alpha:1]
                forKeyPath:@"_placeholderLabel.textColor"];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedDismissNotification:)
                                                 name:@"DissmisView"
                                               object:nil];

//    self.appDelegate = (LAAppDelegate *)[[UIApplication sharedApplication] delegate];
//    self.appDelegate.loginViewController = self;
}
//- (IBAction)skip:(id)sender {
//    [self dismiss];
//}

- (IBAction)closeButtonPressed:(id)sender
{
    [[self delegate]wantsToCloseView];
}

- (IBAction)verifyUser:(id)sender
{
    // clear the keyboard if necessary
    [self.phoneNumber resignFirstResponder];

    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:[_phoneNumber text]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        int count = 0;
        if ((!error) && (objects.count > 0))
        {
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
//          [[[LAStoreManager defaultStore]currentUser]setPhoneNumber:[_phoneNumber text]];
            [[LAStoreManager defaultStore]sendRegistrationRequestForPhoneNumber:[keychainItem objectForKey:(__bridge id)(kSecAttrAccount)]];
            NSLog(@"the next step");
            
            [[[LAStoreManager defaultStore]currentUser]setUserVerified:YES];
        }else{
            [_mobileNumberPrompt setText:@"Enter your mobile number"];
            
            [_validUserLabel setText:@"Oops! Did you miss the app registration? Your number wasn't recognized. Email us for access or retry below."];
            [_validUserLabel setTextColor:[UIColor colorWithRed:0.251 green:0.78 blue:0.949 alpha:1]];
            [_mobileNumberPrompt setTextColor:[UIColor whiteColor]];
            
            NSLog(@"did we get here?");
//            [_verifyUserButton setHidden:YES];
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
    //[[self presentingViewController] dismissViewControllerAnimated:YES completion:_dismissBlock];
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

- (IBAction)backgroundTapped:(id)sender{
    [[self view]endEditing:YES];
}

// come back to if we might need to fix or undo.
//- (void)loginWithPin:(NSString *)pin
//{
//    if ([[LAStoreManager sharedManager]loginWithPhoneNumber:[_phoneNumber text] pinNumber:pin])
//    {
//        [self dismiss];
//    }
//}

- (void)dismiss
{
    self.appDelegate.loginViewController = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)receivedDismissNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"DissmisView"])
    {
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
