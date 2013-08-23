//
//  LAAppDelegate.m
//  #LOSAL
//
//  Created by James Orion Hall on 7/27/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LAAppDelegate.h"
#import "LAStoreManager.h"
#import "LASocialManager.h"

@interface LAAppDelegate ()

@property (nonatomic, strong) LAStoreManager *storeManager;
@property (nonatomic, strong) LASocialManager *socialManager;

@end
@implementation LAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [application setStatusBarHidden:YES];
    
    self.storeManager = [LAStoreManager sharedManager];
    [self.storeManager trackOpen:launchOptions];
    
    // Will have to do this when we get the background image from the server
    [self.storeManager getSettingsWithCompletion:^(NSError *error) {
        NSLog(@"Settings complete");
    }];
    
    self.socialManager = [LASocialManager sharedManager];
    
    return YES;
}

// YOU NEED TO CAPTURE igAPPID:// schema
-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    NSLog(@"url from handel is %@", url);
    return [self.socialManager instagramhandleOpenURL:url];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    if (self.loginViewController) {
        [self.loginViewController loginWithPin:[self getPinFromUrl:url]];
    }
    
    return [self.socialManager instagramhandleOpenURL:url];
}

-(NSString *)getPinFromUrl:(NSURL *)url {
    NSString *urlString = [url absoluteString];
    NSRange pinRange = [urlString rangeOfString:@"//"];
    NSInteger start = pinRange.location + pinRange.length;
    NSInteger length = [urlString length] - start;
    NSString *pinString = [urlString substringWithRange:NSMakeRange(start, length)];
    return pinString;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
