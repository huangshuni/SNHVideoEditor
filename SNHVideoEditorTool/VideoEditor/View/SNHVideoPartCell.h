//
//  SNHVideoPartCell.h
//  SNH
//
//  Created by huangshuni on 2017/7/14.
//  Copyright © 2017年 Mirco. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DeleteVideoBlock)(void);

@interface SNHVideoPartCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *snapImage;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

@property (copy, nonatomic) DeleteVideoBlock deleteBlcok;

@end
