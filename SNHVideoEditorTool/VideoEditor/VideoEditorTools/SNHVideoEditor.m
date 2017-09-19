//
//  SNHVideoEditor.m
//  test视频拼接剪切
//
//  Created by huangshuni on 2017/7/18.
//  Copyright © 2017年 Niusee.inc. All rights reserved.
//

#import "SNHVideoEditor.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define animationDur 1.0f
#define EDIT_VIDEO_FPS 23

@interface SNHVideoEditor ()

@property (nonatomic, strong) AVMutableComposition      *mixComposition;
@property (nonatomic, strong) AVMutableCompositionTrack *audioTrack;
@property (nonatomic, strong) AVMutableCompositionTrack *videoTrack;
@property (nonatomic, strong) AVMutableVideoComposition *videoComposition;

@property (nonatomic, strong) AVMutableCompositionTrack *transAudioTrack;
@property (nonatomic, strong) AVMutableCompositionTrack *transVideoTrack;
@property (nonatomic, strong) AVMutableCompositionTrack *transVideoBgTrack;//用来辅助完成转场效果（淡入淡出效果）

@property (nonatomic, strong) NSMutableArray            *datasArr;
@property (nonatomic, copy)   NSURL                     *outputURL;


@property (nonatomic, assign) SNVideoLogoDirection logoDirection;

@end

@implementation SNHVideoEditor

#pragma mark - =================== life cycle ===================
- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - =================== setter/getter ===================

- (NSString *)outputFileType {
    return [self transOutPutFileType:_outputFileType];
}

- (void)setOutPutPath:(NSString *)outPutPath {
    _outPutPath = outPutPath;
}


- (NSMutableArray *)datasArr {
    if (!_datasArr) {
        _datasArr = [NSMutableArray array];
    }
    return _datasArr;
}

- (NSString *)presetName {
    return _presetName ? _presetName : AVAssetExportPresetHighestQuality;
}

#pragma mark - =================== export api===================
- (void)loadAsset:(NSURL *)assetURL {
    
    SNHVideoModel *model = [[SNHVideoModel alloc]init];
    model.assetUrl = assetURL;
    self.datasArr = [NSMutableArray arrayWithObject:model];
}

- (void)loadAsset:(NSURL *)assetURL beginTime:(CGFloat)beginTime endTime:(CGFloat)endTime {
    
    SNHVideoModel *model = [[SNHVideoModel alloc]init];
    model.assetUrl = assetURL;
    model.beginTime = beginTime;
    model.endTime = endTime;
    self.datasArr = [NSMutableArray arrayWithObject:model];
}

//- (void)loadAsset:(NSURL *)assetURL partsTimeArr:(NSArray *)partTimeRangesArr {
//
//
//}

- (void)loadAssetUrls:(NSArray *)assetURLArr {
    
    for (NSURL *url in assetURLArr) {
        SNHVideoModel *model = [[SNHVideoModel alloc]init];
        model.assetUrl = url;
        [self.datasArr addObject:model];
    }
}

- (void)loadAssetModels:(NSArray <SNHVideoModel *> *)assetModelArr {
    
    self.datasArr = [NSMutableArray arrayWithArray:assetModelArr];
}


- (void)loadAssetWithBGM:(NSURL *)videoAssetURL bgAssetURL:(NSURL *)bgAssetURL {
    
}


#pragma mark 加水印
- (void)addWater:(CALayer *)overlayLayer
       withFrame:(CGSize)size {
    
    overlayLayer.frame = CGRectMake(self.videoComposition.renderSize.width/2 - 150, self.videoComposition.renderSize.height / 2 + 200, 96, 96);
    
    CGSize videoSize = self.videoComposition.renderSize;
    
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    // 这里看出区别了吧，我们把overlayLayer放在了videolayer的上面，所以水印总是显示在视频之上的。
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:overlayLayer];
    
    self.videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool
                                           videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
}


- (void)addLogoInDirection:(SNVideoLogoDirection)direction {
    
    self.logoDirection = direction;
}



#pragma mark - =================== define ===================
#pragma mark - 1.初始化通道
- (void)initialHandle {
    
    //Step 1
    self.mixComposition = [[AVMutableComposition alloc] init];
    
    //创建淡入淡出的视频通道
    if (self.videoTransitionType == SNHVideoTransitionTypeDefault) {
        //创建音频通道
        self.audioTrack = [self.mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                           preferredTrackID:kCMPersistentTrackID_Invalid];
        //创建视频通道
        self.videoTrack = [self.mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                           preferredTrackID:kCMPersistentTrackID_Invalid];
        
    }else if (self.videoTransitionType == SNHVideoTransitionTypeFadeInOut) {
        self.transAudioTrack = [self.mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                preferredTrackID:kCMPersistentTrackID_Invalid];
        self.transVideoTrack = [self.mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                preferredTrackID:
                                kCMPersistentTrackID_Invalid];
        self.transVideoBgTrack = [self.mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                  preferredTrackID:
                                  kCMPersistentTrackID_Invalid];
    }
    
    
}

#pragma mark 2.向音视频通道插入对应的音视频
- (void)combineAudioAndVideo:(NSArray *)assetModelsArr
            WithFailureBlock:(void (^)(NSError *error))failureBlock {
    
    for (int i = 0; i < assetModelsArr.count; i++) {
        SNHVideoModel *model = assetModelsArr[i];
        AVURLAsset *asset = [[AVURLAsset alloc]initWithURL:model.assetUrl options:nil];
        //获取AVAsset中的音频
        if (model.beginTime == 0.0 && model.endTime == 0.0) {
            model.beginTime = 0.0;
            model.endTime = CMTimeGetSeconds(asset.duration);
        }
        
        NSLog(@"value:%lld --- timescale:%d -- seconds:%.2lld",asset.duration.value,asset.duration.timescale,asset.duration.value/asset.duration.timescale);
        
    }
    
    if (self.videoTransitionType == SNHVideoTransitionTypeDefault) {
        [self combineOrginalVideoAndAudio:assetModelsArr WithFailureBlock:^(NSError *error) {
            if (failureBlock) {
                failureBlock(error);
                return;
            }
        }];
        
    }else if (self.videoTransitionType == SNHVideoTransitionTypeFadeInOut) {
        [self combineTransFadeInoutVideoAndAudio:assetModelsArr WithFailureBlock:^(NSError *error) {
            if (failureBlock) {
                failureBlock(error);
                return;
            }
        }];
    }
}

#pragma mark ---插入原始音视频
- (void)combineOrginalVideoAndAudio:(NSArray *)assetModelsArr
                   WithFailureBlock:(void (^)(NSError *error))failureBlock{
    
    //Step 2
    CMTime totalDuration = kCMTimeZero;
    
    for (int i = 0; i < assetModelsArr.count; i++) {
        
        SNHVideoModel *model = assetModelsArr[i];
        AVURLAsset *asset = [[AVURLAsset alloc]initWithURL:model.assetUrl options:nil];
        
        CMTimeRange timeRange;
        timeRange = CMTimeRangeMake(CMTimeMakeWithSeconds(model.beginTime, EDIT_VIDEO_FPS), CMTimeMakeWithSeconds(model.endTime - model.beginTime, EDIT_VIDEO_FPS));
        
        //插入原始音频
        [self insertAudioOriginalWithAsset:asset audioTrack:self.audioTrack timeRange:timeRange startTime:totalDuration failureBlock:^(NSError *error) {
            if (failureBlock) {
                failureBlock(error);
                return;
            }
        }];
        
        //插入原始视频
        [self insertVideoOriginalWithAsset:asset videoTrack:self.videoTrack timeRange:timeRange startTime:totalDuration failureBlock:^(NSError *error) {
            if (failureBlock) {
                failureBlock(error);
                return;
            }
        }];
        
        CMTime assetTime = CMTimeMakeWithSeconds(model.endTime - model.beginTime, EDIT_VIDEO_FPS);
        totalDuration = CMTimeAdd(totalDuration, assetTime);
    }
}

#pragma mark ---插入修剪音视频（转场淡入淡出）
- (void)combineTransFadeInoutVideoAndAudio:(NSArray *)assetModelsArr
                          WithFailureBlock:(void (^)(NSError *error))failureBlock {
    
    //Step 2
    CMTime transTotalDuration = kCMTimeZero;
    CMTime transBgTotalDuration = kCMTimeZero;
    
    for (int i = 0; i < assetModelsArr.count; i++) {
        
        SNHVideoModel *model = assetModelsArr[i];
        AVURLAsset *asset = [[AVURLAsset alloc]initWithURL:model.assetUrl options:nil];
        
        //淡入淡出效果
        CMTimeRange transTimeRange;
        if (i == 0) {
            transTimeRange = CMTimeRangeMake(CMTimeMakeWithSeconds(model.beginTime, EDIT_VIDEO_FPS), CMTimeMakeWithSeconds(model.endTime - model.beginTime, EDIT_VIDEO_FPS));
        }else {
            transTimeRange = CMTimeRangeMake(CMTimeMakeWithSeconds(model.beginTime + animationDur, EDIT_VIDEO_FPS), CMTimeMakeWithSeconds(model.endTime - model.beginTime - animationDur, EDIT_VIDEO_FPS));
        }
        
        [self insertAudioOriginalWithAsset:asset audioTrack:self.transAudioTrack timeRange:transTimeRange startTime:transTotalDuration failureBlock:^(NSError *error) {
            if (failureBlock) {
                failureBlock(error);
                return;
            }
        }];
        
        [self insertVideoOriginalWithAsset:asset videoTrack:self.transVideoTrack timeRange:transTimeRange startTime:transTotalDuration failureBlock:^(NSError *error) {
            if (failureBlock) {
                failureBlock(error);
                return;
            }
        }];
        
        CMTime transAssetTime;
        if (i == 0) {
            transAssetTime = CMTimeMakeWithSeconds(model.endTime - model.beginTime, EDIT_VIDEO_FPS);
        }else {
            transAssetTime = CMTimeMakeWithSeconds(model.endTime - model.beginTime - animationDur, EDIT_VIDEO_FPS);
        }
        transTotalDuration = CMTimeAdd(transTotalDuration, transAssetTime);
        
        
        //背景淡入淡出
        CMTimeRange transBgTimeRange = CMTimeRangeMake(CMTimeMakeWithSeconds(model.beginTime, EDIT_VIDEO_FPS), CMTimeMakeWithSeconds(model.endTime - model.beginTime - animationDur, EDIT_VIDEO_FPS));
        [self insertVideoOriginalWithAsset:asset videoTrack:self.transVideoBgTrack timeRange:transBgTimeRange startTime:transBgTotalDuration failureBlock:^(NSError *error) {
            if (failureBlock) {
                failureBlock(error);
                return;
            }
        }];
        CMTime transBgAssetTime = CMTimeMakeWithSeconds(model.endTime - model.beginTime - animationDur, EDIT_VIDEO_FPS);
        transBgTotalDuration = CMTimeAdd(transBgTotalDuration, transBgAssetTime);
        
    }
    
}

#pragma mark ---插入音频操作
- (void)insertAudioOriginalWithAsset:(AVAsset *)asset
                          audioTrack:(AVMutableCompositionTrack *)audioTrack
                           timeRange:(CMTimeRange)timeRange
                           startTime:(CMTime)totalDuration
                        failureBlock:(void (^)(NSError *error))failureBlock {
    
    //向音频通道内加入音频
    NSError *erroraudio = nil;
    AVAssetTrack *assetAudioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    BOOL ba = [audioTrack insertTimeRange:timeRange
                                  ofTrack:assetAudioTrack
                                   atTime:totalDuration
                                    error:&erroraudio];
    if (!ba) {
        NSLog(@"erroraudio:%@%d",erroraudio,ba);
        if (failureBlock) {
            failureBlock(erroraudio);
        }
    }
    
}

#pragma mark ---插入视频操作
- (void)insertVideoOriginalWithAsset:(AVAsset *)asset
                          videoTrack:(AVMutableCompositionTrack *)videoTrack
                           timeRange:(CMTimeRange)timeRange
                           startTime:(CMTime)totalDuration
                        failureBlock:(void (^)(NSError *error))failureBlock{
    
    //向视频通道内加入视频
    NSError *errorVideo = nil;
    //获取AVAsset中的视频
    AVAssetTrack *assetVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo]firstObject];
    BOOL bl = [videoTrack insertTimeRange:timeRange
                                  ofTrack:assetVideoTrack
                                   atTime:totalDuration
                                    error:&errorVideo];
    if (!bl) {
        NSLog(@"errorVideo:%@%d",errorVideo,bl);
        if (failureBlock) {
            failureBlock(errorVideo);
        }
    }
    
}



#pragma mark 3.调整输出视频的属性
- (void)ajustOutputVideoProperty {
    
    // Step 3:调整输出视频的属性
    self.videoComposition = [AVMutableVideoComposition videoComposition];
    
    //设置视频的Frame
    self.videoComposition.frameDuration = CMTimeMake(1, EDIT_VIDEO_FPS);
    
    
    //视频输出尺寸
    if (self.renderSize.width == 0 && self.renderSize.height == 0) {
        SNHVideoModel *model = self.datasArr[0];
        AVAsset *asset = [AVAsset assetWithURL:model.assetUrl];
        self.videoComposition.renderSize = [self fixRenderSizeWithAsset:asset];
    }else {
        self.videoComposition.renderSize = self.renderSize;
    }
    
    //视频的转向
    CGAffineTransform videoTransForm;
    if (self.renderSize.width == 0 && self.renderSize.height == 0) {
        SNHVideoModel *model = self.datasArr[0];
        AVAsset *asset = [AVAsset assetWithURL:model.assetUrl];
        videoTransForm = [self fixVideoTransformFromAssert:asset];
        
    }else {
        videoTransForm = self.videoTrack.preferredTransform;
    }
    
    NSLog(@"renderSizeW : %.2f---renderSizeH : %.2f",self.videoComposition.renderSize.width,self.videoComposition.renderSize.height);
    
    
    //创建视频组合指令
    AVMutableVideoCompositionInstruction * avMutableVideoCompositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    //设置指令在视频的起作用范围
    [avMutableVideoCompositionInstruction setTimeRange:CMTimeRangeMake(kCMTimeZero, [self.mixComposition duration])];
    
    if (self.videoTransitionType == SNHVideoTransitionTypeDefault) {
        
        //创建视频图层指令
        AVMutableVideoCompositionLayerInstruction * avMutableVideoCompositionLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:self.videoTrack];
        [avMutableVideoCompositionLayerInstruction setTransform:videoTransForm atTime:kCMTimeZero];
        //把视频图层指令放到视频指令中，再放入视频组合对象中
        avMutableVideoCompositionInstruction.layerInstructions = [NSArray arrayWithObject:avMutableVideoCompositionLayerInstruction];
        self.videoComposition.instructions = [NSArray arrayWithObject:avMutableVideoCompositionInstruction];
        
    }else if(self.videoTransitionType == SNHVideoTransitionTypeFadeInOut){
        
        //创建视频图层指令
        AVMutableVideoCompositionLayerInstruction * avMutableVideoCompositionLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:self.transVideoTrack];
        [avMutableVideoCompositionLayerInstruction setTransform:videoTransForm atTime:kCMTimeZero];
        //创建视频图层指令bg
        AVMutableVideoCompositionLayerInstruction * avMutableVideoCompositionLayerInstruction1 = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:self.transVideoBgTrack];
        [avMutableVideoCompositionLayerInstruction1 setTransform:videoTransForm atTime:kCMTimeZero];
        
        CMTime totalTime = kCMTimeZero;
        for (int i = 0; i < self.datasArr.count - 1; i++) {
            SNHVideoModel *model = self.datasArr[i];
            CGFloat seconds = model.endTime - animationDur;
            totalTime = CMTimeAdd(totalTime, CMTimeMakeWithSeconds(seconds, EDIT_VIDEO_FPS));
            [avMutableVideoCompositionLayerInstruction1 setOpacityRampFromStartOpacity:0.0 toEndOpacity:1.0 timeRange:CMTimeRangeMake(totalTime, CMTimeMakeWithSeconds(animationDur, EDIT_VIDEO_FPS))];
        }
        
        //把视频图层指令放到视频指令中，再放入视频组合对象中
        avMutableVideoCompositionInstruction.layerInstructions = [NSArray arrayWithObjects:avMutableVideoCompositionLayerInstruction1,avMutableVideoCompositionLayerInstruction,nil];
        
        self.videoComposition.instructions = [NSArray arrayWithObject:avMutableVideoCompositionInstruction];
    }
    
}

#pragma mark  4.加logo
- (void)addLogo{
    
    CGSize videoSize = self.videoComposition.renderSize;
    
    CALayer *overlayLayer = [CALayer layer];
    CGRect overlayLayerFrame = CGRectZero;
    
    if (self.logoDirection == SNVideoLogoDirectionLeftBottom) {
        overlayLayerFrame = CGRectMake(0, 0, 96, 96);
        
    }else if(self.logoDirection == SNVideoLogoDirectionLeftTop) {
        overlayLayerFrame = CGRectMake(0, videoSize.height - 96, 96, 96);
        
    }else if (self.logoDirection == SNVideoLogoDirectionRightBottom) {
        overlayLayerFrame = CGRectMake(videoSize.width - 96, 0, 96, 96);
        
    }else if (self.logoDirection == SNVideoLogoDirectionRightTop) {
        overlayLayerFrame = CGRectMake(videoSize.width - 96, videoSize.height - 96, 96, 96);
        
    }
    overlayLayer.frame = overlayLayerFrame;
    
    UIImage *animationImage = [UIImage imageNamed:@"iconforNiusee"];
    [overlayLayer setContents:(id)[animationImage CGImage]];
    [overlayLayer setMasksToBounds:YES];
    
    
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    // 这里看出区别了吧，我们把overlayLayer放在了videolayer的上面，所以水印总是显示在视频之上的。
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:overlayLayer];
    
    self.videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool
                                           videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
}


#pragma mark 5.导出视频
- (void)exportVideoAsynchronouslyWithSuccessBlock:(void (^)(NSURL *outputURL))successBlock
                                     failureBlock:(void (^)(NSError *error))failureBlock {
    
    //0.初始化通道信息
    [self initialHandle];
    
    //1.将视频和音频注入音视频通道
    [self combineAudioAndVideo:self.datasArr WithFailureBlock:^(NSError *error) {
        if (failureBlock) {
            failureBlock(error);
            return;
        }
    }];
    
    
    //2.设置输出视频的属性（大小转像输出类型等）
    [self ajustOutputVideoProperty];
    
    //4.加水印等操作
    if (self.logoDirection != SNVideoLogoDirectionNull) {
        [self addLogo];
    }
    
    //5.视频输出
    self.outputURL = [NSURL fileURLWithPath: self.outPutPath];
    //AVAssetExportPresetPassthrough,预设值,可以让我们在不需要重新对媒体编码的前提下实现写入数据的功能.导出预设用于确定导出内容的质量,大小等属性,用其他的会造成导出后的视频增大
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:self.mixComposition presetName:self.presetName];
    
    exporter.outputURL = self.outputURL;
    exporter.videoComposition = self.videoComposition;
    exporter.outputFileType = self.outputFileType;
    exporter.shouldOptimizeForNetworkUse = self.shouldOptimizeForNetworkUse;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (exporter.status == AVAssetExportSessionStatusCompleted) {
                if (successBlock) {
                    successBlock(self.outputURL);
                }
            }else{
                NSLog(@"exporter %@",exporter.error);
                if (failureBlock) {
                    failureBlock(exporter.error);
                }
                
            }
        });
    }];
    
}

#pragma mark - =================== tools ===================

/**
 *  把视频保存到系统相册
 *  @param successBlock 成功回调
 *  @param failureBlcok 失败回调
 */
- (void)writeVideoToPhotoLibraryWithSuccess:(void (^)(void))successBlock failure:(void (^)(NSError *error))failureBlcok {
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:self.outputURL completionBlock:^(NSURL *assetURL, NSError *error) {
        
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


/**
 返回视频导出格式
 
 @param fileType 视频格式后缀
 @return 视频导出格式，AV开头的
 */
- (NSString *)transOutPutFileType:(NSString *)fileType {
    if ([fileType isEqualToString:@"mov"]) {
        return AVFileTypeQuickTimeMovie;
    }else if ([fileType isEqualToString:@"mp4"]) {
        return AVFileTypeMPEG4;
    }else if ([fileType isEqualToString:@"m4v"]) {
        return AVFileTypeAppleM4V;
    }else if ([fileType isEqualToString:@"m4a"]) {
        return AVFileTypeAppleM4A;
    }else if ([fileType isEqualToString:@"3gp"]) {
        return AVFileType3GPP;
    }else if ([fileType isEqualToString:@"3g2"]){
        return AVFileType3GPP2;
    }else if ([fileType isEqualToString:@"caf"]){
        return AVFileTypeCoreAudioFormat;
    }else if ([fileType isEqualToString:@"wav"]){
        return AVFileTypeWAVE;
    }else if ([fileType isEqualToString:@"aif"]){
        return AVFileTypeAIFF;
    }else if ([fileType isEqualToString:@"aifc"]){
        return AVFileTypeAIFC;
    }else if ([fileType isEqualToString:@"amr"]){
        return AVFileTypeAMR;
    }else if ([fileType isEqualToString:@"mp3"]){
        return AVFileTypeMPEGLayer3;
    }else if ([fileType isEqualToString:@"au"]){
        return AVFileTypeSunAU;
    }else if ([fileType isEqualToString:@"ac3"]){
        return AVFileTypeAC3;
    }else if ([fileType isEqualToString:@"eac3"]){
        return AVFileTypeEnhancedAC3;
    }else {
        return AVFileTypeQuickTimeMovie;
    }
}

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
                  failureBlock:(void(^)(NSError *error))failureBlock{
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    
    NSParameterAssert(asset);
    
    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    
    CMTime curTime = CMTimeMakeWithSeconds(time, 60);
    
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:curTime actualTime:NULL error:&thumbnailImageGenerationError];
    if (!thumbnailImageRef){
        NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
    }
    UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;
    
    if (thumbnailImage != nil) {
        if (successBlock) {
            successBlock(thumbnailImage);
        }
    }else{
        if (failureBlock) {
            failureBlock(thumbnailImageGenerationError);
        }
    }
}


#pragma mark - =================== 调整视频转向 ===================
#pragma mark 调整视频大小
- (CGSize)fixRenderSizeWithAsset:(AVAsset *)videoAsset{
    
    NSInteger degrees = [self degressFromVideoFileWithAsset:videoAsset];
    
    NSArray *tracks = [videoAsset tracksWithMediaType:AVMediaTypeVideo];
    AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
    
    CGSize size;
    if (degrees == 90) {
        // 顺时针旋转90°
        size = CGSizeMake(videoTrack.naturalSize.height,videoTrack.naturalSize.width);
    } else if(degrees == 180){
        // 顺时针旋转180°
        size = CGSizeMake(videoTrack.naturalSize.width,videoTrack.naturalSize.height);
    } else if(degrees == 270){
        // 顺时针旋转270°
        size = CGSizeMake(videoTrack.naturalSize.height,videoTrack.naturalSize.width);
    }else {
        size = CGSizeMake(videoTrack.naturalSize.width, videoTrack.naturalSize.height);
    }
    
    return size;
}

#pragma mark 调整视频转向


- (CGAffineTransform)fixVideoTransformFromAssert:(AVAsset *)assert {
    
    NSInteger degrees = [self degressFromVideoFileWithAsset:assert];
    CGAffineTransform translateToCenter;
    CGAffineTransform mixedTransform = CGAffineTransformIdentity;
    
    NSArray *tracks = [assert tracksWithMediaType:AVMediaTypeVideo];
    AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
    
    if (degrees == 90) {
        // 顺时针旋转90°
        translateToCenter = CGAffineTransformMakeTranslation(videoTrack.naturalSize.height, 0.0);
        mixedTransform = CGAffineTransformRotate(translateToCenter,M_PI_2);
    } else if(degrees == 180){
        // 顺时针旋转180°
        translateToCenter = CGAffineTransformMakeTranslation(videoTrack.naturalSize.width, videoTrack.naturalSize.height);
        mixedTransform = CGAffineTransformRotate(translateToCenter,M_PI);
    } else if(degrees == 270){
        // 顺时针旋转270°
        translateToCenter = CGAffineTransformMakeTranslation(0.0, videoTrack.naturalSize.width);
        mixedTransform = CGAffineTransformRotate(translateToCenter,M_PI_2*3.0);
    }else {
        mixedTransform = CGAffineTransformIdentity;
    }
    return mixedTransform;
}


// 获取视频角度
- (NSInteger)degressFromVideoFileWithAsset:(AVAsset *)asset {
    NSInteger degress = 0;
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        CGAffineTransform t = videoTrack.preferredTransform;
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
            // Portrait
            degress = 90;
        } else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
            // PortraitUpsideDown
            degress = 270;
        } else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
            // LandscapeRight
            degress = 0;
        } else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
            // LandscapeLeft
            degress = 180;
        }
    }
    return degress;
}


@end
