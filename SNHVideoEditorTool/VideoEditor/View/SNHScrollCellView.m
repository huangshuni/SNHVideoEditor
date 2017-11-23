//
//  SNHScrollCellView.m
//  testScrollCell
//
//  Created by huangshuni on 2017/7/13.
//  Copyright © 2017年 huangshuni. All rights reserved.
//

#import "SNHScrollCellView.h"
#import "SNHVideoPartCell.h"
#import "SNHVideoModel.h"

static NSString *SNHVideoPartCellId = @"SNHVideoPartCellId";

@interface SNHScrollCellView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UIView *snapView;
@property (nonatomic, assign) CGSize deltaSize;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;

@end

@implementation SNHScrollCellView

#pragma mark - =================== life cycle ===================
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

#pragma mark - =================== define ===================
- (void)setupUI {
    
    [self addSubview:self.collectionView];
}

//移动数据源
- (void)removeObjectFrom:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    //取出源item数据
    id objc = [_datasArr objectAtIndex:sourceIndexPath.item];
    //从资源数组中移除该数据
    [_datasArr removeObject:objc];
    //将数据插入到资源数组中的目标位置上
    [_datasArr insertObject:objc atIndex:destinationIndexPath.item];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(SNHScrollCellViewDidMoveItemAtIndexPath:toIndexPath:)]) {
        [self.delegate SNHScrollCellViewDidMoveItemAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
    }
    
}

#pragma mark - =================== gesture ===================
- (void)handlelongGesture:(UILongPressGestureRecognizer *)longGesture {
    
    CGPoint location = [longGesture locationInView:self.collectionView];
    NSIndexPath *notsureIndexPath = [self.collectionView indexPathForItemAtPoint:location];
    
    //判断手势状态
    switch (longGesture.state) {
        case UIGestureRecognizerStateBegan:{
            //判断手势落点位置是否在路径上
            if (notsureIndexPath == nil) {
                break;
            }
            
            _currentIndexPath = notsureIndexPath;
            
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:_currentIndexPath];
            self.snapView = [cell snapshotViewAfterScreenUpdates:YES];
            self.deltaSize = CGSizeMake(location.x - cell.frame.origin.x, location.y - cell.frame.origin.y);
            self.snapView.center = cell.center;
            self.snapView.transform = CGAffineTransformMakeScale(1.1, 1.1);
            cell.contentView.alpha = 0.0;
            [self.collectionView addSubview:self.snapView];
        }
            break;
        case UIGestureRecognizerStateChanged:
            
            if (self.snapView == nil) {
                return;
            }
            
            self.snapView.frame = CGRectMake(location.x - self.deltaSize.width, location.y - self.deltaSize.height, self.snapView.frame.size.width, self.snapView.frame.size.height);
            
            if (notsureIndexPath != nil && _currentIndexPath != nil) {
                
                if (notsureIndexPath != _currentIndexPath && notsureIndexPath.section == _currentIndexPath.section) {
                    
                    [self.collectionView moveItemAtIndexPath:_currentIndexPath toIndexPath:notsureIndexPath];
                    //移动数据源
                    [self removeObjectFrom:_currentIndexPath toIndexPath:notsureIndexPath];
                    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:notsureIndexPath];
                    cell.contentView.alpha = 0.0;
                    _currentIndexPath = notsureIndexPath;
                }
            }
            
            break;
        case UIGestureRecognizerStateEnded:
            
            if (_currentIndexPath != nil) {
                UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:_currentIndexPath];
                [UIView animateWithDuration:0.25 animations:^{
                    self.snapView.transform = CGAffineTransformIdentity;
                    self.snapView.frame = cell.frame;
                } completion:^(BOOL finished) {
                    [self.snapView removeFromSuperview];
                    self.snapView = nil;
                    self.currentIndexPath = nil;
                    cell.contentView.alpha = 1.0;
                }];
            }
            
            break;
        default:
            
            break;
    }
}


#pragma mark - =================== delegate ===================
#pragma mark UICollectionViewDelegate/DataSource/DelegateFlowLayout

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.datasArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SNHVideoPartCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SNHVideoPartCellId forIndexPath:indexPath];
    SNHVideoModel *model = self.datasArr[indexPath.row];
    cell.snapImage.image = model.videoImage;
    
    cell.deleteBlcok = ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(SNHScrollCellViewDidDeleteItem:)]) {
            [self.delegate SNHScrollCellViewDidDeleteItem:indexPath];
        }
    };
    
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath{
    //返回YES允许其item移动
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath {
    //取出源item数据
    id objc = [_datasArr objectAtIndex:sourceIndexPath.item];
    //从资源数组中移除该数据
    [_datasArr removeObject:objc];
    //将数据插入到资源数组中的目标位置上
    [_datasArr insertObject:objc atIndex:destinationIndexPath.item];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(SNHScrollCellViewDidMoveItemAtIndexPath:toIndexPath:)]) {
        [self.delegate SNHScrollCellViewDidMoveItemAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
    }
}

#pragma mark - =================== setter/getter ===================
-(UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        CGFloat width = ([UIScreen mainScreen].bounds.size.width - 10*2 - 10*3)/4;
        layout.itemSize = CGSizeMake(width, width);
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerNib:[UINib nibWithNibName:@"SNHVideoPartCell" bundle:nil] forCellWithReuseIdentifier:SNHVideoPartCellId];
        
        UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlelongGesture:)];
        [_collectionView addGestureRecognizer:longGesture];
    }
    return _collectionView;
}

-(void)setDatasArr:(NSMutableArray *)datasArr {
    
    //注意深拷贝和浅拷贝
    _datasArr = [datasArr mutableCopy];
    [self.collectionView reloadData];
}


@end
