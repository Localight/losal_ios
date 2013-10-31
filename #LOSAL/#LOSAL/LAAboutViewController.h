//
//  LAAboutViewController.h
//  #LOSAL
//
//  Created by James Orion Hall on 8/28/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LAAboutViewController : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UINavigationItem *navyItem;
@property (strong, nonatomic) IBOutlet UIWebView *webView;

- (IBAction)ReVerify:(id)sender;
@end
