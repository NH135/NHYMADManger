//
//  YMUnionManager.m
//  YMRichCat
//
//  Created by apple on 2020/8/7.
//  Copyright © 2020 niuhui. All rights reserved.
//

#import "YMUnionManager.h"
#import <BUAdSDK/BUSplashAdView.h>
@interface YMUnionManager ()<BUSplashAdDelegate,BUNativeExpressAdViewDelegate,BUNativeExpressRewardedVideoAdDelegate>
@property (nonatomic, copy) ShowUnionADSuccessBlock showSuccessBlock;

@property (nonatomic, copy) ShowUnionNativeADSuccessBlock showNativeSuccessBlock;
@property (nonatomic, copy) ShowUnionNativeADfail showNativeADfail;

@property (nonatomic, strong) BUSplashAdView *splashAd;
@property (nonatomic,strong) BUNativeExpressAdManager* nativeExpressAdManager;
@property (nonatomic,strong) BUNativeExpressRewardedVideoAd* rewardedAd;
@property (nonatomic,copy) NSString* key;//广告标识，广告的位置
@property (nonatomic,strong) YMADModel* model;
@end


@implementation YMUnionManager
+ (instancetype)sharedYMUNManger {
    static YMUnionManager *instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
       
    });
    
    return instance;
}

-(void)showUnionUnifiedBannerTag:(NSString*)keyOption adModel:(YMADModel*)model success:(ShowUnionADSuccessBlock)success {
    self.showSuccessBlock = success;
    self.model = model;
    self.key = keyOption;
    [self uploadUmengADStatus:request];
    CGRect frame = [UIScreen mainScreen].bounds;
    self.splashAd = [[BUSplashAdView alloc] initWithSlotID:model.ad_id frame:frame];
    self.splashAd.delegate = self;
    UIWindow *keyWindow = [UIApplication sharedApplication].windows.firstObject;
    [self.splashAd loadAdData];
    [keyWindow.rootViewController.view addSubview:self.splashAd];
    self.splashAd.rootViewController = keyWindow.rootViewController;
    
}

- (void) showNativeWithTag:(NSString*)keyOption ADModel:(YMADModel*) adModel success:(ShowUnionNativeADSuccessBlock)success fail:(ShowUnionNativeADfail) fail {
    self.model = adModel;
    self.key = keyOption;
    [self uploadUmengADStatus:request];
    self.showNativeSuccessBlock = success;
    self.showNativeADfail = fail;
    
    
    BUAdSlot *slot1 = [[BUAdSlot alloc] init];
    slot1.ID = adModel.ad_id;
    slot1.AdType = BUAdSlotAdTypeFeed;
    BUSize *imgSize = [BUSize sizeBy:BUProposalSize_Feed228_150];
    slot1.imgSize = imgSize;
    slot1.position = BUAdSlotPositionFeed;
    slot1.isSupportDeepLink = YES;
    self.nativeExpressAdManager = [[BUNativeExpressAdManager alloc] initWithSlot:slot1 adSize:CGSizeMake(AlertW*1.1194, AlertW*1.1194/1.7857+3*iPhone6_HeightRate)];
    self.nativeExpressAdManager.delegate = self;
    [self.nativeExpressAdManager loadAd:1];
}

- (void)showRewardVideoTag:(NSString*)keyOption adModel:(YMADModel*)model success:(ShowUnionADSuccessBlock)success {
    self.showSuccessBlock = success;
    self.model = model;
    self.key = keyOption;
    [self uploadUmengADStatus:request];
    BURewardedVideoModel *vidoModel = [[BURewardedVideoModel alloc] init];
    vidoModel.userId = @"123";
    self.rewardedAd = [[BUNativeExpressRewardedVideoAd alloc] initWithSlotID:model.ad_id rewardedVideoModel:vidoModel];
    self.rewardedAd.delegate = self;
    [self.rewardedAd loadAdData];
    
}


#pragma mark -- 开屏回调
-(void)splashAdDidLoad:(BUSplashAdView *)splashAd {
    [self uploadUmengADStatus:success];
}
- (void)splashAdWillVisible:(BUSplashAdView *)splashAd {
    [self uploadUmengADStatus:show];
}
-(void)splashAd:(BUSplashAdView *)splashAd didFailWithError:(NSError *)error {
    self.splashAd = nil;
    if (self.showSuccessBlock) {
        self.showSuccessBlock(NO);
    }
}
-(void)splashAdDidClose:(BUSplashAdView *)splashAd {
    [splashAd removeFromSuperview];
    self.splashAd = nil;
    if (self.showSuccessBlock) {
        self.showSuccessBlock(YES);
    }
}
-(void)splashAdDidClick:(BUSplashAdView *)splashAd {
    [self uploadUmengADStatus:click];
}

#pragma mark -- 原生回调
- (void)nativeExpressAdSuccessToLoad:(BUNativeExpressAdManager *)nativeExpressAd views:(NSArray<__kindof BUNativeExpressAdView *> *)views {
    if (views.count) {
        [self uploadUmengADStatus:success];
        BUNativeExpressAdView *expressView = (BUNativeExpressAdView *)[views objectAtIndex:0];
        expressView.rootViewController = [UIViewController mz_topController];
        [expressView render];
        self.showNativeSuccessBlock(expressView);
    } else {
        self.showNativeADfail();
    }
}

- (void)nativeExpressAdFailToLoad:(BUNativeExpressAdManager *)nativeExpressAd error:(NSError *)error {
    self.showNativeADfail();
}

- (void)nativeExpressAdViewRenderSuccess:(BUNativeExpressAdView *)nativeExpressAdView {
    [self uploadUmengADStatus:show];
}

- (void)nativeExpressAdViewDidClick:(BUNativeExpressAdView *)nativeExpressAdView {
    [self uploadUmengADStatus:click];
}

#pragma mark -- 视频
- (void)nativeExpressRewardedVideoAdDidLoad:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    [self uploadUmengADStatus:success];
    [rewardedVideoAd showAdFromRootViewController:[UIViewController mz_topController]];
}

- (void)nativeExpressRewardedVideoAd:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    if (self.showSuccessBlock) {
        self.showSuccessBlock(NO);
    }
}

- (void)nativeExpressRewardedVideoAdDidClick:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    [self uploadUmengADStatus:click];
}

- (void)nativeExpressRewardedVideoAdViewRenderSuccess:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    
    [self uploadUmengADStatus:show];
}

- (void)nativeExpressRewardedVideoAdDidClose:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    if (self.showSuccessBlock) {
        self.showSuccessBlock(true);
    }
}





- (void) uploadUmengADStatus:(NSString*)status{
    [YMUMStatistics DIYStatisticswithName:@"AllAdSend" param:@{bytedance:[NSString stringWithFormat:@"%@_%@_%@",_key,status,_model.ad_id]}];
}

-(void)dealloc {

}

@end
