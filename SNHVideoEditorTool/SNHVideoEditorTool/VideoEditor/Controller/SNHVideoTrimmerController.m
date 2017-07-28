//
//  SNHVideoTrimmerController.m
//  NiuCam
//
//  Created by huangshuni on 2017/7/13.
//  Copyright © 2017年 Mirco. All rights reserved.
//

#import "SNHVideoTrimmerController.h"
#import "SNHVideoTrimmer.h"
#import "SNHVideoEditor.h"
#import "SNHScrollCellView.h"
#import "MBProgressHUD.h"
#import "SNHVideoEditViewController.h"
#import "NSString+TimeConvert.h"
#import "MBProgressHUD+SHN.h"

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self
#define SCREEN_WIDTH  ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#define DocumentPath ([NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject])

@interface SNHVideoTrimmerController ()<SNHVideoTrimmerDelegate>

@property (strong, nonatomic) UIView *videoPlayerView;
@property (strong, nonatomic) UIView *videoTrimmerBgView;
@property (strong, nonatomic) SNHVideoTrimmerView *trimmerView;
@property (strong, nonatomic) SNHScrollCellView *scrollCellView;
@property (strong, nonatomic) UIButton *trimBtn;
@property (strong, nonatomic) UIButton *mergeBtn;
@property (strong, nonatomic) UIButton *playBtn;

@property (nonatomic, strong) AVAsset *asset;
@property (assign, nonatomic) BOOL isPlaying;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) NSTimer *playbackTimeCheckerTimer;
@property (assign, nonatomic) CGFloat videoPlaybackPosition;

@property (assign, nonatomic) CGFloat startTime;
@property (assign, nonatomic) CGFloat stopTime;

@property (assign, nonatomic) BOOL restartOnPlay;


//videos trimmed
@property (strong, nonatomic) NSMutableArray *videoPartsArr;

@end

@implementation SNHVideoTrimmerController

#pragma mark - =================== lifecycle ===================
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
    
    [self setupTrimmerView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)dealloc {
    self.player = nil;
    [self stopPlaybackTimeChecker];
}

#pragma mark - =================== setter ===================
-(void)setVideoUrl:(NSURL *)videoUrl {
    _videoUrl = videoUrl;
    
    _asset = [AVURLAsset URLAssetWithURL:_videoUrl options:nil];
}

#pragma mark - =================== define ===================
- (void)backAction {
    [self stopPlaybackTimeChecker];
//    [self deleteTempVideoParts];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 设置播放器和剪切视图
- (void)setupTrimmerView {

    self.playerItem = [AVPlayerItem playerItemWithAsset:self.asset];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.contentsGravity = AVLayerVideoGravityResizeAspect;
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    self.playerLayer.frame = self.videoPlayerView.bounds;
    [self.videoPlayerView.layer addSublayer:self.playerLayer];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnVideoLayer:)];
    [self.videoPlayerView addGestureRecognizer:tap];
    
    self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playBtn.frame = CGRectMake(0, 0, 100, 100);
    self.playBtn.center = self.videoPlayerView.center;
    [self.playBtn setImage:[UIImage imageNamed:@"videoEditor_play_h"] forState:UIControlStateNormal];
    [self.playBtn addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.playBtn];


    self.videoPlaybackPosition = 0;
    [self tapOnVideoLayer:tap];
    
    // set properties for trimmer view
    self.trimmerView = [[SNHVideoTrimmerView alloc] init];
    self.trimmerView.frame = self.videoTrimmerBgView.bounds;
    [self.videoTrimmerBgView addSubview:self.trimmerView];
    [self.trimmerView setThemeColor:[UIColor lightGrayColor]];
    [self.trimmerView setAsset:self.asset];
    [self.trimmerView setShowsRulerView:NO];
    [self.trimmerView setShowsTimerView:YES];
    [self.trimmerView setRulerLabelInterval:10];
    [self.trimmerView setMinLength:3.0];
    [self.trimmerView setTrackerColor:[UIColor cyanColor]];
    [self.trimmerView setDelegate:self];

    // important: reset subviews
    [self.trimmerView resetSubviews];
    
    //刚进入时视频播放器在开始
    [self seekVideoToPos:self.startTime];

}


#pragma mark 点击视频播放器
- (void)tapOnVideoLayer:(UITapGestureRecognizer *)tap
{
    if (self.isPlaying == NO) {
        return;
    }
    self.playBtn.hidden = NO;
    
    if (self.isPlaying) {
        [self.player pause];
        [self stopPlaybackTimeChecker];
    }else {
        if (_restartOnPlay){
            [self seekVideoToPos: self.startTime];
            [self.trimmerView seekToTime:self.startTime];
            _restartOnPlay = NO;
        }
        [self.player play];
        [self startPlaybackTimeChecker];
    }
    self.isPlaying = !self.isPlaying;
    [self.trimmerView hideTracker:!self.isPlaying];
}

#pragma mark 点击播放按钮
- (void)playAction:(UIButton *)btn {
    
    btn.hidden = YES;
    
    if (self.isPlaying) {
        [self.player pause];
        [self stopPlaybackTimeChecker];
    }else {
        if (_restartOnPlay){
            [self seekVideoToPos: self.startTime];
            [self.trimmerView seekToTime:self.startTime];
            _restartOnPlay = NO;
        }
        [self.player play];
        [self startPlaybackTimeChecker];
    }
    self.isPlaying = !self.isPlaying;
    [self.trimmerView hideTracker:!self.isPlaying];
}

- (void)startPlaybackTimeChecker
{
    [self stopPlaybackTimeChecker];
    
    self.playbackTimeCheckerTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(onPlaybackTimeCheckerTimer) userInfo:nil repeats:YES];
}

- (void)stopPlaybackTimeChecker
{
    if (self.playbackTimeCheckerTimer) {
        [self.playbackTimeCheckerTimer invalidate];
        self.playbackTimeCheckerTimer = nil;
    }
}

#pragma mark - PlaybackTimeCheckerTimer

- (void)onPlaybackTimeCheckerTimer
{
    CMTime curTime = [self.player currentTime];
    Float64 seconds = CMTimeGetSeconds(curTime);
    if (seconds < 0){
        seconds = 0; // this happens! dont know why.
    }
    self.videoPlaybackPosition = seconds;
    
    [self.trimmerView seekToTime:seconds];
    
    if (self.videoPlaybackPosition >= self.stopTime) {
        //被注释的三步可以用来重复播放截取片段
//        self.videoPlaybackPosition = self.startTime;
//        [self seekVideoToPos: self.startTime];
//        [self.trimmerView seekToTime:self.startTime];
        
        [self stopPlaybackTimeChecker];
        _restartOnPlay = YES;
        [self.player pause];
        self.isPlaying = NO;
        self.playBtn.hidden = NO;
        [self seekVideoToPos:self.startTime];
        [self.trimmerView seekToTime:self.startTime];
        [self.trimmerView hideTracker:true];
    }
}

- (void)seekVideoToPos:(CGFloat)pos
{
    self.videoPlaybackPosition = pos;
    CMTime time = CMTimeMakeWithSeconds(self.videoPlaybackPosition, self.player.currentTime.timescale);
    //NSLog(@"seekVideoToPos time:%.2f", CMTimeGetSeconds(time));
    [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

#pragma mark 删除视频片段
- (void)deleteVideoPart:(NSIndexPath *)indexPath{
    
    SNHVideoModel *model = self.videoPartsArr[indexPath.row];
    if (model) {
        [self.videoPartsArr removeObjectAtIndex:indexPath.row];
        self.scrollCellView.datasArr = self.videoPartsArr;
    }
    
}


#pragma mark 剪切视频
- (void)trimVideo {

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"请等待...";
    
    WS(ws);
    SNHVideoEditor *editor = [[SNHVideoEditor alloc] init];
    [editor loadAsset:self.videoUrl beginTime:self.startTime endTime:self.stopTime];
    editor.outputFileType = @"mov";
    NSString *name = [NSString getCurrentTime];
    NSString *outputPath = [DocumentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",name]];
    editor.outPutPath = outputPath;
    [editor exportVideoAsynchronouslyWithSuccessBlock:^(NSURL *outputURL) {
         NSLog(@"cut success");
        
        [SNHVideoEditor thumbnailImageForVideo:self.videoUrl atTime:self.startTime successBlock:^(UIImage *image) {
            
            [MBProgressHUD hideHUDForView:ws.view animated:YES];
            SNHVideoModel *model = [[SNHVideoModel alloc] init];
            model.assetUrl = outputURL;
            model.beginTime = self.startTime;
            model.endTime = self.stopTime;
            model.videoImage = image;
            [ws.videoPartsArr addObject:model];
            
            ws.scrollCellView.datasArr = self.videoPartsArr;

        } failureBlock:^(NSError *error) {
             [MBProgressHUD hideHUDForView:ws.view animated:YES];
             [MBProgressHUD showOnlyText:@"裁剪失败" view:ws.view];
        }];
        
        
    } failureBlock:^(NSError *error) {
         NSLog(@"cut failure");
         [MBProgressHUD hideHUDForView:ws.view animated:YES];
         [MBProgressHUD showOnlyText:@"裁剪失败" view:ws.view];
    }];
    

}

#pragma mark 合并视频
- (void)mergeVideo {

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"请等待...";
    
    WS(ws);
    NSString *name = [NSString getCurrentTime];
    
    NSString *videoPath = [DocumentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",name]];
    
    SNHVideoEditor *editor = [[SNHVideoEditor alloc] init];
    [editor loadAssetModels:self.videoPartsArr];
    editor.videoTransitionType = SNHVideoTransitionTypeFadeInOut;
    editor.outPutPath = videoPath;
    editor.outputFileType = @"mp4";
    
    [editor exportVideoAsynchronouslyWithSuccessBlock:^(NSURL *outputURL) {
        NSLog(@"merge success");
        [MBProgressHUD hideHUDForView:ws.view animated:YES];
        
        SNHVideoModel *model = [[SNHVideoModel alloc] init];
        model.assetUrl = outputURL;
        model.beginTime = 0.0;
        model.endTime = CMTimeGetSeconds([[AVAsset assetWithURL:outputURL] duration]);
        NSArray *arr = [NSArray arrayWithObject:model];
        
        SNHVideoEditViewController *vc = [[SNHVideoEditViewController alloc] init];
        vc.urlsArr = arr;
        [self.navigationController pushViewController:vc animated:NO];
        
    } failureBlock:^(NSError *error) {
         NSLog(@"merge failure");
        [MBProgressHUD hideHUDForView:ws.view animated:YES];
        [MBProgressHUD showOnlyText:@"合并失败" view:ws.view];
    }];
}


//ui
- (void)setupUI {
    
    self.view.backgroundColor = [UIColor blackColor];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 20, 44, 44);
    [backBtn setImage:[UIImage imageNamed:@"back12"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    UILabel *titlelable = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, 44)];
    titlelable.textColor = [UIColor whiteColor];
    titlelable.textAlignment = NSTextAlignmentCenter;
    titlelable.font = [UIFont systemFontOfSize:15];
    titlelable.text = @"剪辑视频片段";
    [self.view addSubview:titlelable];
    
    self.trimBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.trimBtn.frame = CGRectMake(SCREEN_WIDTH - 10 - 70, SCREEN_HEIGHT - 10 - 30, 70, 30);
    self.trimBtn.backgroundColor = [UIColor orangeColor];
    [self.trimBtn setTitle:@"添加" forState:UIControlStateNormal];
    self.trimBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [self.trimBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.trimBtn addTarget:self action:@selector(trimVideo) forControlEvents:UIControlEventTouchUpInside];
    self.trimBtn.layer.cornerRadius = 3;
    self.trimBtn.layer.masksToBounds = YES;
    [self.view addSubview:self.trimBtn];
    
    self.mergeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.mergeBtn.frame = CGRectMake(10, SCREEN_HEIGHT - 10 - 30, 70, 30);
    self.mergeBtn.backgroundColor = [UIColor orangeColor];
    [self.mergeBtn setTitle:@"合并" forState:UIControlStateNormal];
    self.mergeBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [self.mergeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.mergeBtn addTarget:self action:@selector(mergeVideo) forControlEvents:UIControlEventTouchUpInside];
    self.mergeBtn.layer.cornerRadius = 3;
    self.mergeBtn.layer.masksToBounds = YES;
    [self.view addSubview:self.mergeBtn];
    
    self.videoTrimmerBgView = [[UIView alloc] initWithFrame:CGRectMake(10, self.mergeBtn.frame.origin.y  - 50 - 60, SCREEN_WIDTH - 20, 60)];
    [self.view addSubview:self.videoTrimmerBgView];
    
    WS(ws);
    CGFloat scrollCellViewH = (SCREEN_WIDTH - 10*2 - 10*3)/4 + 20;
    self.scrollCellView = [[SNHScrollCellView alloc] initWithFrame:CGRectMake(0, self.videoTrimmerBgView.frame.origin.y - 40 - scrollCellViewH, SCREEN_WIDTH, scrollCellViewH)];
    self.scrollCellView.collectionView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.scrollCellView];
    //block action
    self.scrollCellView.deleteBlock = ^(NSIndexPath *indexPath) {
        [ws deleteVideoPart:indexPath];
    };
    
    self.videoPlayerView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(titlelable.frame) + 20, SCREEN_WIDTH, self.scrollCellView.frame.origin.y - (CGRectGetMaxY(titlelable.frame) + 20) - 50)];
    self.videoPlayerView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.videoPlayerView];

    
}

#pragma mark - =================== delegate ===================
#pragma mark  SNHVideoTrimmerDelegate

- (void)trimmerView:(SNHVideoTrimmerView *)trimmerView didChangeLeftPosition:(CGFloat)startTime rightPosition:(CGFloat)endTime
{
    _restartOnPlay = YES;
    [self.player pause];
    self.isPlaying = NO;
    self.playBtn.hidden = NO;
    [self stopPlaybackTimeChecker];
    
    [self.trimmerView hideTracker:true];
    
    if (startTime != self.startTime) {
        //then it moved the left position, we should rearrange the bar
        [self seekVideoToPos:startTime];
    }
    else{ // right has changed
        [self seekVideoToPos:endTime];
    }
    self.startTime = startTime;
    self.stopTime = endTime;
    
}

#pragma mark - =================== setter/getter ===================
-(NSMutableArray *)videoPartsArr {
    if (!_videoPartsArr) {
        _videoPartsArr = [NSMutableArray array];
    }
    return _videoPartsArr;
}


@end
