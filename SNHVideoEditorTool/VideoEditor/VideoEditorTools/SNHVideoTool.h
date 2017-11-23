//
//  SNHVideoTool.h
//  SNHVideoEditorTool
//
//  Created by huangshuni on 2017/11/23.
//  Copyright © 2017年 huangshuni. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNHVideoTool : NSObject

+ (instancetype)shared;

/**
 *  把视频保存到系统相册
 *  @param outputURL    保存的url路径
 *  @param successBlock 成功回调
 *  @param failureBlcok 失败回调
 */
- (void)writeVideoToPhotoLibraryWithOutputPath:(NSURL *)outputURL
                                       success:(void (^)(void))successBlock
                                       failure:(void (^)(NSError *error))failureBlcok;


@end
