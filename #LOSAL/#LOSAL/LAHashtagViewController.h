//
//  LAHashtagViewController.h
//  #LOSAL
//
//  Created by Joaquin Brown on 8/26/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LAHashtagViewController : UIViewController<UIPickerViewDataSource,UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *picker;

@end
