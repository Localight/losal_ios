//
//  LAIntroVerifyViewController.m
//  #LOSAL
//
//  Created by Jeffrey Algera on 9/3/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LAIntroVerifyViewController.h"

@interface LAIntroVerifyViewController ()

- (IBAction)closeButtonPressed:(id)sender;

@end

@implementation LAIntroVerifyViewController

- (IBAction)closeButtonPressed:(id)sender
{
    [self.delegate wantsToCloseView];
}

- (void)dealloc
{
    self.delegate = nil;
}

@end
