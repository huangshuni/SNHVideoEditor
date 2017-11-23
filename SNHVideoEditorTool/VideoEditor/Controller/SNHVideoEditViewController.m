//
//  SNHVideoEditViewController.m
//  SNHVideoEditorTool
//
//  Created by huangshuni on 2017/7/27.
//  Copyright © 2017年 huangshuni. All rights reserved.
//

#import "SNHVideoEditViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "SNHVideoModel.h"
#import "SNHVideoTool.h"
#import "MBProgressHUD+SHN.h"

@interface SNHVideoEditViewController ()

@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVAsset *asset;

@property (nonatomic, strong) NSObject *playbackTimeObserver;

@property (nonatomic, strong) UISlider *timeSlider;

@property (nonatomic, strong) UIButton *saveBtn;//保存按钮

@end

@implementation SNHVideoEditViewController

#pragma mark - =================== life cycle ===================
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
    [self addPlayObserver];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - =================== define ===================
- (void)setupUI {

    self.view.backgroundColor = [UIColor blackColor];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 20, 44, 44);
    [backBtn setImage:[UIImage imageNamed:@"back12"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    SNHVideoModel *model = self.urlsArr[0];
    self.asset = [AVAsset assetWithURL:model.assetUrl];
    self.playerItem = [AVPlayerItem playerItemWithAsset:self.asset];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.contentsGravity = AVLayerVideoGravityResizeAspect;
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    self.playerLayer.frame = CGRectMake(0, 100, SCREEN_WIDTH, 200);
    [self.view.layer addSublayer:self.playerLayer];
    [self.player play];
    
    self.timeSlider = [[UISlider alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.playerLayer.frame), SCREEN_WIDTH - 20, 30)];
    [self.timeSlider addTarget:self action:@selector(timeSliderValueChange:) forControlEvents:UIControlEventValueChanged];
    [self.timeSlider setThumbImage:[self thumbImage] forState:UIControlStateNormal];
    self.timeSlider.maximumValue = model.endTime - model.beginTime;
    self.timeSlider.minimumTrackTintColor = [UIColor orangeColor];
    [self.view addSubview:self.timeSlider];
    
    
    self.saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.saveBtn.frame = CGRectMake(SCREEN_WIDTH/2 - 35, CGRectGetMaxY(self.timeSlider.frame) + 100, 70, 30);
    self.saveBtn.backgroundColor = [UIColor orangeColor];
    [self.saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    self.saveBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [self.saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.saveBtn addTarget:self action:@selector(saveVideo) forControlEvents:UIControlEventTouchUpInside];
    self.saveBtn.layer.cornerRadius = 3;
    self.saveBtn.layer.masksToBounds = YES;
    [self.view addSubview:self.saveBtn];
    
}

#pragma mark 保存到系统相册
- (void)saveVideo {
    
    SNHVideoModel *model = self.urlsArr[0];
    [[SNHVideoTool shared] writeVideoToPhotoLibraryWithOutputPath:model.assetUrl success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD showOnlyText:@"保存到系统相册成功" view:self.view];
        });
      
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD showOnlyText:@"保存到系统相册失败" view:self.view];
        });
    }];
}


- (UIImage *)thumbImage{

    CGSize size = CGSizeMake(20, 20);
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor *whiteColor = [UIColor whiteColor];
    CGContextSetFillColorWithColor(context, [whiteColor CGColor]);
    CGContextFillEllipseInRect(context, CGRectMake(0, 0, 20, 20));
    
    UIColor *innerColor = [UIColor orangeColor];
    CGContextSetFillColorWithColor(context, [innerColor CGColor]);
    CGContextFillEllipseInRect(context, CGRectMake(5, 5, 10, 10));
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark 添加观察者
- (void)addPlayObserver{
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObserver {
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    self.playbackTimeObserver = nil;
}

- (void)monitoringPlayback:(AVPlayerItem *)playerItem {
    WS(ws);
    self.playbackTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        CGFloat currentTime = CMTimeGetSeconds(playerItem.currentTime);
        [ws.timeSlider setValue:currentTime];
    }];
}

#pragma mark 返回
- (void)backAction {
    
    [self.navigationController popViewControllerAnimated:NO];
    [self removeObserver];
}

#pragma mark - =================== observer ===================
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItem *playerItem = (AVPlayerItem *)object;
        if ([playerItem status] == AVPlayerItemStatusReadyToPlay) {
             [self monitoringPlayback:self.playerItem];// 监听播放状态
        }
    }
}

#pragma mark - =================== 滑动时间条 ===================
- (void)timeSliderValueChange:(UISlider *)slider {
    NSLog(@"%.2f",slider.value);
    
    [self.player seekToTime:CMTimeMakeWithSeconds(slider.value, 23)];
}


@end
