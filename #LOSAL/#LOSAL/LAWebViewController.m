//
//  LAWebViewController.m
//  #LOSAL
//
//  Created by Joaquin Brown on 8/21/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LAWebViewController.h"
#import "ECSlidingViewController.h"
#import "LAMenuViewController.h"

@interface LAWebViewController ()

@end

@implementation LAWebViewController

- (id)init{
    self = [super init];
    if (self) {
        UINavigationItem *n = [self navigationItem];
        [n setTitle:_name];
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
     
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[LAMenuViewController class]]) {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
    [[self webview]setDelegate:self];
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:_url];
    [[self webview]loadRequest:requestURL];
    
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[LAMenuViewController class]]) {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
    
    NSLog(@"url is %@", [self.url absoluteString]);
}

- (IBAction)back:(id)sender {
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
