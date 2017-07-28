//
//  SNHVideoTrimmerView.h
//  SNHVideoTrimmerView
//
//  Created by 黄淑妮 on 2017/6/15.
//  Copyright © 2017年 Mirco. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol SNHVideoTrimmerDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface SNHVideoTrimmerView : UIView

// Video to be trimmed
@property (strong, nonatomic, nullable) AVAsset *asset;

// Theme color for the trimmer view
@property (strong, nonatomic) UIColor *themeColor;

// Maximum length for the trimmed video
@property (assign, nonatomic) CGFloat maxLength;

// Minimum length for the trimmed video
@property (assign, nonatomic) CGFloat minLength;

// Show ruler view on the trimmer view or not
@property (assign, nonatomic) BOOL showsRulerView;

// Show timer view on the trimmer view or not
@property (assign, nonatomic) BOOL showsTimerView;

// Number of seconds between 
@property (assign, nonatomic) NSInteger rulerLabelInterval;

// Customize color for tracker
@property (strong, nonatomic) UIColor *trackerColor;

// Custom image for the left thumb
@property (strong, nonatomic, nullable) UIImage *leftThumbImage;

// Custom image for the right thumb
@property (strong, nonatomic, nullable) UIImage *rightThumbImage;

// Custom width for the top and bottom borders
@property (assign, nonatomic) CGFloat borderWidth;

// Custom width for thumb
@property (assign, nonatomic) CGFloat thumbWidth;

// Number of images from frames needed
@property (assign, nonatomic) NSInteger framesNeeded;

@property (weak, nonatomic, nullable) id<SNHVideoTrimmerDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithAsset:(AVAsset *)asset;

- (instancetype)initWithFrame:(CGRect)frame asset:(AVAsset *)asset NS_DESIGNATED_INITIALIZER;

- (void)resetSubviews;

- (void)seekToTime:(CGFloat)startTime;

- (void)hideTracker:(BOOL)flag;

@end

NS_ASSUME_NONNULL_END

@protocol SNHVideoTrimmerDelegate <NSObject>

@optional
- (void)trimmerView:(nonnull SNHVideoTrimmerView *)trimmerView didChangeLeftPosition:(CGFloat)startTime rightPosition:(CGFloat)endTime;
- (void)trimmerViewDidEndEditing:(nonnull SNHVideoTrimmerView *)trimmerView;

@end


