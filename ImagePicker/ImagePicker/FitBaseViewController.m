//
//  FitBaseViewController.m
//  Get
//
//  Created by akixie on 16/10/24.
//  Copyright © 2016年 Get. All rights reserved.
//

#import "FitBaseViewController.h"
#import "UIColor+Hex.h"

#define UIBOLDFont(x) [UIFont boldSystemFontOfSize:x]
#define UIFont(x) [UIFont systemFontOfSize:x]



#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
#define TEXTSIZE(text, font) [text length] > 0 ? [text \
sizeWithAttributes:@{NSFontAttributeName:font}] : CGSizeZero;
#else
#define TEXTSIZE(text, font) [text length] > 0 ? [text sizeWithFont:font] : CGSizeZero;
#endif

@interface FitBaseViewController ()

@end

@implementation FitBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (!_isHiddenBack) {
        [self setNavBackButton];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setNavBackButton{
    
    [self.navigationController.navigationItem setHidesBackButton:YES];
    UIButton *bb = [UIButton buttonWithType:UIButtonTypeCustom];
    bb.frame = CGRectMake(0, 0, 43, 43);
    
    //        bb.backgroundColor = [UIColor greenColor];
    [bb addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchDown];
    UIImageView *bbImage = [[UIImageView alloc]initWithFrame:CGRectMake(-10, 5, 33, 33)];
    if (self.isModel) {
        bbImage.image = [UIImage imageNamed:@"fitback"];
    }else{
        bbImage.image = [UIImage imageNamed:@"fitback"];
    }
    bb.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [bb addSubview:bbImage];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithCustomView:bb];
    backItem.tag = 2222;
    self.navigationItem.leftBarButtonItem = backItem;
}

- (void)goBack:(id)sender{
    if (self.isModel) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}



//设置RightItem
- (void)addRightItemWithTitle:(NSString *)title imageName:(NSString *)imageName selector:(SEL)selector{
    
    _navgationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _navgationButton.frame = CGRectMake(0, 0, 50, 25);
    [_navgationButton.titleLabel setFont:UIBOLDFont(16)];
    [_navgationButton setTitleColor:[UIColor colorWithHexString:@"#212121"] forState:UIControlStateNormal];
    [_navgationButton setTitle:title forState:UIControlStateNormal];
    [_navgationButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [_navgationButton addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    //CGSize imageSize = _navgationButton.currentImage.size;
    //CGSize titleSize = TEXTSIZE(title, _navgationButton.titleLabel.font);
    //CGFloat bWidth=imageSize.width+titleSize.width;

    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:_navgationButton];
    
    // 调整 leftBarButtonItem 在 iOS7 下面的位置
    if(([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0? 20:0)){
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -5;
        self.navigationItem.rightBarButtonItems = @[negativeSpacer,buttonItem];
    }else{
        self.navigationItem.rightBarButtonItem = buttonItem;
    }
}




- (void)showErrorMessage:(NSString *)errorMessage
{
    if (errorMessage == nil ||  errorMessage.length == 0) {
        return;
    }
    [[[UIAlertView alloc] initWithTitle:@"提示"
                                message:errorMessage
                               delegate:nil
                      cancelButtonTitle:@"确定"
                      otherButtonTitles:nil] show];
}


@end
