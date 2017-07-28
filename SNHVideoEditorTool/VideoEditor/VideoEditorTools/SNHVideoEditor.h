//
//  SNHVideoEditor.h
//  test视频拼接剪切
//
//  Created by huangshuni on 2017/7/18.
//  Copyright © 2017年 黄淑妮. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SNHVideoModel.h"

typedef NS_ENUM(NSUInteger, SNHVideoTransitionType) {
    SNHVideoTransitionTypeDefault,//无效果
    SNHVideoTransitionTypeFadeInOut,//淡入淡出的效果
};

typedef NS_ENUM(NSUInteger, SNVideoLogoDirection) {
    SNVideoLogoDirectionNull,
    SNVideoLogoDirectionLeftTop,
    SNVideoLogoDirectionLeftBottom,
    SNVideoLogoDirectionRightTop,
    SNVideoLogoDirectionRightBottom,
};

@interface SNHVideoEditor : NSObject

@property (nonatomic, copy)   NSString  *outPutPath;//保存路径

@property (nonatomic, assign) CGSize     renderSize;
@property (nonatomic, copy)   NSString  *outputFileType;//默认为mov
@property (nonatomic, assign) BOOL       shouldOptimizeForNetworkUse; //默认为no
@property (nonatomic, copy)   NSString  *presetName;//清晰度设置 例如：AVAssetExportPresetHighestQuality

@property (nonatomic, assign) SNHVideoTransitionType videoTransitionType;//视频的转场动画

//单个asset操作
- (void)loadAsset:(NSURL *)assetURL;
- (void)loadAsset:(NSURL *)assetURL beginTime:(CGFloat)beginTime endTime:(CGFloat)endTime;
//- (void)loadAsset:(NSURL *)assetURL partsTimeArr:(NSArray *)partTimeRangesArr;

//多个asset操作
- (void)loadAssetUrls:(NSArray *)assetURLArr;
- (void)loadAssetModels:(NSArray <SNHVideoModel *> *)assetModelArr;

//带背景音乐
- (void)loadAssetWithBGM:(NSURL *)videoAssetURL bgAssetURL:(NSURL *)bgAssetURL;

//加水印
- (void)addWater:(CALayer *)overlayLayer
       withFrame:(CGSize)size;

//加logo
- (void)addLogoInDirection:(SNVideoLogoDirection)direction;


/**
 导出视频

 @param successBlock 成功回调
 @param failureBlock 失败回调
 */
- (void)exportVideoAsynchronouslyWithSuccessBlock:(void (^)(NSURL *outputURL))successBlock
                                     failureBlock:(void (^)(NSError *error))failureBlock;


/**
 *  把视频保存到系统相册
 *  @param successBlock 成功回调
 *  @param failureBlcok 失败回调
 */
- (void)writeVideoToPhotoLibraryWithSuccess:(void (^)(void))successBlock failure:(void (^)(NSError *error))failureBlcok;



/**
 获取视频任意时间的图像
 
 @param videoURL 视频的NSURL地址
 @param time 获取那一时刻的图片
 @param successBlock 成功回调
 @param failureBlock 失败回调
 */
+ (void)thumbnailImageForVideo:(NSURL *)videoURL
                        atTime:(CGFloat)time
                  successBlock:(void(^)(UIImage *image))successBlock
                  failureBlock:(void(^)(NSError *error))failureBlock;

@end
