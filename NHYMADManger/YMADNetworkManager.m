//
//  YMADNetworkManager.m
//  YMRichCat
//
//  Created by apple on 2020/8/5.
//  Copyright © 2020 niuhui. All rights reserved.
//

#import "YMADNetworkManager.h"

@implementation YMADNetworkManager

/*
 *  获得全局唯一的网络请求实例单例方法
 *
 *  @return 网络请求类YMNetManager单例
 */
+ (YMADNetworkManager *)sharedYMADNetManager {
    static id sharedYMADNetManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedYMADNetManager = [[super allocWithZone:NULL] init];
    });
    return sharedYMADNetManager;
}

- (AFHTTPSessionManager *)sharedAFManager {
    static AFHTTPSessionManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [AFHTTPSessionManager manager];
        AFHTTPRequestSerializer *request = [AFHTTPRequestSerializer serializer];
        manager.requestSerializer = request;
        manager.requestSerializer.timeoutInterval = 10;
        manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/css",@"text/xml",@"text/plain", @"application/javascript", @"image/jpeg", @"image/png",@"multipart/form-data", @"application/octet-stream", nil];
        /* https 参数配置 */
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
        securityPolicy.allowInvalidCertificates = YES;
        securityPolicy.validatesDomainName = NO;
        manager.securityPolicy = securityPolicy;
        
    });
    
    return manager;
}

- (NSURLSessionTask *)GETurl:(NSString *)urlString
                  parameters:(NSDictionary *)parameters
                successBlock:(YMADNetResponseSuccess)successBlock
                failureBlock:(YMADNetResponseFail)failureBlock {
    return [self ym_requestWithType:YMHttpRequestTypeGet urlString:[NSString stringWithFormat:@"%@%@",[self serverUrl],urlString] parameters:parameters successBlock:successBlock failureBlock:failureBlock];
}

- (NSURLSessionTask *)POSTurl:(NSString *)urlString
                  parameters:(NSDictionary *)parameters
                successBlock:(YMADNetResponseSuccess)successBlock
                failureBlock:(YMADNetResponseFail)failureBlock {
    return [self ym_requestWithType:YMHttpRequestTypePost urlString:[NSString stringWithFormat:@"%@%@",[self serverUrl],urlString] parameters:parameters successBlock:successBlock failureBlock:failureBlock];
}

- (NSURLSessionTask *)ym_requestWithType:(YMHttpRequestType)type
                               urlString:(NSString *)urlString
                              parameters:(NSDictionary *)parameters
                            successBlock:(YMADNetResponseSuccess)successBlock
                            failureBlock:(YMADNetResponseFail)failureBlock {
    
    if (!urlString) {
            return nil;
    }
    /* 检查地址中是否有中文 */
    NSString *URLString = [NSURL URLWithString:urlString] ? urlString : [self strUTF8Encoding:urlString];
    
    NSString *requestType;
    switch (type) {
        case 0:
            requestType = @"GET";
            break;
        case 1:
            requestType = @"POST";
            break;
            
        default:
            break;
    }
    
    NSURLSessionTask *sessionTask = nil;
    YMLogin *login = [YMLogin getInstance];
    [[self sharedAFManager].requestSerializer setValue:@"ios" forHTTPHeaderField:@"platform"];
    [[self sharedAFManager].requestSerializer setValue:@"app_store" forHTTPHeaderField:@"channel"];
    [[self sharedAFManager].requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",login.token] forHTTPHeaderField:@"Authorization"];
    [[self sharedAFManager].requestSerializer setValue:App_Version forHTTPHeaderField:@"version"];
    [[self sharedAFManager].requestSerializer setValue:App_BuildVersion forHTTPHeaderField:@"versionCode"];
    
    YMLog(@"--HTTPRequestHeaders%@",[self sharedAFManager].requestSerializer.HTTPRequestHeaders);
    if (type == YMHttpRequestTypeGet) {
        sessionTask = [[self sharedAFManager] GET:URLString parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (successBlock) {
                if ([self shouldCallBack:responseObject]) {
                    successBlock([responseObject dictionaryForKey:@"data"]?[responseObject dictionaryForKey:@"data"]:responseObject);
                }else{
                    if (failureBlock) {
                        failureBlock([NSString stringWithFormat:@"%@",responseObject[@"msg"]]);
                    }
                }
            }
            YMLog(@"***\n* 请求URL: %@\n* 请求方式: %@\n* 请求param: %@\n* 请求数据成功: %@\n***", URLString, requestType, parameters,responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (failureBlock) {
                if (error.code == -1009 ||error.code == -999  ||error.code == 3840) {
                    failureBlock([NSString stringWithFormat:@"%@",error.localizedDescription]);
                }else if (error.code == -1001){
                    [MBProgressHUD showError:@"网络异常，请检查网络"];
                }else{
                    failureBlock([NSString stringWithFormat:@"%@",error]);
                }
            }
            YMLog(@"***\n* 请求URL: %@\n* 请求方式: %@\n* 请求param: %@\n* 错误信息: %@\n***", URLString, requestType, parameters,error);
            
        }];
    }
    else if (type == YMHttpRequestTypePost) {
        sessionTask = [[self sharedAFManager] POST:URLString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if ([[NSString stringWithFormat:@"%@",responseObject[@"code"]] isEqualToString:@"200"]) {
                if (successBlock) {
                    if ([self shouldCallBack:responseObject]) {
                        successBlock([responseObject dictionaryForKey:@"data"]);
                    }
                }
            }else{
                if (failureBlock) {
                    failureBlock([NSString stringWithFormat:@"%@",responseObject[@"msg"]]);
                }
            }
            
            YMLog(@"***\n* 请求URL: %@\n* 请求方式: %@\n* 请求param: %@* 请求数据成功: %@\n***", URLString, requestType, parameters,responseObject);
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (error.code == -1009 ||error.code == -999 ) {
                failureBlock([NSString stringWithFormat:@"%@",error.localizedDescription]);
            }else if (error.code == -1001){
                [MBProgressHUD showError:@"网络异常，请检查网络"];
            }else{
                failureBlock([NSString stringWithFormat:@"%@",error]);
            }
            
            YMLog(@"***\n* 请求URL: %@\n* 请求方式: %@\n* 请求param: %@* 错误信息: %@\n***", URLString, requestType, parameters,error);
        }];
    }
    return sessionTask;
    
}

- (BOOL)shouldCallBack:(NSDictionary *)resp {
    if ([[resp stringForKey:@"code"] isEqualToString:@"200"]) {
        return YES;
    }
    return NO;
}

#pragma mark - url 中文格式化
- (NSString *)strUTF8Encoding:(NSString *)str {
    return [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

- (NSString *)serverUrl {
#ifdef DEBUG
    return @"https://mmxbltest.higaoyao.com/";
#else
     return @"https://ad.higaoyao.com/";
#endif
    
}

@end
