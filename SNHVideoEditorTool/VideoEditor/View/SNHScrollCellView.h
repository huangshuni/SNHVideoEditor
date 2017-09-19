//
//  SNHScrollCellView.h
//  testScrollCell
//
//  Created by huangshuni on 2017/7/13.
//  Copyright © 2017年 huangshuni. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SNHScrollCellViewDelegate <NSObject>

- (void)SNHScrollCellViewDidDeleteItem:(NSIndexPath *)indexPath;
- (void)SNHScrollCellViewDidMoveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath;

@end

@interface SNHScrollCellView : UIView

@property (nonatomic, strong) NSMutableArray *datasArr;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, weak) id <SNHScrollCellViewDelegate > delegate;

@end
