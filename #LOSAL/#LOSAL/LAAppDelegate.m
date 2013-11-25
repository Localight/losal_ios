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
#import "LANoticesStore.h"
#import "KeychainItemWrapper.h"
#import "LALikesStore.h"
#import <Security/Security.h>
#import "TestFlight.h"

@interface LAAppDelegate ()

@property (nonatomic, strong) LASocialManager *socialManager;

@end

@implementation LAAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [TestFlight takeOff:@"81a4be3b-0bfa-4ed9-a551-02b3e262a9c3"];
    [Parse setApplicationId:@"zFi294oXTVT6vj6Tfed5heeF6XPmutl0y1Rf7syg"
                  clientKey:@"jyL9eoOizsJqQK5KtADNX5ILpjgSdP6jW9Lz1nAU"];
    
    PFACL *defaultACL = [PFACL ACL];
    
    // Enable public read access by default, with any newly created PFObjects belonging to the current user
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    [PFUser enableAutomaticUser];
    [[PFUser currentUser] saveInBackground];

    [[LAStoreManager defaultStore] getSettingsWithCompletion:^(NSError *error){
        NSLog(@"Settings complete");
    }];
    
    [[LANoticesStore defaultStore] updateEntries];
    
    self.socialManager = [LASocialManager sharedManager];

    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [self.socialManager instagramhandleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    // determine if the URL string is coming from Instagram, if it is, then don't attempt to log the user in
    NSArray *bundleIdentifierSplit = [url.absoluteString componentsSeparatedByString:@"localism.losal"];
    if (bundleIdentifierSplit.count < 2)
        return [self.socialManager instagramhandleOpenURL:url];
    
    NSString *urlString = [url absoluteString];
    NSRange pinRange = [urlString rangeOfString:@"//"];
    NSInteger start = pinRange.location + pinRange.length;
    NSInteger length = [urlString length] - start;
    NSString *pinString = [urlString substringWithRange:NSMakeRange(start, length)];
    
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"YourAppLogin"
                                                                            accessGroup:nil];
    
    [keychainItem setObject:pinString forKey:(__bridge id)kSecValueData];
    
    [[LAStoreManager defaultStore] loginWithPhoneNumber];
    
    [[LALikesStore defaultStore] getUserLikesWithCompletion:^(NSError *error) {
        NSLog(@"getting the likes");
    }];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[NSUserDefaults standardUserDefaults] synchronize];
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
    [[NSUserDefaults standardUserDefaults] synchronize];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
