//
//  YMADConfigModel.m
//  YMRichCat
//
//  Created by apple on 2020/7/24.
//  Copyright © 2020 niuhui. All rights reserved.
//

#import "YMADConfigModel.h"


@implementation YMADConfigModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"advList":[YMADConfigListModel class]};
}

- (YMADConfigListModel*) getAdsListWIthTargetKey:(NSString*) key {
    for (YMADConfigListModel* model in self.advList) {
        if ([model.target_key isEqualToString:key]) {
            return model;
        }
    }
    return nil;
}

@end

@implementation YMADConfigListModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"ads_list":[YMADModel class]};
}
@end


@implementation YMADModel

@end
