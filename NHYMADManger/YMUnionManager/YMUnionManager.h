//
//  YMUnionManager.h
//  YMRichCat
//
//  Created by apple on 2020/8/7.
//  Copyright © 2020 niuhui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BUAdSDK/BUAdSDK.h>
NS_ASSUME_NONNULL_BEGIN


typedef void(^ShowUnionADSuccessBlock)(BOOL isDataLoadSuccess);

typedef void(^ShowUnionNativeADSuccessBlock)(BUNativeExpressAdView *expressView);
typedef void(^ShowUnionNativeADfail)(void);

@interface YMUnionManager : NSObject
+ (instancetype)sharedYMUNManger;


-(void)showUnionUnifiedBannerTag:(NSString*)keyOption adModel:(YMADModel*)model success:(ShowUnionADSuccessBlock)success;


/*
 原生广告
 */

- (void) showNativeWithTag:(NSString*)keyOption ADModel:(YMADModel*) adModel success:(ShowUnionNativeADSuccessBlock)success fail:(ShowUnionNativeADfail) fail;

- (void)showRewardVideoTag:(NSString*)keyOption adModel:(YMADModel*)model success:(ShowUnionADSuccessBlock)success;

@end

NS_ASSUME_NONNULL_END
