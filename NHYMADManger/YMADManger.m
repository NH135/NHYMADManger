//
//  YMADManger.m
//  YMRichCat
//
//  Created by apple on 2020/7/24.
//  Copyright © 2020 niuhui. All rights reserved.
//

#import "YMADManger.h"
#import "YMGDTManger.h"
#import "YMADNetworkManager.h"
#import "YMADInitConfigModel.h"
#import "GDTSDKConfig.h"
#import "YMUnionManager.h"
#import "YMSigmobManager.h"
#import "YMBaiduADManager.h"
#import <WindSDK/WindSDK.h>

@interface YMADManger()
@property (nonatomic, copy) ScreenADCompleteBlock screenADCompleteBlock;
@property (nonatomic, copy) BannerADCompleteBlock bannerADCompleteBlock;
@property (nonatomic, copy) RewardADCompleteBlock rewardADCompleteBlock;
@property (nonatomic, copy) NativeADCompleteBlock nativeADCompleteBlock;
@property (nonatomic, copy) ShowNativeADfail showNativeADfail;
@property (nonatomic, weak) UIViewController *vc;
@property (nonatomic, strong) NSArray* adArray;
@end

@implementation YMADManger
+ (instancetype)sharedYMADManger {
    static YMADManger *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

/// 初始化广告
- (void) adInit {
    [[YMADNetworkManager sharedYMADNetManager] POSTurl:@"adv/push/getAdvProject" parameters:@{@"project_name":App_Name,@"app_package":App_BuildIdentifier} successBlock:^(id  _Nonnull response) {
        
        NSArray* adModelArray = [response objectForKey:@"advProjectList"];
        YMLog(@"ad init :%@",adModelArray);
        for (int i = 0; i < adModelArray.count; i++) {
            YMADInitConfigModel* ymADInitModel = [YMADInitConfigModel yy_modelWithJSON:[adModelArray objectAtIndex:i]];
            if ([ymADInitModel.ad_name isEqualToString:gdt]) {
                [GDTSDKConfig registerAppId:ymADInitModel.app_id];
            } else if ([ymADInitModel.ad_name isEqualToString:bytedance]) {
                [BUAdSDKManager setAppID:ymADInitModel.app_id];
                [BUAdSDKManager setIsPaidApp:NO];
                [BUAdSDKManager setLoglevel:BUAdSDKLogLevelDebug];
            } else if ([ymADInitModel.ad_name isEqualToString:sigmob]) {
                WindAdOptions *options = [WindAdOptions options];
                options.appId = ymADInitModel.app_id;
                [WindAds startWithOptions:options];
            }
        }
    } failureBlock:^(NSString * _Nonnull error) {
        
    }];
    
}

/// 上报广告信息
- (void)uploadADStatusWith:(NSString *)adjsonString {
    
    [[YMADNetworkManager sharedYMADNetManager] POSTurl:@"adv/push/sendAdvList" parameters:@{@"ad":adjsonString} successBlock:^(id  _Nonnull response) {
        
    } failureBlock:^(NSString * _Nonnull error) {
        
    }];
    
}

- (void) getAdConfig:(void(^)(YMADConfigModel* adConfigModel))configModel{
    [YMWebClient getAdvListSuccess:^(NSMutableDictionary * _Nonnull response) {
        YMLog(@"ad Config :%@",response);
        [self plistSave:response];
        self.adConfigmodel = [YMADConfigModel yy_modelWithJSON:[self getAdDicPlistLoad]];
        configModel(self.adConfigmodel);
    } failure:^(NSString * _Nonnull error) {
   
        self.adConfigmodel = [YMADConfigModel yy_modelWithJSON:[self getAdDicPlistLoad]];
        configModel([YMADConfigModel yy_modelWithJSON:[self getAdDicPlistLoad]]);
    }];
}


-(void) showScreenADSuccess:(ScreenADCompleteBlock)success{
    self.screenADCompleteBlock = success;
    if (!self.adConfigmodel) {
        [self getAdConfig:^(YMADConfigModel * _Nonnull adConfigModel) {
            
            if (!adConfigModel) {
                //拿不到配置，直接返回失败
                self.screenADCompleteBlock(false);
            } else {
                // 有数据，开始加载广告
                [self showScreenwithIndex:0];
            }
        }];
    } else {
        // 有数据，开始加载广告
        [self showScreenwithIndex:0];
    }
}

- (void)showRewardVideoAd:(UIViewController *)viewController
                 tagetKey:(NSString*)key
                  success:(RewardADCompleteBlock)success {
    
    self.vc = viewController;
    self.rewardADCompleteBlock = success;
    if (!self.adConfigmodel) {
        [self getAdConfig:^(YMADConfigModel * _Nonnull adConfigModel) {
            if (!adConfigModel) {
                //拿不到配置，直接返回失败
                self.rewardADCompleteBlock(false,@"");
            } else {
                // 有数据，开始加载广告
                [self showMVwithTagetKey:key index:0];
            }
        }];
    } else {
        // 有数据，开始加载广告
        [self showMVwithTagetKey:key index:0];
    }
}

- (void) showDoworkRewardViodeoAd:(UIViewController*)viewController
                         tagetKey:(NSString*)key
                           adList:(NSArray*)adArray
                          success:(RewardADCompleteBlock)success {
    
    self.vc = viewController;
    self.rewardADCompleteBlock = success;
    self.adArray = [NSArray arrayWithArray:adArray];
    if (!adArray) {
        self.rewardADCompleteBlock(false,@"");
    } else {
        // 有数据，开始加载广告
        [self showWorkMVwithTagetKey:key index:0];
    }
    
}


-(void)showBannerView:(UIViewController *)viewController
                frame:(CGRect )frame
             tagetKey:(NSString*)key
              success:(BannerADCompleteBlock)success {
    self.vc = viewController;
    self.bannerADCompleteBlock = success;
    
    if (!self.adConfigmodel) {
        [self getAdConfig:^(YMADConfigModel * _Nonnull adConfigModel) {
            if (!adConfigModel) {
                //拿不到配置，直接返回失败
                self.bannerADCompleteBlock(false);
            } else {
                // 有数据，开始加载广告
                [self showBannerWithTagetKey:key frame:frame Index:0];
            }
        }];
    } else {
        // 有数据，开始加载广告
        [self showBannerWithTagetKey:key frame:frame Index:0];
    }
}


- (void) showNativeWithTagetKey:(NSString*)key
                       success:(NativeADCompleteBlock)success
                          fail:(ShowNativeADfail) fail {
    
    self.nativeADCompleteBlock = success;
    self.showNativeADfail = fail;
    
    if (!self.adConfigmodel) {
        [self getAdConfig:^(YMADConfigModel * _Nonnull adConfigModel) {
            if (!adConfigModel) {
                //拿不到配置，直接返回失败
                self.showNativeADfail();
            } else {
                // 有数据，开始加载广告
                [self showNativeWithTagetKey:key index:0];
            }
        }];
    } else {
        // 有数据，开始加载广告
        [self showNativeWithTagetKey:key index:0];
    }
}



- (void) showBannerWithTagetKey:(NSString*)key frame:(CGRect)frame Index:(int) index {
    
    int indexAD = index;
    if ([self.adConfigmodel getAdsListWIthTargetKey:key].ads_list.count > indexAD) {
        YMADModel* model =[[self.adConfigmodel getAdsListWIthTargetKey:key].ads_list objectAtIndex:indexAD];
        
        if ([model.ad_name isEqualToString:@"gdt"]) {
            //广点通
            [[YMGDTManger sharedYMGEManger] showGDTUnifiedBannerView:_vc Tag:key frame:frame adModel:model success:^(BOOL isDataLoadSuccess) {
                if (isDataLoadSuccess) {
                    self.bannerADCompleteBlock(true);
                } else {
                    [self showBannerWithTagetKey:key frame:frame Index:indexAD+1];
                }
            }];
        } else {
            // 走下一个渠道广告
            [self showBannerWithTagetKey:key frame:frame Index:indexAD+1];
        }
    } else {
        //循环完毕了。没有加载出广告！直接返回
        self.bannerADCompleteBlock(false);
    }
    
}



- (void) showScreenwithIndex:(int)index{
    int indexAD = index;
    if ([self.adConfigmodel getAdsListWIthTargetKey:kp].ads_list.count > indexAD) {
        YMADModel* model =[[self.adConfigmodel getAdsListWIthTargetKey:kp].ads_list objectAtIndex:indexAD];
        
        if ([model.ad_name isEqualToString:gdt]) {
            //广点通
            [[YMGDTManger sharedYMGEManger] showScreenWithTag:kp ADModel:model success:^(BOOL isDataLoadSuccess) {
               if (isDataLoadSuccess) {
                    self.screenADCompleteBlock(true);
                } else {
                    [self showScreenwithIndex:indexAD+1];
                }
            }];
        } else if ([model.ad_name isEqualToString:bytedance]) {
            // 穿山甲
            [[YMUnionManager sharedYMUNManger] showUnionUnifiedBannerTag:kp adModel:model success:^(BOOL isDataLoadSuccess) {
                if (isDataLoadSuccess) {
                    self.screenADCompleteBlock(true);
                } else {
                    [self showScreenwithIndex:indexAD+1];
                }
            }];
        } else if ([model.ad_name isEqualToString:sigmob]) {
            [[YMSigmobManager sharedSigmobManger] showScreenWithTag:kp ADModel:model success:^(BOOL isDataLoadSuccess) {
                if (isDataLoadSuccess) {
                    self.screenADCompleteBlock(true);
                } else {
                    [self showScreenwithIndex:indexAD+1];
                }
            }];
        } else if ([model.ad_name isEqualToString:baidu]) {
            [[YMBaiduADManager sharedBaiduManger] showScreenWithTag:kp ADModel:model success:^(BOOL isDataLoadSuccess) {
                if (isDataLoadSuccess) {
                    self.screenADCompleteBlock(true);
                } else {
                    [self showScreenwithIndex:indexAD+1];
                }
            }];
        }else {
            [self showScreenwithIndex:indexAD+1];
        }
    } else {
        //循环完毕了。没有加载出广告！直接返回
        self.screenADCompleteBlock(false);
    }
}


- (void) showMVwithTagetKey:(NSString*)key index:(int)index{
    int indexAD = index;
    if ([self.adConfigmodel getAdsListWIthTargetKey:key].ads_list.count > indexAD) {
        YMADModel* model =[[self.adConfigmodel getAdsListWIthTargetKey:key].ads_list objectAtIndex:indexAD];
        
        if ([model.ad_name isEqualToString:gdt]) {
            //广点通
            [[YMGDTManger sharedYMGEManger] showRewardVideoAd:_vc Tag:key withModel:model success:^(BOOL isDataLoadSuccess) {
                if (isDataLoadSuccess) {
                    [self showTosatWithString:@"广点通"];
                    self.rewardADCompleteBlock(true,[NSString stringWithFormat:@"%@_%@",gdt,model.ad_id]);
                } else {
                    [self showMVwithTagetKey:key index:indexAD+1];
                }
            }];
            
        } else if ([model.ad_name isEqualToString:bytedance]){
            // 走下一个渠道广告
            [[YMUnionManager sharedYMUNManger] showRewardVideoTag:key adModel:model success:^(BOOL isDataLoadSuccess) {
                if (isDataLoadSuccess) {
                    [self showTosatWithString:@"穿山甲"];
                    self.rewardADCompleteBlock(true,[NSString stringWithFormat:@"%@_%@",bytedance,model.ad_id]);
                } else {
                    [self showMVwithTagetKey:key index:indexAD+1];
                }
            }];

        } else if ([model.ad_name isEqualToString:sigmob]) {
            [[YMSigmobManager sharedSigmobManger] showLoadRewardWithTag:key ADModel:model success:^(BOOL isDataLoadSuccess) {
                if (isDataLoadSuccess) {
                    [self showTosatWithString:@"Sigmob"];
                    self.rewardADCompleteBlock(true,[NSString stringWithFormat:@"%@_%@",sigmob,model.ad_id]);
                } else {
                    [self showMVwithTagetKey:key index:indexAD+1];
                }
            }];
        } else if ([model.ad_name isEqualToString:@"百度"]||[model.ad_name isEqualToString:baidu]) {
            [[YMBaiduADManager sharedBaiduManger] showLoadRewardWithTag:key ADModel:model success:^(BOOL isDataLoadSuccess) {
                if (isDataLoadSuccess) {
                    [self showTosatWithString:@"百度"];
                    self.rewardADCompleteBlock(true,[NSString stringWithFormat:@"%@_%@",baidu,model.ad_id]);
                } else {
                    [self showMVwithTagetKey:key index:indexAD+1];
                }
            }];
        }else {
            [self showMVwithTagetKey:key index:indexAD+1];
        }
    } else {
        //循环完毕了。没有加载出广告！直接返回
        self.rewardADCompleteBlock(false,@"");
    }
}


- (void) showWorkMVwithTagetKey:(NSString*)key index:(int)index {
    int indexAD = index;
    if (self.adArray.count > indexAD) {
        YMADModel* model =[self.adArray objectAtIndex:indexAD];

        if ([model.ad_name isEqualToString:gdt]) {
            //广点通
            [[YMGDTManger sharedYMGEManger] showRewardVideoAd:_vc Tag:key withModel:model success:^(BOOL isDataLoadSuccess) {
                if (isDataLoadSuccess) {
                    [self showTosatWithString:@"广点通"];
                    self.rewardADCompleteBlock(true,[NSString stringWithFormat:@"%@_%@",gdt,model.ad_id]);
                } else {
                    [self showWorkMVwithTagetKey:key index:indexAD+1];
                }
            }];

        } else if ([model.ad_name isEqualToString:bytedance]){
            // 走下一个渠道广告
            [[YMUnionManager sharedYMUNManger] showRewardVideoTag:key adModel:model success:^(BOOL isDataLoadSuccess) {
                if (isDataLoadSuccess) {
                    [self showTosatWithString:@"穿山甲"];
                    self.rewardADCompleteBlock(true,[NSString stringWithFormat:@"%@_%@",bytedance,model.ad_id]);
                } else {
                    [self showWorkMVwithTagetKey:key index:indexAD+1];
                }
            }];

        } else if ([model.ad_name isEqualToString:sigmob]) {
            [[YMSigmobManager sharedSigmobManger] showLoadRewardWithTag:key ADModel:model success:^(BOOL isDataLoadSuccess) {
                if (isDataLoadSuccess) {
                    [self showTosatWithString:@"Sigmob"];
                    self.rewardADCompleteBlock(true,[NSString stringWithFormat:@"%@_%@",sigmob,model.ad_id]);
                } else {
                    [self showWorkMVwithTagetKey:key index:indexAD+1];
                }
            }];
        } else if ([model.ad_name isEqualToString:@"百度"]||[model.ad_name isEqualToString:baidu]) {
            [[YMBaiduADManager sharedBaiduManger] showLoadRewardWithTag:key ADModel:model success:^(BOOL isDataLoadSuccess) {
                if (isDataLoadSuccess) {
                    [self showTosatWithString:@"百度"];
                    self.rewardADCompleteBlock(true,[NSString stringWithFormat:@"%@_%@",baidu,model.ad_id]);
                } else {
                    [self showWorkMVwithTagetKey:key index:indexAD+1];
                }
            }];
        }else {
            [self showWorkMVwithTagetKey:key index:indexAD+1];
        }
    } else {
        //循环完毕了。没有加载出广告！直接返回
        self.rewardADCompleteBlock(false,@"");
    }
}


- (void) showNativeWithTagetKey:(NSString*)key index:(int) index {
    
    int indexAD = index;
    if ([self.adConfigmodel getAdsListWIthTargetKey:key].ads_list.count > indexAD) {
        YMADModel* model =[[self.adConfigmodel getAdsListWIthTargetKey:key].ads_list objectAtIndex:indexAD];
        
        if ([model.ad_name isEqualToString:gdt]) {
            //广点通
            [[YMGDTManger sharedYMGEManger] showNativeWithTag:key ADModel:model success:^(GDTNativeExpressAdView * _Nonnull expressView) {
                self.nativeADCompleteBlock(expressView);
            } fail:^{
                [self showNativeWithTagetKey:key index:indexAD+1];
            }];
            
        }else if ([model.ad_name isEqualToString:baidu]) {
            //百度
            [[YMBaiduADManager sharedBaiduManger] showNativeWithTag:key ADModel:model success:^(BaiduMobAdNativeAdView * _Nonnull expressView) {
                self.nativeADCompleteBlock(expressView);
                NSLog(@"chengg");
            } fail:^{
                NSLog(@"chenggchenggchenggchengg");
                [self showNativeWithTagetKey:key index:indexAD+1];
            }];
           
            
        } else if([model.ad_name isEqualToString:bytedance]) {
            // 走下一个渠道广告
            [[YMUnionManager sharedYMUNManger] showNativeWithTag:key ADModel:model success:^(BUNativeExpressAdView * _Nonnull expressView) {
                self.nativeADCompleteBlock(expressView);
            } fail:^{
                [self showNativeWithTagetKey:key index:indexAD+1];
            }];
        } else {
            [self showNativeWithTagetKey:key index:indexAD+1];
        }
    } else {
        //循环完毕了。没有加载出广告！直接返回
        self.showNativeADfail();
    }
    
}

- (void) showTosatWithString:(NSString*) str {
#ifdef DEBUG
    [MBProgressHUD showError:[NSString stringWithFormat:@"SHOW %@ AD Success",str]];
#endif
}

- (void)plistSave:(NSDictionary*) dic {
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *filePath = [cachePath stringByAppendingPathComponent:@"adPlist.plist"];
    [@{@"ad":[dic toJson]} writeToFile:filePath atomically:YES];
}

- (NSDictionary*)getAdDicPlistLoad {
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *filePath = [cachePath stringByAppendingPathComponent:@"adPlist.plist"];
    NSDictionary *t = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSLog(@"%@",t);
    return [[t objectForKey:@"ad"] turnJsonDict];
}

@end
