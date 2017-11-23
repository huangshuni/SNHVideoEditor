//
//  MBProgressHUD+SHN.m
//  SNHVideoEditorTool
//
//  Created by huangshuni on 2017/7/27.
//  Copyright © 2017年 huangshuni. All rights reserved.
//

#import "MBProgressHUD+SHN.h"

@implementation MBProgressHUD (SHN)

#pragma mark - 只显示提示信息无图片
+ (MBProgressHUD *)showOnlyText:(NSString *)text view:(UIView *)view
{
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = text;
    // 再设置模式
    hud.mode = MBProgressHUDModeText;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    // 2秒之后再消失
    [hud hideAnimated:YES afterDelay:2.0];
    
    return hud;
}

+ (MBProgressHUD *)showOnlyText:(NSString *)text view:(UIView *)view delayTime:(CGFloat)delayTime {

    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = text;
    // 再设置模式
    hud.mode = MBProgressHUDModeText;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    // 2秒之后再消失
    [hud hideAnimated:YES afterDelay:delayTime];
    
    return hud;

}


@end
