//
//  UIView+Animation.h
//  Get
//
//  Created by akixie on 17/3/23.
//  Copyright © 2017年 Get. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Animation)

- (void)animationStartPoint:(CGPoint)start endPoint:(CGPoint)end didStopAnimation:(void(^)(void)) event;


@end
