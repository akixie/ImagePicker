//
//  UIColor+Hex.h
//  Get
//
//  Created by akixie on 15/10/17.
//  Copyright © 2015年 Get. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor(Hex)
/**
 *  设置颜色
 *
 *  @param hexColor 颜色值（long）
 *
 *  @return color对象
 */
+ (UIColor *)colorWithHex:(long)hexColor;
/**
 *  设置颜色
 *
 *  @param hexColor 颜色值（long）
 *  @param opacity  透明度
 *
 *  @return color对象
 */
+ (UIColor *)colorWithHex:(long)hexColor alpha:(float)opacity;
/**
 *  根据传入的16进制的颜色值创建颜色
 *
 *  @param color 颜色值
 *
 *  @return 颜色color
 */
+ (UIColor *) colorWithHexString: (NSString *)color;


+ (UIColor *)colorWithInt:(int)color;

@end
