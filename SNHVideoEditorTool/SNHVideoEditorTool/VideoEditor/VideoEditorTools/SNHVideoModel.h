//
//  SNHVideoModel.h
//  test视频拼接剪切
//
//  Created by huangshuni on 2017/7/18.
//  Copyright © 2017年 黄淑妮. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SNHVideoModel : NSObject

//如果begintime和endtime都没有设置的话，默认为完整的视频
//如果begintime设置了，endtime没有设置的话，默认为（begintime-视频结束）
//如果beigintime和endtime都设置了，那么久为begin-endtime

@property (nonatomic, assign) CGFloat beginTime;
@property (nonatomic, assign) CGFloat endTime;
@property (nonatomic, strong) NSURL  *assetUrl;

@property (nonatomic, strong) UIImage *videoImage;//视频第一帧的图片

@end
