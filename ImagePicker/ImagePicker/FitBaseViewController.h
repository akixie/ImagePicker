//
//  FitBaseViewController.h
//  Get
//
//  Created by akixie on 16/10/24.
//  Copyright © 2016年 Get. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FitBaseViewController : UIViewController


@property(nonatomic, assign) BOOL isModel;
@property (nonatomic,strong) UIButton      *navgationButton;

@property(nonatomic, assign) BOOL isHiddenBack;


//返回操作
- (void)goBack:(id)sender;

//设置RightItem
- (void)addRightItemWithTitle:(NSString *)title imageName:(NSString *)imageName selector:(SEL)selector;



- (void)showErrorMessage:(NSString *)errorMessage;

@end
