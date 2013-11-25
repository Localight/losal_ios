//
//  LANoticeViewController.h
//  #LOSAL
//
//  Created by Joaquin Brown on 8/23/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LADetailNoticeViewController.h"
#import "LANoticeItem.h"

@protocol LANoticeViewControllerDelegate <NSObject>

- (void)showDetailViewItem:(LANoticeItem *)ourItem;

@end

@interface LANoticeViewController :UITableViewController

@property (nonatomic, weak) id<LANoticeViewControllerDelegate>delegate;

@end
