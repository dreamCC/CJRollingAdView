//
//  CJRollingAdView.h
//  CJModule
//
//  Created by 仁和Mac on 2018/7/2.
//  Copyright © 2018年 zhucj. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CJRollingAdViewDelegate<NSObject>

-(void)touchAdvertisement:(NSString *)advertisementContent;

@end

@interface CJRollingAdView : UIView

/// 滚动时间，默认 0.5f
@property(nonatomic, assign) NSTimeInterval rollingDuration UI_APPEARANCE_SELECTOR;

/// 滚动间隔，默认 3.f
@property(nonatomic, assign) NSTimeInterval rollingInterval UI_APPEARANCE_SELECTOR;

/// 广告颜色， 默认 lightGrayColor
@property(nonatomic, strong) UIColor *adColor UI_APPEARANCE_SELECTOR;

/// 广告字体， 默认 15
@property(nonatomic, strong) UIFont *adFont UI_APPEARANCE_SELECTOR;

/// 广告数组
@property(nonatomic,strong) NSArray<NSString *> *advertisements;


@property(nonatomic, weak) id<CJRollingAdViewDelegate> delegate;


/// 点击广告，advertisementContent 广告内容
@property(nonatomic, copy) void(^touchAdvertisement)(NSString *advertisementContent);


/**
 初始化

 @param frame frame
 @param advertisements 广告数组
 @return self
 */
-(instancetype)initWithFrame:(CGRect)frame advertisements:(NSArray<NSString *> *)advertisements;


/**
 开始动画
 */
-(void)startAnimation;


/**
 停止动画，定时器并不会销毁，可以通过startAnimation继续动画
 */
-(void)pauseAnimation;
@end

@interface CJRollingAdView (UIAppearance)
+(instancetype)appearance;
@end
