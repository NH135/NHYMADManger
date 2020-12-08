//
//  YMBaiduADManager.m
//  YMRichCat
//
//  Created by apple on 2020/8/10.
//  Copyright © 2020 niuhui. All rights reserved.
//

#import "YMBaiduADManager.h"
#import <BaiduMobAdSDK/BaiduMobAdSplash.h>
#import <BaiduMobAdSDK/BaiduMobAdRewardVideo.h>
#import <BaiduMobAdSDK/BaiduMobAdNativeAdView.h>
#import "BaiduMobAdSDK/BaiduMobAdNativeWebView.h"
#import "BaiduMobAdSDK/BaiduMobAdNativeAdDelegate.h"
#import "BaiduMobAdSDK/BaiduMobAdNative.h"
#import "BaiduMobAdSDK/BaiduMobAdNativeAdObject.h"


@interface YMBaiduADManager()<BaiduMobAdSplashDelegate,BaiduMobAdRewardVideoDelegate,BaiduMobAdNativeAdDelegate>
@property (nonatomic, copy) ShowADSuccessBlock showSuccessBlock;
@property (nonatomic,strong) BaiduMobAdSplash *splashAd;
@property (nonatomic, strong) BaiduMobAdRewardVideo *reward;

@property (nonatomic, copy) ShowBaiduNativeADSuccessBlock showNativeSuccessBlock;
@property (nonatomic, copy) ShowBaiduNativeADfail showNativeADfail;
@property (nonatomic, strong)BaiduMobAdNative *native;


@property (nonatomic,copy) NSString* key;//广告标识，广告的位置
@property (nonatomic,strong) YMADModel* model;
@end


@implementation YMBaiduADManager
+ (instancetype)sharedBaiduManger {
    static YMBaiduADManager *instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
       
    });
    return instance;
}

-(void)showScreenWithTag:(NSString*)keyOption ADModel:(YMADModel*)adModel success:(ShowADSuccessBlock)success {
    self.model = adModel;
    self.key = keyOption;
    [self uploadUmengADStatus:request];
    self.showSuccessBlock = success;
    BaiduMobAdSplash *splash = [[BaiduMobAdSplash alloc] init];
    splash.delegate = self;
    splash.AdUnitTag = adModel.ad_id;
    [splash loadAndDisplayUsingKeyWindow:kWindow];
    self.splashAd = splash;
}
/*
 原生广告
 */

- (void) showNativeWithTag:(NSString*)keyOption ADModel:(YMADModel*) adModel success:(ShowBaiduNativeADSuccessBlock)success fail:(ShowBaiduNativeADfail) fail{
    self.model = adModel;
    self.key = keyOption;
    [self uploadUmengADStatus:request];
    self.showNativeSuccessBlock = success;
    self.showNativeADfail = fail;
    
    if (!self.native) {
        self.native = [[BaiduMobAdNative alloc]init];
        self.native.delegate = self;
    }
    self.native.publisherId =adModel.app_id;
    self.native.adId = adModel.ad_id;
//    self.native.publisherId =@"ccb60059";
//    self.native.adId = @"2058621";
    [self.native requestNativeAds];
 
    
}

-(void)nativeAdObjectsSuccessLoad:(NSArray *)nativeAds nativeAd:(BaiduMobAdNative *)nativeAd{
    NSLog(@"信息流广告加载成功");
    if (nativeAds.count) {
        [self uploadUmengADStatus:success];
        BaiduMobAdNativeAdObject *obje = nativeAds[0];
        BaiduMobAdNativeAdView *view = [self createNativeAdViewWithframe:CGRectMake(0, 0, AlertW*1.1194, AlertW*1.1194/1.7857+3*iPhone6_HeightRate) object:obje];
       
        [view loadAndDisplayNativeAdWithObject:obje completion:^(NSArray *errors) {
                        if (!errors) {
                            self.showNativeSuccessBlock(view);
                            [view trackImpression];
                            //UIView *vv = [[UIView alloc]initWithFrame:CGRectMake(10, 100, [UIScreen mainScreen].bounds.size.width, height)];
                            //[kWindow addSubview:vv];
                           // vv.backgroundColor=[UIColor redColor];
                           // [vv addSubview:view];
                        }
        }];
  
    } else {
        self.showNativeADfail();
    }
}
//广告曝光回调
- (void)nativeAdExposure:(UIView *)nativeAdView nativeAdDataObject:(BaiduMobAdNativeAdObject *)object {
    NSLog(@"信息流广告曝光回调:%@ - %@", nativeAdView, object);
}
//广告返回失败
-(void)nativeAdsFailLoad:(BaiduMobFailReason)reason nativeAd:(BaiduMobAdNative *)nativeAd{
        NSLog(@"信息流加载失败:reason = %d",reason);
    self.showNativeADfail();
}
 
#pragma mark - 创建广告视图

- (BaiduMobAdNativeAdView *)createNativeAdViewWithframe:(CGRect)frame object:(BaiduMobAdNativeAdObject *)object {

    //大图
    UIImageView *mainImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, AlertW*1.1194, AlertW*1.1194/1.7857+3*iPhone6_HeightRate)];
    //广告logo
    UIImageView *baiduLogoView = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(mainImageView.frame)-51-15, CGRectGetMaxY(mainImageView.frame)-40, 15, 14)];
    baiduLogoView.contentMode = UIViewContentModeScaleAspectFit;
    UIImageView *adLogoView = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(baiduLogoView.frame), CGRectGetMinY(baiduLogoView.frame), 26, 14)];
    BaiduMobAdNativeAdView *nativeAdView;
 
    if (object.materialType == HTML) {
        ///信息流模版广告 模板广告内部已添加百度广告logo和熊掌，开发者无需添加
        BaiduMobAdNativeWebView *webview = [[BaiduMobAdNativeWebView alloc]initWithFrame:frame andObject:object];
        nativeAdView = [[BaiduMobAdNativeAdView alloc]initWithFrame:frame
                                                            webview:webview];
    } else if (object.materialType == NORMAL) {
//        多图 Demo  单图和多图按需展示
        nativeAdView = [[BaiduMobAdNativeAdView alloc] initWithFrame:frame brandName:nil title:nil text:nil icon:nil mainImage:mainImageView];

        nativeAdView.baiduLogoImageView = baiduLogoView;
        [nativeAdView addSubview:baiduLogoView];
        nativeAdView.adLogoImageView = adLogoView;
        [nativeAdView addSubview:adLogoView];

    }
    
    return nativeAdView;
}
/**
 激励视频
 */
- (void) showLoadRewardWithTag:(NSString*)keyOption ADModel:(YMADModel*)adModel success:(ShowADSuccessBlock)success {
    
    self.model = adModel;
    self.key = keyOption;
    [self uploadUmengADStatus:request];
    self.showSuccessBlock = success;
    
    self.reward = [[BaiduMobAdRewardVideo alloc] init];
    self.reward.delegate = self;
    self.reward.AdUnitTag = adModel.ad_id;
    self.reward.publisherId = adModel.app_id;
    [self.reward load];
}


#pragma mark -- 开屏

/**
 *  广告展示成功
 */
- (void)splashSuccessPresentScreen:(BaiduMobAdSplash *)splash {
    [self uploadUmengADStatus:show];
}

/**
 *  广告展示失败
 */
- (void)splashlFailPresentScreen:(BaiduMobAdSplash *)splash withError:(BaiduMobFailReason) reason {
    [self removeSplash];
    if (self.showSuccessBlock) {
        self.showSuccessBlock(NO);
    }
}

/**
 *  广告被点击
 */
- (void)splashDidClicked:(BaiduMobAdSplash *)splash {
    [self uploadUmengADStatus:click];
}

/**
 *  广告展示结束
 */
- (void)splashDidDismissScreen:(BaiduMobAdSplash *)splash {
    [self removeSplash];
    if (self.showSuccessBlock) {
        self.showSuccessBlock(YES);
    }
}

/**
 *  广告详情页消失
 */
- (void)splashDidDismissLp:(BaiduMobAdSplash *)splash {
    
}


/**
 * 开屏广告请求成功
 *
 * @param splash 开屏广告对象
 */
- (void)splashAdLoadSuccess:(BaiduMobAdSplash *)splash {
    [self uploadUmengADStatus:success];
}

/**
 * 开屏广告请求失败
 *
 * @param splash 开屏广告对象
 */
- (void)splashAdLoadFail:(BaiduMobAdSplash *)splash {
    
}

- (NSString *)publisherId {
    return self.model.app_id;
}

/**
 *  展示结束or展示失败后, 手动移除splash和delegate
 */
- (void) removeSplash {
    if (self.splashAd) {
        self.splashAd.delegate = nil;
        self.splashAd = nil;
    }
}

- (void) removeReward {
    
    if (self.reward) {
        self.reward.delegate = nil;
        self.reward = nil;
    }
    
}


#pragma mark -- 激励视频

- (void)rewardedVideoAdLoaded:(BaiduMobAdRewardVideo *)video {
    [self uploadUmengADStatus:success];
    [self.reward showFromViewController:[UIViewController mz_topController]];
}

- (void)rewardedVideoAdLoadFailed:(BaiduMobAdRewardVideo *)video withError:(BaiduMobFailReason)reason {
    [self removeReward];
    if (self.showSuccessBlock) {
        self.showSuccessBlock(NO);
    }
}

- (void)rewardedVideoAdShowFailed:(BaiduMobAdRewardVideo *)video withError:(BaiduMobFailReason)reason {
    [self removeReward];
    if (self.showSuccessBlock) {
        self.showSuccessBlock(NO);
    }
}

- (void)rewardedVideoAdDidStarted:(BaiduMobAdRewardVideo *)video {
    [self uploadUmengADStatus:show];
}

- (void)rewardedVideoAdDidPlayFinish:(BaiduMobAdRewardVideo *)video {
    
}

- (void)rewardedVideoAdDidClick:(BaiduMobAdRewardVideo *)video withPlayingProgress:(CGFloat)progress {
    [self uploadUmengADStatus:click];
}

- (void)rewardedVideoAdDidClose:(BaiduMobAdRewardVideo *)video withPlayingProgress:(CGFloat)progress {
    [self removeReward];
    if (self.showSuccessBlock) {
        self.showSuccessBlock(YES);
    }
}



- (void) uploadUmengADStatus:(NSString*)status{
    [YMUMStatistics DIYStatisticswithName:@"AllAdSend" param:@{baidu:[NSString stringWithFormat:@"%@_%@_%@",_key,status,_model.ad_id]}];
}

@end
