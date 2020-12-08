//
//  YMSigmobManager.m
//  YMRichCat
//
//  Created by apple on 2020/8/7.
//  Copyright © 2020 niuhui. All rights reserved.
//

#import "YMSigmobManager.h"
#import "KeychainIDFA.h"
#import <WindSDK/WindSDK.h>
@interface YMSigmobManager()<WindSplashAdDelegate,WindRewardedVideoAdDelegate>
@property (nonatomic, copy) ShowADSuccessBlock showSuccessBlock;
@property (nonatomic,strong) WindSplashAd *splashAd;
@property (nonatomic,copy) NSString* key;//广告标识，广告的位置
@property (nonatomic,strong) YMADModel* model;

@end

@implementation YMSigmobManager
+ (instancetype)sharedSigmobManger {
    static YMSigmobManager *instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
       
    });
    return instance;
}

/**
 启动开屏广告
 */
-(void)showScreenWithTag:(NSString*)keyOption ADModel:(YMADModel*)adModel success:(ShowADSuccessBlock)success {
    
//    NSString *deviceID = [KeychainIDFA IDFA];

    
    self.model = adModel;
    self.key = keyOption;
    [self uploadUmengADStatus:request];
    self.showSuccessBlock = success;
    
    self.splashAd = [[WindSplashAd alloc] initWithPlacementId:adModel.ad_id];
    self.splashAd.delegate = self;
    self.splashAd.fetchDelay = 3;
    [self.splashAd loadAdAndShow];
    
}

- (void) showLoadRewardWithTag:(NSString*)keyOption ADModel:(YMADModel*)adModel success:(ShowADSuccessBlock)success {
    self.model = adModel;
    self.key = keyOption;
    [self uploadUmengADStatus:request];
    self.showSuccessBlock = success;
    
    WindAdRequest *request = [WindAdRequest request];
    //userId可选值
//    request.userId = @"user id";
    //设置delegate
    [[WindRewardedVideoAd sharedInstance] setDelegate:self];
    //执行加载广告
    [[WindRewardedVideoAd sharedInstance] loadRequest:request withPlacementId:adModel.ad_id];
    
}

#pragma mark - WindSplashAdDelegate
//开屏广告展现成功
- (void)onSplashAdSuccessPresentScreen:(WindSplashAd *)splashAd {
    [self uploadUmengADStatus:success];
    [self uploadUmengADStatus:show];
}

//开屏广告加载失败
- (void)onSplashAdFailToPresent:(WindSplashAd *)splashAd withError:(NSError *)error {
    self.splashAd.delegate = nil;
    self.splashAd = nil;
    if (self.showSuccessBlock) {
        self.showSuccessBlock(NO);
    }
}

//开屏广告被点击
- (void)onSplashAdClicked:(WindSplashAd *)splashAd {
    [self uploadUmengADStatus:click];
}

//开屏广告即将关闭
- (void)onSplashAdWillClosed:(WindSplashAd *)splashAd {
    
}

//开屏广告关闭完成
- (void)onSplashAdClosed:(WindSplashAd *)splashAd {
    //释放
    self.splashAd.delegate = nil;
    self.splashAd = nil;
    
    if (self.showSuccessBlock) {
        self.showSuccessBlock(YES);
    }
}


#pragma mark - RewardVideoAd
//加载成功
-(void)onVideoAdLoadSuccess:(NSString * _Nullable)placementId {
    
    BOOL isReady = [[WindRewardedVideoAd sharedInstance] isReady:self.model.ad_id];
    if (isReady) {
        [self uploadUmengADStatus:success];
        [[WindRewardedVideoAd sharedInstance] playAd:[UIViewController mz_topController] withPlacementId:self.model.ad_id options:nil error:nil];
    }
    
}

//开始播放
-(void)onVideoAdPlayStart:(NSString * _Nullable)placementId {
    [self uploadUmengADStatus:show];
}

//点击
-(void)onVideoAdClicked:(NSString * _Nullable)placementId {
    [self uploadUmengADStatus:click];
}

//完成（奖励）广告b关闭
- (void)onVideoAdClosedWithInfo:(WindRewardInfo *)info placementId:(NSString *)placementId {
    //再次加载广告
    if (self.showSuccessBlock) {
        self.showSuccessBlock(YES);
    }
}

//错误
-(void)onVideoError:(NSError *)error placementId:(NSString * _Nullable)placementId {
    if (self.showSuccessBlock) {
        self.showSuccessBlock(NO);
    }
}

//播放出错
- (void)onVideoAdPlayError:(NSError *)error placementId:(NSString *)placementId {
    if (self.showSuccessBlock) {
        self.showSuccessBlock(NO);
    }
}

//视频播放完成
- (void)onVideoAdPlayEnd:(NSString *)placementId {
}

//ad server 返回广告信息
- (void)onVideoAdServerDidSuccess:(NSString *)placementId {
}

//ad server 无广告信息返回
- (void)onVideoAdServerDidFail:(NSString *)placementId {
}


- (void) uploadUmengADStatus:(NSString*)status{
    [YMUMStatistics DIYStatisticswithName:@"AllAdSend" param:@{sigmob:[NSString stringWithFormat:@"%@_%@_%@",_key,status,_model.ad_id]}];
}


@end
