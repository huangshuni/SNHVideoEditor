//
//  MBProgressHUD+SHN.h
//  SNHVideoEditorTool
//
//  Created by huangshuni on 2017/7/27.
//  Copyright © 2017年 huangshuni. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (SHN)

+ (MBProgressHUD *)showOnlyText:(NSString *)text view:(UIView *)view;

+ (MBProgressHUD *)showOnlyText:(NSString *)text view:(UIView *)view delayTime:(CGFloat)delayTime;

@end
