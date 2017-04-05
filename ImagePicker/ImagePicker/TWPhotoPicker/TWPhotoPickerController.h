//
//  TWPhotoPickerController.h
//  InstagramPhotoPicker
//
//  Created by Emar on 12/4/14.
//  Copyright (c) 2014 wenzhaot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FitBaseViewController.h"

@interface TWPhotoPickerController : FitBaseViewController

@property (nonatomic, copy) void(^cropBlock)(UIImage *image);

@property (nonatomic, copy) NSString *typeTitle;

@end
