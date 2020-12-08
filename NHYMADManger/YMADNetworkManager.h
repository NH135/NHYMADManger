//
//  YMADNetworkManager.h
//  YMRichCat
//
//  Created by apple on 2020/8/5.
//  Copyright © 2020 niuhui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking-umbrella.h"
NS_ASSUME_NONNULL_BEGIN

#define YMADWeak  __weak __typeof(self) weakSelf = self

/*定义请求类型的枚举 */
typedef NS_ENUM(NSUInteger, YMHttpRequestType) {
    YMHttpRequestTypeGet = 0,                   /* get请求 */
    YMHttpRequestTypePost,                      /* post请求 */
    YMHttpRequestTypePut,                       /* post请求 */
    YMHttpRequestTypeDelete                     /* delete请求 */
};

typedef void(^YMADNetResponseSuccess)(id response);                  /* 定义请求成功的 block */
typedef void(^YMADNetResponseFail)(NSString *error);                  /* 定义请求失败的 block */

@interface YMADNetworkManager : NSObject
/*
 *  获得全局唯一的网络请求实例单例方法
 *
 *  @return 网络请求类YMNetManager单例
 */
+ (YMADNetworkManager *)sharedYMADNetManager;

- (NSURLSessionTask *)GETurl:(NSString *)urlString
                  parameters:(NSDictionary *)parameters
                successBlock:(YMADNetResponseSuccess)successBlock
                failureBlock:(YMADNetResponseFail)failureBlock;

- (NSURLSessionTask *)POSTurl:(NSString *)urlString
                  parameters:(NSDictionary *)parameters
                successBlock:(YMADNetResponseSuccess)successBlock
                failureBlock:(YMADNetResponseFail)failureBlock;

@end


NS_ASSUME_NONNULL_END
