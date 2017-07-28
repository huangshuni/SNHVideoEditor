//
//  SNHTimerView.m
//  SNHTimerView
//
//  Created by huangshuni on 2017/7/27.
//  Copyright © 2017年 Mirco. All rights reserved.
//

#import "SNHTimerView.h"

@implementation SNHTimerView

#pragma mark - =================== life cycle ===================
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self creatUI];
    }
    return self;
}

#pragma mark - =================== define ===================
- (void)creatUI {

    self.totalTimeLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    self.totalTimeLable.font = [UIFont systemFontOfSize:13];
    self.totalTimeLable.textColor = [UIColor whiteColor];
    self.totalTimeLable.textAlignment = NSTextAlignmentCenter;
    self.totalTimeLable.text = @"totalTime";
    [self addSubview:self.totalTimeLable];
    
}

@end
