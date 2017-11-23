//
//  SNHVideoTool.m
//  SNHVideoEditorTool
//
//  Created by huangshuni on 2017/11/23.
//  Copyright © 2017年 huangshuni. All rights reserved.
//

#import "SNHVideoTool.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation SNHVideoTool

+ (instancetype)shared {
    static SNHVideoTool *tool;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [[self alloc] init];
    });
    return tool;
}


/**
 *  把视频保存到系统相册
 *  @param outputURL    保存的url路径
 *  @param successBlock 成功回调
 *  @param failureBlcok 失败回调
 */
- (void)writeVideoToPhotoLibraryWithOutputPath:(NSURL *)outputURL
                                       success:(void (^)(void))successBlock
                                       failure:(void (^)(NSError *error))failureBlcok {
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:outputURL completionBlock:^(NSURL *assetURL, NSError *error) {
        
        if (error) {
            if (failureBlcok) {
                failureBlcok(error);
                NSLog(@"保存到系统相册失败");
            }
        }else{
            if (successBlock) {
                NSLog(@"保存到系统相册成功");
                successBlock();
            }
        }
        
    }];
}

@end
