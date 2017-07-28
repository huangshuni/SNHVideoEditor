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

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self
#define SCREEN_WIDTH  ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

@interface SNHVideoEditViewController ()

@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVAsset *asset;

@property (nonatomic, strong) UISlider *timeSlider;

@end

@implementation SNHVideoEditViewController

#pragma mark - =================== life cycle ===================
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
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
    self.timeSlider.maximumValue = model.endTime - model.beginTime;
    self.timeSlider.minimumTrackTintColor = [UIColor orangeColor];
    [self.view addSubview:self.timeSlider];
   
}

- (void)backAction {
    
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - =================== 滑动时间条 ===================
- (void)timeSliderValueChange:(UISlider *)slider {
    NSLog(@"%.2f",slider.value);
    
    [self.player seekToTime:CMTimeMakeWithSeconds(slider.value, 23)];
}


@end
