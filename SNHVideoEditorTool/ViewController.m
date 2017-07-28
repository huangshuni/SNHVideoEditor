//
//  ViewController.m
//  SNHVideoEditorTool
//
//  Created by huangshuni on 2017/7/26.
//  Copyright © 2017年 huangshuni. All rights reserved.
//

#import "ViewController.h"
#import "ZYQAssetPickerController.h"
#import "SNHVideoTrimmerController.h"

@interface ViewController ()<ZYQAssetPickerControllerDelegate,UINavigationControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)selectFromAlbum:(id)sender {
    
//    ZYQAssetPickerController *vc = [[ZYQAssetPickerController alloc]init];
//    vc.maximumNumberOfSelection = 1;
//    vc.delegate = self;
//    [self presentViewController:vc animated:YES completion:nil];
    
    SNHVideoTrimmerController *vc = [[SNHVideoTrimmerController alloc] init];
    vc.videoUrl = [[NSBundle mainBundle] URLForResource:@"ping20s" withExtension:@"mp4"];
    [self.navigationController pushViewController:vc animated:YES];

}

#pragma mark - =================== ZYQAssetPickerControllerDelegate ===================
//选中照片
-(void)assetPickerController:(ZYQAssetPickerController *)picker didFinishPickingAssets:(NSArray *)assets{
    
    for (int i=0; i<assets.count; i++) {
        ALAsset *asset = assets[i];
        ALAssetRepresentation * representation = asset.defaultRepresentation;
//        [self.urlArr addObject:representation.url];
        SNHVideoTrimmerController *vc = [[SNHVideoTrimmerController alloc] init];
        vc.videoUrl = representation.url;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}


@end
