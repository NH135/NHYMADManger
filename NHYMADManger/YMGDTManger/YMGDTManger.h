//
//  YMGDTManger.h
//  YMRichCat
//
//  Created by apple on 2020/7/2.
//  Copyright © 2020 niuhui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YMADConfigModel.h"
#import "GDTRewardVideoAd.h"
#import "GDTSplashAd.h"
#import "GDTUnifiedBannerView.h"
#import "GDTNativeExpressAd.h"
#import "GDTNativeExpressAdView.h"
NS_ASSUME_NONNULL_BEGIN

/**
激励视频数据请求结果，如果数据加载成功则即将显示

@param isDataLoadSuccess 数据是否加载成功
*/
typedef void(^ShowADSuccessBlock)(BOOL isDataLoadSuccess);

typedef void(^ShowNativeADSuccessBlock)(GDTNativeExpressAdView *expressView);
typedef void(^ShowNativeADfail)(void);

@interface YMGDTManger : NSObject
+ (instancetype)sharedYMGEManger;

/**
 banner广告
 */
-(void)showGDTUnifiedBannerView:(UIViewController *)view
                            Tag:(NSString*)keyOption
                          frame:(CGRect )frame
                        adModel:(YMADModel*)model
                        success:(ShowADSuccessBlock)success;

-(void)removeGDTUnifiedBannerView;

/**
 启动开屏广告
 */
-(void)showScreenWithTag:(NSString*)keyOption ADModel:(YMADModel*)adModel success:(ShowADSuccessBlock)success;

/**
 展示激励视频
 
 @param viewController 当前控制器
 @param success 播放成功回调
 */
- (void)showRewardVideoAd:(UIViewController *)viewController Tag:(NSString*)keyOption withModel:(YMADModel*)model  success:(ShowADSuccessBlock)success;

/*
 原生广告
 */

- (void) showNativeWithTag:(NSString*)keyOption ADModel:(YMADModel*) adModel success:(ShowNativeADSuccessBlock)success fail:(ShowNativeADfail) fail;

@end

NS_ASSUME_NONNULL_END
