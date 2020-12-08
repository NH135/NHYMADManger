//
//  YMADConfigModel.h
//  YMRichCat
//
//  Created by apple on 2020/7/24.
//  Copyright © 2020 niuhui. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YMADModel;
@class YMADConfigListModel;
NS_ASSUME_NONNULL_BEGIN

@interface YMADConfigModel : NSObject
@property (nonatomic,copy) NSString* refreshTime;
@property (nonatomic,strong) NSArray<YMADConfigListModel *>* advList;

- (YMADConfigListModel*) getAdsListWIthTargetKey:(NSString*) key;

@end


@interface YMADConfigListModel : NSObject
@property (nonatomic,copy) NSString* target_key;
@property (nonatomic,copy) NSString* name;
@property (nonatomic,copy) NSString* change_code;
@property (nonatomic,copy) NSString* updated_at;
@property (nonatomic,strong) NSArray<YMADModel *>* ads_list;
@end



@interface YMADModel : NSObject
@property (nonatomic,copy) NSString* app_id;
@property (nonatomic,copy) NSString* ad_name;
@property (nonatomic,copy) NSString* ad_id;
@property (nonatomic,copy) NSString* ad_type;
@property (nonatomic,copy) NSString* task_type;
@property (nonatomic,copy) NSString* jump_addr;
@end


NS_ASSUME_NONNULL_END
