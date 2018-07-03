
//
//  CJRollingAdView.m
//  CJModule
//
//  Created by 仁和Mac on 2018/7/2.
//  Copyright © 2018年 zhucj. All rights reserved.
//

#import "CJRollingAdView.h"

@implementation CJRollingAdView (UIAppearance)

+(void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self appearance];
    });
}

static CJRollingAdView *rollingAd;
+(instancetype)appearance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!rollingAd) {
            rollingAd = [[CJRollingAdView alloc] init];
            rollingAd.rollingDuration = 0.5f;
            rollingAd.rollingInterval = 3.f;
            rollingAd.adFont  = [UIFont systemFontOfSize:15];
            rollingAd.adColor = [UIColor lightGrayColor];
        }
    });
    return rollingAd;
}
@end

@interface CJRollingAdView()

@property(nonatomic,strong) NSTimer *rollingTimer;

@property(nonatomic,strong) NSMutableArray<UILabel *> *adLabels;

@property(nonatomic,assign) CATransform3D rollingTransform;
@property(nonatomic,assign) CATransform3D hiddenTransform;

@end

@implementation CJRollingAdView


-(instancetype)initWithFrame:(CGRect)frame advertisements:(NSArray *)advertisements {
    self = [super initWithFrame:frame];
    if (self) {
        self.advertisements = advertisements;
        
        [self didInitialize];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame advertisements:nil];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialize];
    }
    return self;
}

-(void)didMoveToSuperview {
    [super didMoveToSuperview];
    [self setupSubViewsTransform];
}

-(void)layoutSubviews {

    for (NSInteger i = 0,count = self.adLabels.count;i < count ; i++) {
        UILabel *adLabel = self.adLabels[i];
        adLabel.frame = self.bounds;
    }
}

// 这里做动画的初始化主要防止在调用self被添加到superview后，再次更改frame（frame不同会导致动画紊乱）
-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    CGFloat translateYZ = CGRectGetHeight(self.frame) * 0.5;
    _rollingTransform = CATransform3DRotate(CATransform3DIdentity, M_PI_2, 1, 0, 0);
    _rollingTransform = CATransform3DTranslate(_rollingTransform, 0, translateYZ, translateYZ);
    
    _hiddenTransform = CATransform3DRotate(CATransform3DIdentity, M_PI_2, 1, 0, 0);
    _hiddenTransform = CATransform3DTranslate(_hiddenTransform, 0, -translateYZ, -translateYZ);
    
    if (!self.adLabels.count) return;
    [self setupSubViewsTransform];
}

-(void)startAnimation {
    if (_rollingInterval <= _rollingDuration) {
        @throw [NSException exceptionWithName:@"滚动时间设置有误 " reason:@"滚动时间rollingInterval不能小于rollingDuration，不然动画出现错乱" userInfo:nil];
        return;
    }
    if (self.rollingTimer) {
        [self.rollingTimer setFireDate:[NSDate date]];
    }
}
-(void)pauseAnimation {
    if (self.rollingTimer) {
        [self.rollingTimer setFireDate:[NSDate distantFuture]];
    }
}

#pragma mark -- private method
-(void)didInitialize {
    if (rollingAd) {
        self.rollingDuration = rollingAd.rollingDuration;
        self.rollingInterval = rollingAd.rollingInterval;
        self.adFont  = rollingAd.adFont;
        self.adColor = rollingAd.adColor;
    }
}

-(void)didInitializeSubviews {
    if (!self.advertisements.count) return;
    [self.adLabels removeAllObjects];
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (NSInteger i = 0,count = self.advertisements.count; i < count; i++) {
        UILabel *adLabel  = [[UILabel alloc] init];
        adLabel.text      = self.advertisements[i];
        adLabel.textColor = self.adColor;
        adLabel.font      = self.adFont;
        adLabel.textAlignment = NSTextAlignmentCenter;
        adLabel.userInteractionEnabled = YES;
        [self addSubview:adLabel];
        [self.adLabels addObject:adLabel];
        
        UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAdLabel:)];
        [adLabel addGestureRecognizer:tapGesture];
    }
}

-(void)setupSubViewsTransform {
    if (self.adLabels.count <= 1) return;
    for (NSInteger i = 0,count = self.adLabels.count;i < count ; i++) {
        UILabel *adLabel = self.adLabels[i];
        if (i != 0) {
            adLabel.layer.transform = _hiddenTransform;
        }
    }
}

-(void)rollingStart {
    if (self.advertisements.count <= 1) {
        [self.rollingTimer setFireDate:[NSDate distantFuture]];
        return;
    }

    UILabel *visibleAdLab = self.adLabels.firstObject;
    UILabel *willVisibleAdLab = self.adLabels[1];
    [UIView animateWithDuration:self.rollingDuration animations:^{
        visibleAdLab.layer.transform = self.rollingTransform;
        willVisibleAdLab.layer.transform = CATransform3DIdentity;
    } completion:^(BOOL finished) {
        if (finished) {
            visibleAdLab.layer.transform = self.hiddenTransform;
            [self.adLabels removeObjectAtIndex:0];
            [self.adLabels addObject:visibleAdLab];
        }
    }];
}

-(void)tapAdLabel:(UITapGestureRecognizer *)tapGesture {
    UILabel *tapLabel = (UILabel *)tapGesture.view;
    !_touchAdvertisement?:_touchAdvertisement(tapLabel.text);
    if ([self.delegate respondsToSelector:@selector(touchAdvertisement:)]) {
        [self.delegate touchAdvertisement:tapLabel.text];
    }
}


-(void)setAdvertisements:(NSArray *)advertisements {
    _advertisements = advertisements;
    [self didInitializeSubviews];
}

-(void)setAdColor:(UIColor *)adColor {
    _adColor = adColor;
    if (self.subviews.count) {
        [self.subviews makeObjectsPerformSelector:@selector(setTextColor:) withObject:adColor];
    }
}

-(void)setAdFont:(UIFont *)adFont {
    _adFont = adFont;
    if (self.subviews.count) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.subviews makeObjectsPerformSelector:@selector(setFont:) withObject:adFont];
        });
    }
}

#pragma mark -- lazy
-(NSTimer *)rollingTimer {
    if (!_rollingTimer) {
        _rollingTimer = [NSTimer timerWithTimeInterval:self.rollingInterval target:self selector:@selector(rollingStart) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.rollingTimer forMode:NSRunLoopCommonModes];
        [_rollingTimer setFireDate:[NSDate distantFuture]];
    }
    return _rollingTimer;
}


-(NSMutableArray<UILabel *> *)adLabels {
    if (!_adLabels) {
        _adLabels = [NSMutableArray array];
    }
    return _adLabels;
}

-(void)dealloc {
    [self.rollingTimer invalidate];
    self.rollingTimer = nil;
}
@end



