//
//  YMBaiduADManager.h
//  YMRichCat
//
//  Created by apple on 2020/8/10.
//  Copyright © 2020 niuhui. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BaiduMobAdNativeAdView;
NS_ASSUME_NONNULL_BEGIN
typedef void(^ShowADSuccessBlock)(BOOL isDataLoadSuccess);

typedef void(^ShowBaiduNativeADSuccessBlock)(BaiduMobAdNativeAdView *expressView);
typedef void(^ShowBaiduNativeADfail)(void);

@interface YMBaiduADManager : NSObject
+ (instancetype)sharedBaiduManger;


/**
 启动开屏广告
 */
-(void)showScreenWithTag:(NSString*)keyOption ADModel:(YMADModel*)adModel success:(ShowADSuccessBlock)success;

/**
 激励视频
 */
- (void) showLoadRewardWithTag:(NSString*)keyOption ADModel:(YMADModel*)adModel success:(ShowADSuccessBlock)success;
/*
 原生广告
 */

- (void) showNativeWithTag:(NSString*)keyOption ADModel:(YMADModel*) adModel success:(ShowBaiduNativeADSuccessBlock)success fail:(ShowBaiduNativeADfail) fail;

@end

NS_ASSUME_NONNULL_END
