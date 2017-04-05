//
//  FitPublish2ViewController.m
//  Get
//
//  Created by akixie on 17/3/23.
//  Copyright © 2017年 Get. All rights reserved.
//

#import "FitPublish2ViewController.h"
#import "UIColor+Hex.h"
#import "UIView+Animation.h"

#define UIFont(x) [UIFont systemFontOfSize:x]
#define UIBOLDFont(x) [UIFont boldSystemFontOfSize:x]
#define SCREEN_W ([[UIScreen mainScreen] bounds].size.width)
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]

#define kSpec 10

@interface FitPublish2ViewController ()


@property (nonatomic, strong) UIImageView *faceImageView;
@property (nonatomic, strong) UIView *animationView;

@property (nonatomic, strong) UILabel *address_text;

@property (nonatomic,strong) NSMutableArray *imageDataArray;

@property (assign,nonatomic) BOOL isPublishing;

@property (nonatomic,strong) UITextView *textView1;



@property (assign,nonatomic) int  faceSelectedIndex;


@end

@implementation FitPublish2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"GetFit三餐打卡";
    
    [self addRightItemWithTitle:@"发送" imageName:nil selector:@selector(submitActions)];
    
    self.imageDataArray = [[NSMutableArray alloc] init];
    
    [self.imageDataArray addObject:self.selectImage];
    
    [self initAllViews];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

-(void)submitActions{
    
    NSString *descText = self.textView1.text;
    
    
    if (descText.length == 0) {
        [self showErrorMessage:@"请输入文字描述"];
        [self.textView1 becomeFirstResponder];
        return;
    }
    
    
    if (self.faceSelectedIndex == 0 ) {
        [self showErrorMessage:@"请选择表情"];
        return;
    }

    

    [self.textView1 resignFirstResponder];
    
     [self dismissViewControllerAnimated:YES completion:NULL];

    
}

-(void)initAllViews{
    //总高
    CGFloat totalHeight = 0;
    //文字描述
    self.textView1 = [[UITextView alloc] init];
    self.textView1.frame = CGRectMake(10, 5, SCREEN_W-20, 60);
    self.textView1.font = UIFont(16);
    self.textView1.textColor = [UIColor colorWithHexString:@"212121"];
    self.textView1.backgroundColor = [UIColor clearColor];
//    textView1.scrollEnabled = NO;
    [self.contentSV addSubview:self.textView1];
    totalHeight += self.textView1.frame.size.height + kSpec;
    
    //选择后的表情显示
    self.faceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_W-60, totalHeight, 45, 45)];
//    _faceImageView.image = [UIImage imageNamed:@"face5selected"];
    [self.contentSV addSubview:_faceImageView];
    totalHeight +=_faceImageView.frame.size.height +kSpec;
    
    //分割线1
    UILabel *line1 = [[UILabel alloc] initWithFrame:CGRectMake(0, totalHeight, SCREEN_W, 1)];
    line1.text = @"";
    line1.backgroundColor = [UIColor colorWithHexString:@"E5E5E5"];
    [self.contentSV addSubview:line1];
    
    //位置图标
    UIView *addressView = [[UIView alloc] initWithFrame:CGRectMake(0, totalHeight, SCREEN_W, 54)];
    addressView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *addressTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToLocation)];
    [addressView addGestureRecognizer:addressTapGesture];
    [self.contentSV addSubview:addressView];
    
    UIImageView *address_icon = [[UIImageView alloc] initWithFrame:CGRectMake(20,  18, 15, 19)];
    address_icon.image = [UIImage imageNamed:@"card_location"];
    [addressView addSubview:address_icon];
    
    self.address_text = [[UILabel alloc] initWithFrame:CGRectMake(45,  16, SCREEN_W-80, 21)];
    _address_text.text = @"所在位置";
    _address_text.font = UIBOLDFont(17);
    [addressView addSubview:_address_text];
    
    UIImageView *address_righticon = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_W - 30,  22, 8, 13)];
    address_righticon.image = [UIImage imageNamed:@"fit_disclosure Indicator"];
    [addressView addSubview:address_righticon];
    totalHeight += 44 + kSpec;
    
    //分割线2
    UILabel *line2 = [[UILabel alloc] initWithFrame:CGRectMake(0, totalHeight, SCREEN_W, 1)];
    line2.text = @"";
    line2.backgroundColor = [UIColor colorWithHexString:@"E5E5E5"];
    [self.contentSV addSubview:line2];
    
    
    //五个表情
    int count = 5;
    int spaceX = 10;
    int viewSize = (SCREEN_W-spaceX*6)/count;
    int faceImageSize = 45;
    for (int i=0 ; i<5; i++) {
        UIView *sView = [[UIView alloc]initWithFrame:CGRectMake(kSpec*(i%count+1) + i%count * viewSize, totalHeight + 5, viewSize, viewSize)];
        sView.backgroundColor = [UIColor clearColor];
        float faceX = viewSize-faceImageSize;
        if (faceX <0) {
            faceX = 0;
        }
        UIImageView *faceImage = [[UIImageView alloc] initWithFrame:CGRectMake(faceX, 5, faceImageSize, faceImageSize)];
        
        int faceIndex = i+1;
        NSString *faceName = @"face3selected";//刚刚好
        if (faceIndex > 0 && faceIndex <= count) {
            faceName = [NSString stringWithFormat:@"face%dselected",faceIndex];
        }
        faceImage.image = [UIImage imageNamed:faceName];
        [sView addSubview:faceImage];
        
        UILabel *faceText = [[UILabel alloc] initWithFrame:CGRectMake(faceX, faceImageSize + 5, faceImageSize, 21)];
        faceText.textColor = [UIColor colorWithHexString:@"#B6B6B6"];
        faceText.font = UIFont(12);
        faceText.textAlignment = NSTextAlignmentCenter;
        [sView addSubview:faceText];
        switch (i) {
            case 0:
                faceText.text = @"吃撑了";
                break;
            case 1:
                faceText.text = @"有点饱";
                break;
            case 2:
                faceText.text = @"刚刚好";
                break;
            case 3:
                faceText.text = @"还可以";
                break;
            case 4:
                faceText.text = @"超健康";
                break;
                
            default:
                break;
        }
        
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(faceTapGestureAction:)];
        sView.tag = faceIndex;
        [sView addGestureRecognizer:tapGesture];
        
        
        [self.contentSV addSubview:sView];
    }
    totalHeight += viewSize + 10 ;
    
    //选择的餐卡图片
    UIImageView *foodImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, totalHeight+ 10, SCREEN_W, SCREEN_W)];
    //foodImageView.image = [UIImage imageNamed:@"temp1"];
    foodImageView.image = self.selectImage;
    foodImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *foodTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(foodImageTap)];
    [foodImageView addGestureRecognizer:foodTapGesture];
    
    
    [self.contentSV addSubview:foodImageView];
    totalHeight += SCREEN_W + 15 ;
    
    
    self.contentSV.contentSize= CGSizeMake(SCREEN_W, totalHeight);
 
}

-(void)foodImageTap{
    [self.textView1 resignFirstResponder];
}

-(void)goToLocation{
    [self foodImageTap];

}




- (void)faceTapGestureAction:(UITapGestureRecognizer *)tapGesture {
    [self foodImageTap];
    UIView *fromView = tapGesture.view;
    int faceIndex = (int)fromView.tag;
    UIImageView *faceImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
    [self.contentSV addSubview:faceImage];
    
    NSString *faceName = @"face3selected";//刚刚好
    if (faceIndex > 0 && faceIndex <= 5) {
        faceName = [NSString stringWithFormat:@"face%dselected",faceIndex];
    }
    faceImage.image = [UIImage imageNamed:faceName];
    faceImage.tag = faceIndex;
    self.faceImageView.tag = faceIndex;
    
    [faceImage animationStartPoint:fromView.center endPoint:self.faceImageView.center didStopAnimation:^{
        
//        int faceIndex = (int)sView.tag;
        NSString *faceName = faceName = [NSString stringWithFormat:@"face%dselected",faceIndex];
        self.faceImageView.image = [UIImage imageNamed:faceName];
        
        self.faceSelectedIndex = faceIndex;
        
        [self shakeImage:self.faceImageView];
        
        [faceImage removeFromSuperview];
        
    }];
    
}

//晃动效果
- (void)shakeImage:(UIImageView*)sView{
    //创建动画对象,绕Z轴旋转
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    //设置属性，周期时长
    [animation setDuration:0.08];
    
    //抖动角度
    animation.fromValue = @(-M_1_PI/2);
    animation.toValue = @(M_1_PI/2);
    //重复次数，无限大
//    animation.repeatCount = HUGE_VAL;
    animation.repeatCount = 2;
    //恢复原样
    animation.autoreverses = YES;
    //锚点设置为图片中心，绕中心抖动
    sView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    
    [sView.layer addAnimation:animation forKey:@"rotation"];
    
    //1秒后暂停
//    [self performSelector:@selector(pause:) withObject:sView afterDelay:0.2];
}

- (void)pause:(UIImageView*)sView {
//    UIImageView *sView = (UIImageView*)sender;
    sView.layer.speed = 0.0;
    
    [sView removeFromSuperview];
}




#pragma mark =====路径动画-=============
-(CAKeyframeAnimation *)keyframeAnimation:(CGMutablePathRef)path durTimes:(float)time Rep:(float)repeatTimes
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.path = path;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animation.autoreverses = NO;
    animation.duration = time;
    animation.repeatCount = repeatTimes;
    return animation;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
