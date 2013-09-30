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
#import <Security/Security.h>
@interface LAAppDelegate ()

//@property (nonatomic, strong) LAStoreManager *storeManager;
@property (nonatomic, strong) LASocialManager *socialManager;

@end
@implementation LAAppDelegate

//static NSString * const firstTimeLaunchkey = @"hasLaunchedOnce";
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
   
// const pointer
    
//    [[UIApplication sharedApplication] setStatusBarHidden:YES];
//    [[UIApplication sharedApplication] setStatusBarHidden:YES
//                                            withAnimation:UIStatusBarAnimationNone];
    
    [Parse setApplicationId:@"zFi294oXTVT6vj6Tfed5heeF6XPmutl0y1Rf7syg"
                  clientKey:@"jyL9eoOizsJqQK5KtADNX5ILpjgSdP6jW9Lz1nAU"];
    
    PFACL *defaultACL = [PFACL ACL];
    // Enable public read access by default, with any newly created PFObjects belonging to the current user
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
//    self.storeManager = [LAStoreManager sharedManager];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    [PFUser enableAutomaticUser];
    [[PFUser currentUser] saveInBackground];
    //[[LAStoreManager defaultStore]createUser];
    
    [[LAStoreManager defaultStore]getSettingsWithCompletion:^(NSError *error){
        NSLog(@"Settings complete");
    }];
    //[[LANoticesStore defaultStore]updateEntries];
    // Will download hashtags for later use
    [[LAStoreManager defaultStore]getHashTags];
    
    self.socialManager = [LASocialManager sharedManager];
    
    return YES;
}

// YOU NEED TO CAPTURE igAPPID:// schema
-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    NSLog(@"url from handel is %@", url);
    return [self.socialManager instagramhandleOpenURL:url];
}



-(BOOL)application:(UIApplication *)application
           openURL:(NSURL *)url
 sourceApplication:(NSString *)sourceApplication
        annotation:(id)annotation {
    
    NSLog(@"url from open is %@", url);
    
    // here is where we could add the get pin fromUrl and save it.
    // I'm thinking about passing the url to the store and from the store passing it to the LAUser
    NSString *urlString = [url absoluteString];
    NSRange pinRange = [urlString rangeOfString:@"//"];
    NSInteger start = pinRange.location + pinRange.length;
    NSInteger length = [urlString length] - start;
    NSString *pinString = [urlString substringWithRange:NSMakeRange(start, length)];
    
    NSLog(@"we caught the website thing");
    
//    [[LAStoreManager sharedManager]setUserVerified:YES];
    // We se the user's password to the pinstring then log in using the LAUser info.
    NSLog(@"%@",pinString);
    
    // This is where we would use store the user password and username with the key thing, then from here on out call the keychain method
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"YourAppLogin"
                                                                            accessGroup:nil];
    
    [keychainItem setObject:pinString forKey:(__bridge id)kSecValueData];
    
//    [PFUser logInWithUsernameInBackground:[keychainItem objectForKey:(__bridge id)(kSecAttrAccount)]
//                                 password:[keychainItem objectForKey:(__bridge id)(kSecValueData)]
//                                   target:self
//                                 selector:@selector(handleUserLogin:error:)];
//    [keychainItem setObject:@"username you are saving" forKey:kSecAttrAccount];
//    [[[LAStoreManager defaultStore]currentUser]setPinNumberFromUrl:[keychainItem objectForKey:kSecValueData]];
     [[LAStoreManager defaultStore]loginWithPhoneNumber];
    [[LAStoreManager defaultStore]getUserLikesWithCompletion:^(NSError *error) {
        NSLog(@"getting the likes");
    }];
    return [self.socialManager instagramhandleOpenURL:url];// doesn't make sense come back too.
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
