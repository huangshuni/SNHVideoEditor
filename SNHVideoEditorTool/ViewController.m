//
//  ViewController.m
//  SNHVideoEditorTool
//
//  Created by huangshuni on 2017/7/26.
//  Copyright © 2017年 huangshuni. All rights reserved.
//

#import "ViewController.h"
#import "SNHVideoTrimmerController.h"
#import "TZImagePickerController.h"
#import <Photos/Photos.h>

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)selectFromAlbum:(id)sender {
    
    SNHVideoTrimmerController *vc = [[SNHVideoTrimmerController alloc] init];
    vc.videoUrl = [[NSBundle mainBundle] URLForResource:@"ping20s" withExtension:@"mp4"];
    [self.navigationController pushViewController:vc animated:YES];

}
- (IBAction)selectVideoFromLocal:(id)sender {
    
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:nil];
    imagePickerVc.allowPickingVideo = YES;
    imagePickerVc.allowPickingImage = NO;
    imagePickerVc.allowCrop = YES;
    NSInteger width = SCREEN_WIDTH;
    NSInteger Height = (SCREEN_WIDTH / (16.0/9));
    imagePickerVc.cropRect = CGRectMake((SCREEN_WIDTH - width)/2, (SCREEN_HEIGHT - Height)/2, width, Height);
    
    [imagePickerVc setDidFinishPickingVideoHandle:^(UIImage *coverImage,id asset){
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
        PHImageManager *manager = [PHImageManager defaultManager];
        [manager requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            AVURLAsset *urlAsset = (AVURLAsset *)asset;
            NSURL *url = urlAsset.URL;
            dispatch_async(dispatch_get_main_queue(), ^{
                SNHVideoTrimmerController *vc = [[SNHVideoTrimmerController alloc] init];
                vc.videoUrl = url;
                [self.navigationController pushViewController:vc animated:YES];
            });
        }];
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
    
}



@end
