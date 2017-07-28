//
//  SNHScrollCellView.h
//  testScrollCell
//
//  Created by huangshuni on 2017/7/13.
//  Copyright © 2017年 huangshuni. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ScrollCellDeleteBlcok)(NSIndexPath *indexPath);

@interface SNHScrollCellView : UIView

@property (nonatomic, strong) NSMutableArray *datasArr;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, copy) ScrollCellDeleteBlcok deleteBlock;

@end
