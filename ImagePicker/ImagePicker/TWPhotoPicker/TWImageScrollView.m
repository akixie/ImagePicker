//
//  TWImageScrollView.m
//  InstagramPhotoPicker
//
//  Created by Emar on 12/4/14.
//  Copyright (c) 2014 wenzhaot. All rights reserved.
//

#import "TWImageScrollView.h"
#define rad(angle) ((angle) / 180.0 * M_PI)

//屏幕的高度
#define SCREEN_H ([[UIScreen mainScreen] bounds].size.height)
//屏幕宽度
#define SCREEN_W ([[UIScreen mainScreen] bounds].size.width)

@interface TWImageScrollView ()<UIScrollViewDelegate>
{
    CGSize _imageSize;
    //双击缩放
    CGFloat maxScale;
    CGFloat minScale;
}

@property (assign, nonatomic) CGFloat currentScale;

@end

@implementation TWImageScrollView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.alwaysBounceHorizontal = YES;
        self.alwaysBounceVertical = YES;
        self.bouncesZoom = YES;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
        
        maxScale = 1.0;
        minScale = 0.8;
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // center the zoom view as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.imageView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    self.imageView.frame = frameToCenter;
}

/**
 *  cropping image not just snapshot , inpired by https://github.com/gekitz/GKImagePicker
 *
 *  @return image cropped
 */
- (UIImage *)capture
{

    CGRect visibleRect = [self _calcVisibleRectForCropArea];//caculate visible rect for crop
    CGAffineTransform rectTransform = [self _orientationTransformedRectOfImage:self.imageView.image];//if need rotate caculate
    visibleRect = CGRectApplyAffineTransform(visibleRect, rectTransform);
    
    
    
    CGAffineTransform _trans = self.imageView.transform;
    
    CGFloat rotate = acosf(_trans.a);
    // 旋转180度后，需要处理弧度的变化
    if (_trans.b < 0) {
        rotate = M_PI -rotate;
    }
    // 将弧度转换为角度
    CGFloat degree = rotate/M_PI * 180;
     

    if (degree > 80) {
//        CGImageRef ref = [self CGImageRotatedByAngle:[self.imageView.image CGImage] angle:360-degree visibleRect:visibleRect];
////        CGImageRef newImageRef = CGImageCreateWithImageInRect([self.imageView.image CGImage], visibleRect);
//        UIImage *newImage = [UIImage imageWithCGImage:ref scale:0.2 orientation:self.imageView.image.imageOrientation];
        
        CGFloat scale = [UIScreen mainScreen].scale;
        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, scale);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image;
    }
    
    CGImageRef ref = CGImageCreateWithImageInRect([self.imageView.image CGImage], visibleRect);//crop
    UIImage* cropped = [[UIImage alloc] initWithCGImage:ref scale:self.imageView.image.scale orientation:self.imageView.image.imageOrientation] ;
    CGImageRelease(ref);
    ref = NULL;
    return cropped;
}

- (CGImageRef)CGImageRotatedByAngle:(CGImageRef)imgRef angle:(CGFloat)angle visibleRect:(CGRect)visibleRect
{
    
    CGFloat angleInRadians = angle * (M_PI / 180);
    CGFloat width = CGImageGetWidth(imgRef);
    //CGFloat height = CGImageGetHeight(imgRef);
    
    width = visibleRect.size.width;
    if (width < SCREEN_W) {
        width = SCREEN_W;
    }
    
    CGRect imgRect = CGRectMake(visibleRect.origin.x, visibleRect.origin.y, width, visibleRect.size.height);
    CGAffineTransform transform = CGAffineTransformMakeRotation(angleInRadians);
    CGRect rotatedRect = CGRectApplyAffineTransform(imgRect, transform);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef bmContext = CGBitmapContextCreate(NULL,
                                                   rotatedRect.size.width,
                                                   rotatedRect.size.height,
                                                   8,
                                                   0,
                                                   colorSpace,
                                                   kCGImageAlphaPremultipliedFirst);
    CGContextSetAllowsAntialiasing(bmContext, YES);
    CGContextSetShouldAntialias(bmContext, YES);
    CGContextSetInterpolationQuality(bmContext, kCGInterpolationHigh);
    CGColorSpaceRelease(colorSpace);
    CGContextTranslateCTM(bmContext,
                          +(rotatedRect.size.width/2),
                          +(rotatedRect.size.height/2));
    CGContextRotateCTM(bmContext, angleInRadians);
    CGContextTranslateCTM(bmContext,
                          -(rotatedRect.size.width/2),
                          -(rotatedRect.size.height/2));
    CGContextDrawImage(bmContext, CGRectMake(0, 0,
                                             rotatedRect.size.width,
                                             rotatedRect.size.height),
                       imgRef);
    
    
    
    CGImageRef rotatedImage = CGBitmapContextCreateImage(bmContext);
    
    
    CFRelease(bmContext);

    return rotatedImage;
}


static CGRect TWScaleRect(CGRect rect, CGFloat scale)
{
    return CGRectMake(rect.origin.x * scale, rect.origin.y * scale, rect.size.width * scale, rect.size.height * scale);
}


-(CGRect)_calcVisibleRectForCropArea{

    CGFloat sizeScale = self.imageView.image.size.width / self.imageView.frame.size.width;
    
    CGFloat zoomScale = self.zoomScale;
    if (self.zoomScale < 0.1) {
        zoomScale = 1;
        sizeScale = self.imageView.image.size.height / self.imageView.frame.size.height;
        
    }
    sizeScale *= zoomScale;
    CGRect visibleRect = [self convertRect:self.bounds toView:self.imageView];
    if (self.zoomScale < 0.1) {
        //visibleRect.size.width = SCREEN_W ;
    }
    return visibleRect = TWScaleRect(visibleRect, sizeScale);
}

- (CGAffineTransform)_orientationTransformedRectOfImage:(UIImage *)img
{
    CGAffineTransform rectTransform;
    switch (img.imageOrientation)
    {
        case UIImageOrientationLeft:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(90)), 0, -img.size.height);
            break;
        case UIImageOrientationRight:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-90)), -img.size.width, 0);
            break;
        case UIImageOrientationDown:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-180)), -img.size.width, -img.size.height);
            break;
        default:
            rectTransform = CGAffineTransformIdentity;
    };
    
    return CGAffineTransformScale(rectTransform, img.scale, img.scale);
}


- (void)displayImage:(UIImage *)image
{
    // clear the previous image
    [self.imageView removeFromSuperview];
    self.imageView = nil;
    
    // reset our zoomScale to 1.0 before doing any further calculations
    self.zoomScale = 1.0;
    
    // make a new UIImageView for the new image
    self.imageView = [[UIImageView alloc] initWithImage:image];
    self.imageView.clipsToBounds = NO;
    self.imageView.userInteractionEnabled=YES;
    //双击手势
    UITapGestureRecognizer *doubelGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleGesture:)];
    doubelGesture.numberOfTapsRequired=2;
    [self.imageView addGestureRecognizer:doubelGesture];
    
    [self addSubview:self.imageView];
    
    CGRect frame = self.imageView.frame;
    if (image.size.height > image.size.width) {
        frame.size.width = self.bounds.size.width ;
        frame.size.height = (self.bounds.size.width / image.size.width) * image.size.height;
    } else {
        frame.size.height = self.frame.size.height;
        frame.size.width = (self.bounds.size.height / image.size.height) * image.size.width;
    }
    self.imageView.frame = frame;
    [self configureForImageSize:self.imageView.bounds.size];
}

- (void)configureForImageSize:(CGSize)imageSize
{
    _imageSize = imageSize;
    self.contentSize = imageSize;
    
    //to center
    if (imageSize.width > imageSize.height) {
        self.contentOffset = CGPointMake(imageSize.width/4, 0);
    } else if (imageSize.width < imageSize.height) {
        self.contentOffset = CGPointMake(0, imageSize.height/4);
    }
    
    [self setMaxMinZoomScalesForCurrentBounds];
    self.zoomScale = 1.0;
    
    // center the zoom view as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.imageView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    self.imageView.frame = frameToCenter;
}

- (void)setMaxMinZoomScalesForCurrentBounds
{
    self.minimumZoomScale = minScale;
    self.maximumZoomScale = 2.0;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    
    return self.imageView;
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
//    [scrollView setZoomScale:scale-0.2 animated:NO];
//    [scrollView setZoomScale:scale animated:NO];
    self.currentScale = scale;
    
//    CGAffineTransform _trans = self.imageView.transform;
//    
//    CGFloat rotate = acosf(_trans.a);
//    // 旋转180度后，需要处理弧度的变化
//    if (_trans.b < 0) {
//        rotate = M_PI -rotate;
//    }
//    // 将弧度转换为角度
//    CGFloat degree = rotate/M_PI * 180;
//    
//    self.imageView.transform = CGAffineTransformMakeRotation(degree);
    
//    [self.imageView setTransformWithoutScaling:CGAffineTransformIdentity];
//    
//    self.imageView setTransform:<#(CGAffineTransform)#>
    
}

- (void) scrollViewDidZoom:(UIScrollView *) scrollView
{
    
    
//    CATransform3D scale = self.imageView.layer.transform;
//    CATransform3D rotation = CATransform3DMakeRotation(M_PI_4, 0, 0, 1);
//    
//    self.imageView.layer.transform = CATransform3DConcat(rotation, scale);
}

#pragma mark -DoubleGesture Action
-(void)doubleGesture:(UIGestureRecognizer *)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PhotoDoubleGesture" object:nil];
    
    //当前倍数等于最大放大倍数
    //双击默认为缩小到原图
    if (_currentScale==maxScale) {
        self.currentScale=minScale;
        [self setZoomScale:_currentScale animated:YES];
        return;
    }
    //当前等于最小放大倍数
    //双击默认为放大到最大倍数
    if (_currentScale==minScale) {
        self.currentScale=maxScale;
        [self setZoomScale:_currentScale animated:YES];
        return;
    }
    
    CGFloat aveScale =minScale+(maxScale-minScale)/2.0;//中间倍数
    
    //当前倍数大于平均倍数
    //双击默认为放大最大倍数
    if (_currentScale>=aveScale) {
        self.currentScale=maxScale;
        [self setZoomScale:_currentScale animated:YES];
        return;
    }
    
    //当前倍数小于平均倍数
    //双击默认为放大到最小倍数
    if (_currentScale<aveScale) {
        self.currentScale=minScale;
        [self setZoomScale:_currentScale animated:YES];
        return;
    }
    
}

@end
