//
//  YMGDTManger.m
//  YMRichCat
//
//  Created by apple on 2020/7/2.
//  Copyright © 2020 niuhui. All rights reserved.
//

#import "YMGDTManger.h"



@interface YMGDTManger ()<GDTRewardedVideoAdDelegate,GDTSplashAdDelegate,GDTUnifiedBannerViewDelegate,GDTNativeExpressAdDelegete>
@property (nonatomic, copy) ShowADSuccessBlock showSuccessBlock;
@property (nonatomic, copy) ShowNativeADSuccessBlock showNativeSuccessBlock;
@property (nonatomic, copy) ShowNativeADfail showNativeADfail;
@property (nonatomic,strong) GDTRewardVideoAd *rewardVideoAd;
@property (nonatomic, strong) GDTUnifiedBannerView *bannerView;//GDT底部banner广告
@property (nonatomic, weak) UIViewController *vc;
@property (nonatomic, strong) GDTSplashAd *splashAd;
@property (nonatomic, strong) GDTNativeExpressAd *nativeExpressAd;
@property (nonatomic,assign)BOOL isRead;
@property (nonatomic,copy) NSString* key;//广告标识，广告的位置
@property (nonatomic,strong) YMADModel* model;
@end


@implementation YMGDTManger
+ (instancetype)sharedYMGEManger {
    static YMGDTManger *instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
       
    });
    
    return instance;
}

/**
 banner广告
 */
-(void)showGDTUnifiedBannerView:(UIViewController *)view Tag:(NSString*)keyOption frame:(CGRect )frame adModel:(YMADModel*)model  success:(ShowADSuccessBlock)success{
    YMLog(@"%@======%@",self.bannerView,self.bannerView.superview);
    self.model = model;
    self.key = keyOption;
    [self uploadUmengADStatus:request];
    if (self.bannerView.superview) {
        [self.bannerView removeFromSuperview];
        self.bannerView = nil;
    }
    self.showSuccessBlock = success;
    self.bannerView = [[GDTUnifiedBannerView alloc] initWithPlacementId:model.ad_id viewController:view];
    self.bannerView.accessibilityIdentifier = @"banner_ad";
    self.bannerView.delegate = self;
    [view.view addSubview:self.bannerView];
    [self.bannerView loadAdAndShow];
}
-(void)removeGDTUnifiedBannerView{
    if (self.bannerView.superview) {
        [self.bannerView removeFromSuperview];
        self.bannerView = nil;
    }
}
/**
启动开屏广告
*/
-(void)showScreenWithTag:(NSString*)keyOption ADModel:(YMADModel*)adModel success:(ShowADSuccessBlock)success {
    self.model = adModel;
    self.key = keyOption;
    [self uploadUmengADStatus:request];
    self.showSuccessBlock = success;
    self.splashAd = [[GDTSplashAd alloc] initWithPlacementId:adModel.ad_id];
    self.splashAd.delegate = self;
    self.splashAd.fetchDelay = 5;
//    [self.splashAd loadAdAndShowInWindow:YMAppDelegate.getAppDelegate.window];
    [self.splashAd loadAd];
}


- (void)showRewardVideoAd:(UIViewController *)viewController Tag:(NSString*)keyOption withModel:(YMADModel*)model  success:(ShowADSuccessBlock)success {
          [[UIViewController mz_topController].view showDefultGIF];
    [[UIViewController mz_topController].view showDefultGIF];
    self.model = model;
    self.key = keyOption;
    [self uploadUmengADStatus:request];
    self.showSuccessBlock = success;
    self.rewardVideoAd = [[GDTRewardVideoAd alloc] initWithPlacementId:model.ad_id];
    self.rewardVideoAd.delegate = self;
    //      self.rewardVideoAd.videoMuted = NO; // 设置激励视频是否静音
    [self.rewardVideoAd loadAd];
    self.vc=viewController;
    
}

- (void) showNativeWithTag:(NSString*)keyOption ADModel:(YMADModel*) adModel success:(nonnull ShowNativeADSuccessBlock)success fail:(nonnull ShowNativeADfail)fail {
//    adModel.ad_name = @"baidu";
 
    self.model = adModel;
    self.key = keyOption;
    [self uploadUmengADStatus:request];
    self.showNativeSuccessBlock = success;
    self.showNativeADfail = fail;
    self.nativeExpressAd = [[GDTNativeExpressAd alloc] initWithPlacementId:adModel.ad_id adSize:CGSizeMake(kScreen_W-60, 200)];
    self.nativeExpressAd.delegate = self;
    self.nativeExpressAd.maxVideoDuration = 10;
    self.nativeExpressAd.minVideoDuration = 5;
    self.nativeExpressAd.detailPageVideoMuted = YES;
    self.nativeExpressAd.videoAutoPlayOnWWAN = YES;
    [self.nativeExpressAd loadAd:1];
    
}


// 开屏delegate
- (void)splashAdFailToPresent:(GDTSplashAd *)splashAd withError:(NSError *)error
{
    YMLog(@"没有广告");
      self.splashAd = nil;
     if (self.showSuccessBlock) {
         self.showSuccessBlock(NO);
     }
}

/**
*  开屏广告显示成功
*/
- (void)splashAdSuccessPresentScreen:(GDTSplashAd *)splashAd {
    [self uploadUmengADStatus:success];
}

/**
 *  开屏广告素材加载成功
 */
- (void)splashAdDidLoad:(GDTSplashAd *)splashAd {
    
    if (self.splashAd.isAdValid) {
        [self.splashAd showAdInWindow:YMAppDelegate.getAppDelegate.window withBottomView:nil skipView:nil];
    }
}


/**
 *  开屏广告关闭回调
 */
- (void)splashAdClosed:(GDTSplashAd *)splashAd{
    self.splashAd = nil;
    if (self.showSuccessBlock) {
        self.showSuccessBlock(YES);
    }
}

/**
 *  开屏广告曝光回调
 */
- (void)splashAdExposured:(GDTSplashAd *)splashAd {
    [self uploadUmengADStatus:show];
}

/**
 *  开屏广告点击回调
 */
- (void)splashAdClicked:(GDTSplashAd *)splashAd {
    [self uploadUmengADStatus:click];
}


- (void)gdt_rewardVideoAdVideoDidLoad:(GDTRewardVideoAd *)rewardedVideoAd {
    YMLog(@"视频文件加载成功");
        [[UIViewController mz_topController].view lotitleDismss];
    if (!self.rewardVideoAd.isAdValid) {
        //        self.statusLabel.text = @"广告失效，请重新拉取";
        return;
    }
    [self.rewardVideoAd showAdFromRootViewController:self.vc];
    
}
- (void)gdt_rewardVideoAd:(GDTRewardVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error
{
       
         [[UIViewController mz_topController].view lotitleDismss];
    if (error.code == 4014) {
        YMLog(@"请拉取到广告后再调用展示接口");
        //        self.statusLabel.text = @"请拉取到广告后再调用展示接口";
    } else if (error.code == 4016) {
        YMLog(@"应用方向与广告位支持方向不一致");
        //        self.statusLabel.text = @"应用方向与广告位支持方向不一致";
    } else if (error.code == 5012) {
        YMLog(@"广告已过期");
        //        self.statusLabel.text = @"广告已过期";
    } else if (error.code == 4015) {
        YMLog(@"广告已经播放过，请重新拉取");
        //        self.statusLabel.text = @"广告已经播放过，请重新拉取";
    } else if (error.code == 5002) {
        YMLog(@"视频下载失败");
        //        self.statusLabel.text = @"视频下载失败";
        
    } else if (error.code == 5003) {
        YMLog(@"视频播放失败");
        
        //        self.statusLabel.text = @"视频播放失败";
    } else if (error.code == 5004) {
        YMLog(@"没有合适的广告");
        //        self.statusLabel.text = @"没有合适的广告";
    }
    YMLog(@"ERROR: %@", error);
    if (self.showSuccessBlock) {
        self.showSuccessBlock(NO);
    }
}
/**
 视频广告播放达到激励条件回调
 
 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_rewardVideoAdDidRewardEffective:(GDTRewardVideoAd *)rewardedVideoAd{
    YMLog(@"视频广告播放达到激励条件回调");
    self.isRead=YES;
}

/**
 视频广告曝光回调

 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_rewardVideoAdDidExposed:(GDTRewardVideoAd *)rewardedVideoAd {
    [self uploadUmengADStatus:show];
}

-(void)gdt_rewardVideoAdDidPlayFinish:(GDTRewardVideoAd *)rewardedVideoAd{
    YMLog(@"广点通播放完毕");
}
/**
 视频播放页即将展示回调
 
 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_rewardVideoAdWillVisible:(GDTRewardVideoAd *)rewardedVideoAd{
    YMLog(@"视频播放页即将展示回调");
}

/**
 视频播放页关闭回调
 
 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_rewardVideoAdDidClose:(GDTRewardVideoAd *)rewardedVideoAd{
    YMLog(@"视频数据下载成功回调，已经下载过的视频会直接回调");
    if (self.isRead) {
        if (self.showSuccessBlock) {
            self.showSuccessBlock(YES);
        }
    }
}

/**
 视频广告信息点击回调
 
 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_rewardVideoAdDidClicked:(GDTRewardVideoAd *)rewardedVideoAd{
    YMLog(@"视频广告信息点击回调");
    [self uploadUmengADStatus:click];
}

/**
 广告数据加载成功回调
 
 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_rewardVideoAdDidLoad:(GDTRewardVideoAd *)rewardedVideoAd{
    YMLog(@"广告数据加载成功回调");
    [self uploadUmengADStatus:success];
}

/**
 *  请求广告条数据成功后调用
 *  当接收服务器返回的广告数据成功后调用该函数
 */
- (void)unifiedBannerViewDidLoad:(GDTUnifiedBannerView *)unifiedBannerView {
    [self uploadUmengADStatus:success];
    if (self.showSuccessBlock) {
        self.showSuccessBlock(YES);
    }
}

/**
 *  请求广告条数据失败后调用
 *  当接收服务器返回的广告数据失败后调用该函数
 */
- (void)unifiedBannerViewFailedToLoad:(GDTUnifiedBannerView *)unifiedBannerView error:(NSError *)error {
    if (self.showSuccessBlock) {
        self.showSuccessBlock(NO);
    }
}

/**
 *  banner2.0曝光回调
 */
- (void)unifiedBannerViewWillExpose:(GDTUnifiedBannerView *)unifiedBannerView {
    [self uploadUmengADStatus:show];
}

/**
 *  banner2.0点击回调
 */
- (void)unifiedBannerViewClicked:(GDTUnifiedBannerView *)unifiedBannerView {
    [self uploadUmengADStatus:click];
}


- (void)nativeExpressAdSuccessToLoad:(GDTNativeExpressAd *)nativeExpressAd views:(NSArray<__kindof GDTNativeExpressAdView *> *)views {
    [self uploadUmengADStatus:success];
    GDTNativeExpressAdView *expressView = views[0];
    expressView.controller = [UIViewController mz_topController];
    [expressView render];
    [expressView videoDuration];
    self.showNativeSuccessBlock(expressView);
}
- (void)nativeExpressAdRenderFail:(GDTNativeExpressAdView *)nativeExpressAdView
{
    YMLog(@"%s",__FUNCTION__);
    self.showNativeADfail();
}

- (void)nativeExpressAdFailToLoad:(GDTNativeExpressAd *)nativeExpressAd error:(NSError *)error
{
    YMLog(@"%s",__FUNCTION__);
    YMLog(@"Express Ad Load Fail : %@",error);
    self.showNativeADfail();
}

/**
 * 原生模板广告曝光回调
 */
- (void)nativeExpressAdViewExposure:(GDTNativeExpressAdView *)nativeExpressAdView {
    [self uploadUmengADStatus:show];
}

/**
 * 原生模板广告点击回调
 */
- (void)nativeExpressAdViewClicked:(GDTNativeExpressAdView *)nativeExpressAdView {
    
    [self uploadUmengADStatus:click];
    
}


- (void) uploadUmengADStatus:(NSString*)status{
    [YMUMStatistics DIYStatisticswithName:@"AllAdSend" param:@{@"gdt":[NSString stringWithFormat:@"%@_%@_%@",_key,status,_model.ad_id]}];
}



-(void)dealloc {
    self.rewardVideoAd.delegate = nil;
    self.rewardVideoAd = nil;
}
@end
