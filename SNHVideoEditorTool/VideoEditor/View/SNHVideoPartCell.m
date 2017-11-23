//
//  SNHVideoPartCell.m
//  SNH
//
//  Created by huangshuni on 2017/7/14.
//  Copyright © 2017年 Mirco. All rights reserved.
//

#import "SNHVideoPartCell.h"

@implementation SNHVideoPartCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)deleteVideoPartAction:(id)sender {
    
    if (self.deleteBlcok) {
        self.deleteBlcok();
    }
}

@end
