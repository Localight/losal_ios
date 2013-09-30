//
//  LAMasterViewController.h
//  #LOSAL
//
//  Created by James Orion Hall on 7/27/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LADataLoader.h"
#import "LANoticeViewController.h"
// 1. Forward declaration of ChildViewControllerDelegate - this just declares
// that a ChildViewControllerDelegate type exists so that we can use it
// later.

@interface LAFeedViewController : UITableViewController<LANoticeViewControllerDelegate>
{
    
}

@end
