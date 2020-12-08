//
//  YMADManger.h
//  YMRichCat
//
//  Created by apple on 2020/7/24.
//  Copyright © 2020 niuhui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YMADConfigModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^ScreenADCompleteBlock)(BOOL isDataLoadSuccess);
typedef void(^BannerADCompleteBlock)(BOOL isDataLoadSuccess);
typedef void(^RewardADCompleteBlock)(BOOL isDataLoadSuccess,NSString* ad_id);
typedef void(^NativeADCompleteBlock)(UIView *expressView);
typedef void(^ShowNativeADfail)(void);

@interface YMADManger : NSObject

+ (instancetype)sharedYMADManger;

@property (nonatomic,strong) YMADConfigModel* adConfigmodel;

- (void) adInit;

- (void) uploadADStatusWith:(NSString*) adjsonString;

-(void) getAdConfig:(void(^)(YMADConfigModel* adConfigModel))configModel;


-(void) showScreenADSuccess:(ScreenADCompleteBlock)success;

- (void)showRewardVideoAd:(UIViewController *)viewController
                 tagetKey:(NSString*)key
                  success:(RewardADCompleteBlock)success;

- (void) showDoworkRewardViodeoAd:(UIViewController*)viewController
                         tagetKey:(NSString*)key
                           adList:(NSArray*)adArray
                          success:(RewardADCompleteBlock)success;

-(void)showBannerView:(UIViewController *)viewController
                frame:(CGRect )frame
             tagetKey:(NSString*)key
              success:(BannerADCompleteBlock)success;

- (void) showNativeWithTagetKey:(NSString*)key success:(NativeADCompleteBlock)success fail:(ShowNativeADfail) fail;


@end

NS_ASSUME_NONNULL_END
