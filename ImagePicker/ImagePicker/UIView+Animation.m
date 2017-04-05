//
//  UIView+Animation.m
//  Get
//
//  Created by akixie on 17/3/23.
//  Copyright © 2017年 Get. All rights reserved.
//

#import "UIView+Animation.h"
#import <objc/message.h>

@interface UIView ()<CAAnimationDelegate>

@property (nonatomic, copy) void (^animStop)(void);

@end


@implementation UIView (Animation)

- (void)animationStartPoint:(CGPoint)start endPoint:(CGPoint)end didStopAnimation:(void (^)(void))event {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:start];
    [path addCurveToPoint:end controlPoint1:start controlPoint2:CGPointMake(start.x, start.y)];
    
    // 路径
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.path = path.CGPath;
//    animation.rotationMode = kCAAnimationRotateAuto;
    
    // 缩放
    CABasicAnimation *scAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scAnimation.fromValue = @1;
    scAnimation.toValue = @0.7;
    scAnimation.autoreverses = YES;
    
    CAAnimationGroup *groups = [CAAnimationGroup animation];
    groups.animations = @[animation,scAnimation];
    groups.duration = 0.5; // 时间
    groups.removedOnCompletion = NO;
    groups.fillMode = kCAFillModeForwards;
    groups.delegate = self;
    [groups setValue:@"groupsAnimation" forKey:@"animationName"];
    [self.layer addAnimation:groups forKey:nil];
    
    self.animStop = event;
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    self.animStop();
}

- (void)setAnimStop:(void (^)(void))animStop {
    objc_setAssociatedObject(self, @"animStop", animStop, OBJC_ASSOCIATION_COPY);
}

- (void (^)(void))animStop {
    return objc_getAssociatedObject(self, @"animStop");
}

@end
