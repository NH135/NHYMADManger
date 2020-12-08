//
//  YMSigmobManager.h
//  YMRichCat
//
//  Created by apple on 2020/8/7.
//  Copyright © 2020 niuhui. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ShowADSuccessBlock)(BOOL isDataLoadSuccess);

@interface YMSigmobManager : NSObject
+ (instancetype)sharedSigmobManger;

/**
 启动开屏广告
 */
-(void)showScreenWithTag:(NSString*)keyOption ADModel:(YMADModel*)adModel success:(ShowADSuccessBlock)success;

/**
 激励视频
 */
- (void) showLoadRewardWithTag:(NSString*)keyOption ADModel:(YMADModel*)adModel success:(ShowADSuccessBlock)success;

@end

NS_ASSUME_NONNULL_END
