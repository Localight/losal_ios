//
//  LADetailNoticeViewController.m
//  #LOSAL
//
//  Created by James Orion Hall on 8/27/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LADetailNoticeViewController.h"
#import "LANoticeItem.h"
#import "LANoticesStore.h"
#import "LAImageStore.h"
//#import "LAImageStore.h"
@implementation LADetailNoticeViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [titleLabel setText:[_item noticeTitle]];
    [content setText:[_item noticeContent]];
    
    [[self navigationItem] setTitle:[_item noticeTitle]];
}
//    // Create a NSDateFormatter that will turn a date into a simple date string
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
//    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
//    
//    // Use filtered NSDate object to set dateLabel contents
//    [dateLabel setText:[dateFormatter stringFromDate:[item dateCreated]]];
    
    // Change the navigation item to display name of item
//     
//    NSString *imageKey = [_item imageKey];
//    if (imageKey) {
//        // Get image for image key from image store
//        UIImage *imageToDisplay =
//        [[LAImageStore defaultImageStore] imageForKey:imageKey];
//        // Use that image to put on the screen in imageView
//        [imageView setImage:imageToDisplay];
//    } else {
//        // Clear the imageView
//        [imageView setImage:nil];
//    }

//- (void)imagePickerController:(UIImagePickerController *)picker
//didFinishPickingMediaWithInfo:(NSDictionary *)info
//{
//    // Get picked image from info dictionary
//    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
//    
//    [_item setThumbnailDataFromImage:image];
//    
//    // Create a CFUUID object - it knows how to create unique identifier strings
//    CFUUIDRef newUniqueID = CFUUIDCreate (kCFAllocatorDefault);
//    
//    // Create a string from unique identifier
//    CFStringRef newUniqueIDString =
//    CFUUIDCreateString (kCFAllocatorDefault, newUniqueID);
//    
//    // Use that unique ID to set our item's imageKey
//    NSString *key = (__bridge NSString *)newUniqueIDString;
//    [_item setImageKey:key];
//    
//    
//    // Store image in the BNRImageStore with this key
//    [[LAImageStore defaultImageStore] setImage:image
//                                         forKey:[_item imageKey]];
//    
//    CFRelease(newUniqueIDString);
//    CFRelease(newUniqueID);
//    
//    // Put that image onto the screen in our image view
//    [imageView setImage:image];
//    
//     [self dismissViewControllerAnimated:YES completion:nil];
//}

@end
