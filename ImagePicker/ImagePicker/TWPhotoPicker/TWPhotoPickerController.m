//
//  TWPhotoPickerController.m
//  InstagramPhotoPicker
//
//  Created by Emar on 12/4/14.
//  Copyright (c) 2014 wenzhaot. All rights reserved.
//

#import "TWPhotoPickerController.h"
#import "TWPhotoCollectionViewCell.h"
#import "TWImageScrollView.h"
#import "TWPhotoLoader.h"
#import "FitPublish2ViewController.h"
#import <Photos/Photos.h>

#define kCollectionViewTop 64

#define UIFont(x) [UIFont systemFontOfSize:x]
#define UIBOLDFont(x) [UIFont boldSystemFontOfSize:x]
#define SCREEN_W ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_H ([[UIScreen mainScreen] bounds].size.height)
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]

@interface TWPhotoPickerController ()<UICollectionViewDataSource, UICollectionViewDelegate> {
    CGFloat beginOriginY;
    int fzCount;
}
@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UIImageView *maskView;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) TWImageScrollView *imageScrollView;



@property (strong, nonatomic) NSArray *allPhotos;

@end

@implementation TWPhotoPickerController

#pragma mark - life cycle

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"ReloadSelectAllPhotos" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"PhotoDoubleGesture" object:nil];

}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:self.topView];
    [self.view insertSubview:self.collectionView belowSubview:self.topView];
    
   
       // [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];

    
    
    self.title = @"相机胶卷";
    
    [self addRightItemWithTitle:@"继续" imageName:nil selector:@selector(nextActions)];
    
    [self loadPhotos];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadPhotos) name:@"ReloadSelectAllPhotos" object:nil];
    
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(photosDouble) name:@"PhotoDoubleGesture" object:nil];
    
}
-(void)photosDouble{
    fzCount = 0;
}

-(void)nextActions{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted ||
        status == PHAuthorizationStatusDenied) {
        //无权限
        [self showErrorMessage:@"请先在手机设置-隐私-照片-打开GetFit应用权限"];
        
        return;
    }
    FitPublish2ViewController *publishVC = [FitPublish2ViewController new];
    publishVC.selectImage = self.imageScrollView.capture;
    publishVC.title = self.typeTitle;
    [self.navigationController pushViewController:publishVC animated:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
}




#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.allPhotos count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"TWPhotoCollectionViewCell";
    
    TWPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    TWPhoto *photo = [self.allPhotos objectAtIndex:indexPath.row];
    cell.imageView.image = photo.thumbnailImage;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //旋转复原位
    fzCount = 0;
//    self.imageScrollView.transform = CGAffineTransformIdentity;
    self.imageScrollView.imageView.transform = CGAffineTransformIdentity;
    
    TWPhoto *photo = [self.allPhotos objectAtIndex:indexPath.row];
    [self.imageScrollView displayImage:photo.originalImage];
    if (self.topView.frame.origin.y != kCollectionViewTop) {
        [self tapGestureAction:nil];
    }
    
    
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    //velocity滚动速度
    if (velocity.y >= 1.5 && self.topView.frame.origin.y == kCollectionViewTop) {
        [self tapGestureAction:nil];
    }
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY<= -40 && self.topView.frame.origin.y != kCollectionViewTop) {
        [self tapGestureAction:nil];
    }
}



#pragma mark - event response

- (void)backAction {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)panGestureAction:(UIPanGestureRecognizer *)panGesture {
    switch (panGesture.state)
    {
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            CGRect topFrame = self.topView.frame;
            CGFloat endOriginY = self.topView.frame.origin.y;
            if (endOriginY > beginOriginY) {
                topFrame.origin.y = (endOriginY - beginOriginY) >= 20 ? kCollectionViewTop : -(CGRectGetHeight(self.topView.bounds) - kCollectionViewTop - 44);
            } else if (endOriginY < beginOriginY) {
                topFrame.origin.y = (beginOriginY - endOriginY) >= 20 ? -(CGRectGetHeight(self.topView.bounds) - kCollectionViewTop - 44) : kCollectionViewTop;
            }
            
            CGRect collectionFrame = self.collectionView.frame;
            collectionFrame.origin.y = CGRectGetMaxY(topFrame) - kCollectionViewTop + 2;
            collectionFrame.size.height = CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(topFrame) + kCollectionViewTop;
            [UIView animateWithDuration:.3f animations:^{
                self.topView.frame = topFrame;
                self.collectionView.frame = collectionFrame;
            }];
            break;
        }
        case UIGestureRecognizerStateBegan:
        {
            beginOriginY = self.topView.frame.origin.y;
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            CGPoint translation = [panGesture translationInView:self.view];
            CGRect topFrame = self.topView.frame;
            topFrame.origin.y = translation.y + beginOriginY;
            
            CGRect collectionFrame = self.collectionView.frame;
            collectionFrame.origin.y = CGRectGetMaxY(topFrame)-kCollectionViewTop + 2;
            collectionFrame.size.height = CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(topFrame) + kCollectionViewTop;
            
            if (topFrame.origin.y <= kCollectionViewTop && (topFrame.origin.y >= -(CGRectGetHeight(self.topView.bounds)-kCollectionViewTop-44))) {
                self.topView.frame = topFrame;
                self.collectionView.frame = collectionFrame;
            }
            
            break;
        }
        default:
            break;
    }
}

- (void)tapGestureAction:(UITapGestureRecognizer *)tapGesture {
    CGRect topFrame = self.topView.frame;
    topFrame.origin.y = topFrame.origin.y == kCollectionViewTop ? -(CGRectGetHeight(self.topView.bounds)-kCollectionViewTop-44) : kCollectionViewTop;
    
    CGRect collectionFrame = self.collectionView.frame;
    collectionFrame.origin.y = CGRectGetMaxY(topFrame) - kCollectionViewTop + 2;
    collectionFrame.size.height = CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(topFrame) + kCollectionViewTop;
    [UIView animateWithDuration:.3f animations:^{
        self.topView.frame = topFrame;
        self.collectionView.frame = collectionFrame;
    }];
}



#pragma mark - private methods

- (void)loadPhotos {
    [TWPhotoLoader loadAllPhotos:^(NSArray *photos, NSError *error) {
        if (!error) {
            self.allPhotos = [NSArray arrayWithArray:photos];
            if (self.allPhotos.count) {
                TWPhoto *firstPhoto = [self.allPhotos objectAtIndex:0];
                [self.imageScrollView displayImage:firstPhoto.originalImage];
            }
            [self.collectionView reloadData];
        } else {
            NSLog(@"Load Photos Error: %@", error);
        }
    }];
    
}



#pragma mark - getters & setters

- (UIView *)topView {
    if (_topView == nil) {
        CGRect rect = CGRectMake(0, kCollectionViewTop, SCREEN_W, SCREEN_W);
        self.topView = [[UIView alloc] initWithFrame:rect];
        self.topView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        self.topView.backgroundColor = RGBCOLOR(238, 238, 238);
        self.topView.clipsToBounds = YES;
        
        rect = CGRectMake(0, SCREEN_W-44, SCREEN_W, 44);
        UIView *dragView = [[UIView alloc] initWithFrame:rect];
        dragView.backgroundColor = [UIColor clearColor];
        dragView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        
        //翻转
        UIButton *fzButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 24, 28)];
        [fzButton setBackgroundImage:[UIImage imageNamed:@"card_rotate"] forState:UIControlStateNormal];
        [fzButton setBackgroundImage:[UIImage imageNamed:@"card_rotate"] forState:UIControlStateSelected];
        [fzButton addTarget:self action:@selector(imageRotateActions) forControlEvents:UIControlEventTouchUpInside];
        [dragView addSubview:fzButton];
        
        [self.topView addSubview:dragView];
        
//        UIImage *img = [UIImage imageNamed:@"cameraroll-picker-grip.png" inBundle:bundle compatibleWithTraitCollection:nil];
//        rect = CGRectMake((CGRectGetWidth(dragView.bounds)-img.size.width)/2, (CGRectGetHeight(dragView.bounds)-img.size.height)/2, img.size.width, img.size.height);
//        UIImageView *gripView = [[UIImageView alloc] initWithFrame:rect];
//        gripView.image = img;
//        [dragView addSubview:gripView];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
        [dragView addGestureRecognizer:panGesture];
        
//        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
//        [dragView addGestureRecognizer:tapGesture];
//        [tapGesture requireGestureRecognizerToFail:panGesture];
        
        
        
        rect = CGRectMake(0, 0, SCREEN_W, SCREEN_W);
        self.imageScrollView = [[TWImageScrollView alloc] initWithFrame:rect];
        
        
        
        [self.topView addSubview:self.imageScrollView];
        [self.topView sendSubviewToBack:self.imageScrollView];
        
//        self.maskView = [[UIImageView alloc] initWithFrame:rect];
//        
//        self.maskView.image = [UIImage imageNamed:@"straighten-grid.png" inBundle:bundle compatibleWithTraitCollection:nil];
//        [self.topView insertSubview:self.maskView aboveSubview:self.imageScrollView];
    }
    return _topView;
}

-(void)imageRotateActions{
    fzCount +=1;
    self.imageScrollView.imageView.transform = CGAffineTransformMakeRotation(M_PI_2 * fzCount);

    
    
//    CGRect frame = self.imageScrollView.imageView.frame;
//    if ( self.imageScrollView.imageView.image.size.height >  self.imageScrollView.imageView.image.size.width) {
//        frame.size.width = self.imageScrollView.bounds.size.width ;
//        frame.size.height = (self.imageScrollView.bounds.size.width / self.imageScrollView.imageView.image.size.width) * self.imageScrollView.imageView.image.size.height;
//    } else {
//        frame.size.height = self.imageScrollView.frame.size.height;
//        frame.size.width = (self.imageScrollView.bounds.size.height / self.imageScrollView.imageView.image.size.height) * self.imageScrollView.imageView.image.size.width;
//    }
//    self.imageScrollView.imageView.frame = frame;
    
    
    CGSize imageSize = self.imageScrollView.imageView.bounds.size;
    
    //to center,旋转时，因为宽高对调了，所以需要重新调整图片中心位置
    if (fzCount % 2 == 0) {
        if (imageSize.width > imageSize.height) {
            self.imageScrollView.contentOffset = CGPointMake(imageSize.width/4, 0);
        } else if (imageSize.width < imageSize.height) {
            self.imageScrollView.contentOffset = CGPointMake(0, imageSize.height/4);
        }
    }else{
        if (imageSize.width < imageSize.height) {
            self.imageScrollView.contentOffset = CGPointMake(imageSize.width/4, 0);
        } else if (imageSize.width > imageSize.height) {
            self.imageScrollView.contentOffset = CGPointMake(0, imageSize.height/4);
        }
    }
    
    
//    self.imageScrollView.imageView.transform = CGAffineTransformIdentity;
//    _weiboContentTextView.transform=CGAffineTransformMakeRotation(CGFloat angle);传入弧度值
//    弧度值为：角度＊*M_PI/180
}

- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        CGFloat colum = 4.0, spacing = 2.0;
        CGFloat value = floorf((CGRectGetWidth(self.view.bounds) - (colum - 1) * spacing) / colum);
        
        UICollectionViewFlowLayout *layout  = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize                     = CGSizeMake(value, value);
        layout.sectionInset                 = UIEdgeInsetsMake(0, 0, 0, 0);
        layout.minimumInteritemSpacing      = spacing;
        layout.minimumLineSpacing           = spacing;
        
        CGRect rect = CGRectMake(0, SCREEN_W+spacing, SCREEN_W, SCREEN_H-SCREEN_W);
        _collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        
        [_collectionView registerClass:[TWPhotoCollectionViewCell class] forCellWithReuseIdentifier:@"TWPhotoCollectionViewCell"];
    }
    return _collectionView;
}

@end
