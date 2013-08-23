//
//  LAWebViewController.h
//  #LOSAL
//
//  Created by Joaquin Brown on 8/21/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LAWebViewController : UIViewController<UIWebViewDelegate>

@property (nonatomic, strong) NSURL *url;

@property (weak, nonatomic) IBOutlet UIWebView *webview;

@property (weak, nonatomic)NSString *titleName;

@property (weak, nonatomic) IBOutlet UINavigationItem *navyItem;

@end
