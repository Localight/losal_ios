//
//  LAAboutViewController.m
//  #LOSAL
//
//  Created by James Orion Hall on 8/28/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LAAboutViewController.h"
#import "ECSlidingViewController.h"
#import "LAMenuViewController.h"
#import "LANoticeViewController.h"
#import "LAStoreManager.h"
@interface LAAboutViewController ()

@end

@implementation LAAboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)revealNotices:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECLeft];
}
- (IBAction)back:(id)sender {
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self navyItem]setTitle:@"About"];
    
    [_paragraph1 setFont:[UIFont fontWithName:@"Roboto-Regular" size:14]];
    [_paragraph2 setFont:[UIFont fontWithName:@"Roboto-Regular" size:14]];
    [_paragraph3 setFont:[UIFont fontWithName:@"Roboto-Regular" size:14]];
    [_paragraph4 setFont:[UIFont fontWithName:@"Roboto-Regular" size:14]];
    [_paragraph5 setFont:[UIFont fontWithName:@"Roboto-Regular" size:14]];
    
    [_labelSuggestFeature setFont:[UIFont fontWithName:@"Roboto-Bold" size:16]];
    [_helpLabel setFont:[UIFont fontWithName:@"Roboto-Bold" size:16]];
    [_SafetySecurityLabel setFont:[UIFont fontWithName:@"Roboto-Bold" size:16]];
    [_faqLabel setFont:[UIFont fontWithName:@"Roboto-Bold" size:16]];
    [_copywriteLabel setFont:[UIFont fontWithName:@"Roboto-Bold" size:16]];

    
    UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(0, 0, 30, 30);
    [menuBtn setBackgroundImage:[UIImage imageNamed:@"menu-icon.png"] forState:UIControlStateNormal];
    [menuBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
    [_navyItem setLeftBarButtonItem:[[UIBarButtonItem alloc]initWithCustomView:menuBtn]];
    
    UIButton *noticeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    noticeBtn.frame = CGRectMake(0, 0, 27, 27);
    [noticeBtn setBackgroundImage:[UIImage imageNamed:@"lightning.png"] forState:UIControlStateNormal];
    [noticeBtn addTarget:self action:@selector(revealNotices:) forControlEvents:UIControlEventTouchUpInside];
    
    [_navyItem setRightBarButtonItem:[[UIBarButtonItem alloc]initWithCustomView:noticeBtn]];
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[LAMenuViewController class]]) {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
    
    if (![self.slidingViewController.underRightViewController isKindOfClass:[LANoticeViewController class]]) {
        self.slidingViewController.underRightViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Notices"];
    }
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)ReVerify:(id)sender{
    //PFUser *currentUser = [PFUser currentUser];
    // if user wants to enter phone number
    if (![[[LAStoreManager defaultStore]currentUser]userVerified])// if the user is not logged in.
    {
        UIAlertView *prompt = [[UIAlertView alloc]initWithTitle:@"Request for Text Message"
                                                        message:@"Would you like to re-enter your phone number and have the text message sent to you again? Please enter your phone number below or click NO to leave this screen."
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
        
        [prompt setAlertViewStyle:UIAlertViewStylePlainTextInput];
        UITextField *myTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
        [myTextField setBackgroundColor:[UIColor whiteColor]];
        [prompt addSubview:myTextField];
        CGAffineTransform myTransform = CGAffineTransformMakeTranslation(0.0, 130.0);
        [prompt setTransform:myTransform];
        [prompt show];
  
        [[LAStoreManager defaultStore]sendRegistrationRequestForPhoneNumber:[myTextField text]];

        
        //        // show the signup or login scren
        //        UIAlertView *prompt = [[UIAlertView alloc]initWithTitle:@"Oops!" message:@"You are already Validated. Would you like to reValidate and the text message send agai?" delegate:nil cancelButtonTitle:@"Yes" otherButtonTitles:"No", ];
    } else {
        UIAlertView *prompt = [[UIAlertView alloc]initWithTitle:@"Oops!"
                                                        message:@"It looks like you are already Verified and logged In."                                                        delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [prompt show];
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
        NSString *number = [[alertView textFieldAtIndex:0]text];
        NSLog(@"%@",number);
        [[[LAStoreManager defaultStore]currentUser]setPhoneNumber:number];
        [[LAStoreManager defaultStore]sendRegistrationRequestForPhoneNumber:number];
        // name contains the entered value
}
@end
