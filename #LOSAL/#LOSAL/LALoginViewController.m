//
//  LALoginViewController.m
//  #LOSAL
//
//  Created by Joaquin Brown on 8/12/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LALoginViewController.h"
#import "LAStoreManager.h"

@interface LALoginViewController ()

@property (strong, nonatomic) LAStoreManager *storeManager;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *pinNumber;
- (IBAction)login:(id)sender;

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
    
}

- (IBAction)skip:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)login:(id)sender {
    
    if ([self.storeManager loginWithPhoneNumber:self.phoneNumber.text pinNumber:self.pinNumber.text]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
