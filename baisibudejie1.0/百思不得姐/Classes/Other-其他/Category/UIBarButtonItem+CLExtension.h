//
//  UIBarButtonItem+CLExtension.h
//  百思不得姐
//
//  Created by 杨博兴 on 16/9/21.
//  Copyright © 2016年 xx_cc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (CLExtension)

+(instancetype)itemWithImage:(NSString *)image HeightImage:(NSString *)heightImage Target:(id)target action:(SEL)action;

@end
