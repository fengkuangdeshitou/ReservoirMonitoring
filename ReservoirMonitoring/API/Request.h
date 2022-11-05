//
//  Request.h
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/5/24.
//

#import <Foundation/Foundation.h>
#import "RequestURL.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^RequestProgressBlock)(float progress);
typedef void(^RequestSuccessBlock)(NSDictionary * result);
typedef void(^RequestFailureBlock)(NSString *errorMsg);

@interface Request : NSObject

+ (instancetype)shareInstance;

@property(nonatomic,assign) BOOL hiddenHUD;;

- (void)getUrl:(NSString *)url
        params:(NSDictionary *)params
      progress:(RequestProgressBlock)progress
       success:(RequestSuccessBlock)success
       failure:(RequestFailureBlock)failure;

- (void)postUrl:(NSString *)url
         params:(NSDictionary *)params
       progress:(RequestProgressBlock)progress
        success:(RequestSuccessBlock)success
        failure:(RequestFailureBlock)failure;

- (void)putUrl:(NSString *)url
         params:(NSDictionary *)params
        success:(RequestSuccessBlock)success
        failure:(RequestFailureBlock)failure;

- (void)upload:(NSString *)url
        params:(NSDictionary *)params
         image:(UIImage *)image
      progress:(RequestProgressBlock)progress
       success:(RequestSuccessBlock)success
       failure:(RequestFailureBlock)failure;

- (void)upload:(NSString *)url
        params:(NSDictionary *)params
        images:(NSArray<UIImage*> *)images
      progress:(RequestProgressBlock)progress
       success:(RequestSuccessBlock)success
       failure:(RequestFailureBlock)failure;

- (void)cancelCurrentRequest;

@end

NS_ASSUME_NONNULL_END
