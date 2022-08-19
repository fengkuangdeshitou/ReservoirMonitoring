//
//  Request.m
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/5/24.
//

#import "Request.h"
#import "AFNetworking.h"
#import "GlobelDescAlertView.h"
@import CoreTelephony;
#import "Reachability.h"
#import "UIView+Hud.h"

@interface Request ()

@property(nonatomic,strong) AFHTTPSessionManager *manager;
@property(nonatomic,strong) NSMutableDictionary *headers;
@property(nonatomic,assign) BOOL isConnect;
@property(nonatomic,strong) Reachability * reach;

@end

@implementation Request

static Request * _request = nil;

+ (instancetype)shareInstance{
    if (_request == nil) {
        _request = [[Request alloc] init];
        _request.reach.reachableBlock = ^(Reachability *reach){
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"网络可用");
                _request.isConnect = true;
            });
        };
        _request.reach.unreachableBlock = ^(Reachability *reach){
            NSLog(@"网络不可用");
            _request.isConnect = false;
        };
        [_request.reach startNotifier];
    }
    return _request;
}

- (Reachability *)reach{
    if (!_reach) {
        _reach = [Reachability reachabilityWithHostname:@"www.baidu.com"];
    }
    return _reach;
}

- (NSMutableDictionary *)headers{
    if (!_headers) {
        _headers = [[NSMutableDictionary alloc] init];
    }
    [_headers setValue:@"en_US" forKey:@"currentLanguage"];
    if ([NSUserDefaults.standardUserDefaults objectForKey:@"token"]) {
        [_headers setValue:[NSUserDefaults.standardUserDefaults objectForKey:@"token"] forKey:@"Authorization"];
    }
    return _headers;
}

- (AFHTTPSessionManager *)manager{
    if(!_manager){
        _manager = [AFHTTPSessionManager manager];
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _manager.operationQueue.maxConcurrentOperationCount = 1;
        _manager.requestSerializer.timeoutInterval = 20;
    }
    return _manager;
}

- (void)getUrl:(NSString *)url
        params:(NSDictionary *)params
      progress:(RequestProgressBlock)progress
       success:(RequestSuccessBlock)success
       failure:(RequestFailureBlock)failure{
    [UIApplication.sharedApplication.keyWindow showHUDToast:@"Loading"];
    [self.manager GET:[Host stringByAppendingString:url] parameters:params headers:self.headers progress:^(NSProgress * _Nonnull downloadProgress) {
            
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * json = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSString * code = json[@"status"];
        NSLog(@"url=%@,params=%@,result=%@",url,params,json);
        [UIApplication.sharedApplication.keyWindow hiddenHUD];
        if (code.intValue == 200) {
            success(json);
        }else if (code.intValue == 403) {
            [NSUserDefaults.standardUserDefaults removeObjectForKey:@"token"];
            [[NSNotificationCenter defaultCenter] postNotificationName:LOG_OUT object:nil];
            [RMHelper showToast:@"User token expired, please log in again." toView:RMHelper.getCurrentVC.view];
        }else{
            failure(json[@"message"]);
            [RMHelper showToast:json[@"message"] toView:UIApplication.sharedApplication.keyWindow];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"========%ld,%@",error.code,error.userInfo);
        [UIApplication.sharedApplication.keyWindow hiddenHUD];
        [self loadNetworkAlertData:error];
    }];
}

- (void)postUrl:(NSString *)url
         params:(NSDictionary *)params
       progress:(RequestProgressBlock)progress
        success:(RequestSuccessBlock)success
        failure:(RequestFailureBlock)failure{
    [UIApplication.sharedApplication.keyWindow showHUDToast:@"Loading"];
    [self.manager POST:[Host stringByAppendingString:url] parameters:params headers:self.headers progress:^(NSProgress * _Nonnull downloadProgress) {
            
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * json = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSString * code = json[@"status"];
        NSLog(@"url=%@,params:%@,result=%@",url,params,json);
        [UIApplication.sharedApplication.keyWindow hiddenHUD];
        if (code.intValue == 200) {
            success(json);
        }else{
            failure(json[@"message"]);
            [RMHelper showToast:json[@"message"] toView:UIApplication.sharedApplication.keyWindow];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"err=%@",error);
        [UIApplication.sharedApplication.keyWindow hiddenHUD];
        [self loadNetworkAlertData:error];
    }];
}

- (void)putUrl:(NSString *)url
         params:(NSDictionary *)params
        success:(RequestSuccessBlock)success
       failure:(RequestFailureBlock)failure{
    [UIApplication.sharedApplication.keyWindow showHUDToast:@"Loading"];
    [self.manager PUT:[Host stringByAppendingString:url] parameters:params headers:self.headers success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * json = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSString * code = json[@"status"];
        NSLog(@"url=%@,result=%@",url,json);
        [UIApplication.sharedApplication.keyWindow hiddenHUD];
        if (code.intValue == 200) {
            success(json);
        }else{
            failure(json[@"message"]);
            [RMHelper showToast:json[@"message"] toView:UIApplication.sharedApplication.keyWindow];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"err=%@",error);
        [UIApplication.sharedApplication.keyWindow hiddenHUD];
        [self loadNetworkAlertData:error];
    }];
}

- (void)upload:(NSString *)url
        params:(NSDictionary *)params
         image:(UIImage *)image
      progress:(RequestProgressBlock)progress
       success:(RequestSuccessBlock)success
       failure:(RequestFailureBlock)failure{
    [self.manager POST:[Host stringByAppendingString:url] parameters:params headers:self.headers constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 0.4) name:@"file" fileName:@"1.jpg" mimeType:@"image/jpg/png"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * json = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSString * code = json[@"status"];
        NSLog(@"url=%@,result=%@",url,json);
        if (code.intValue == 200) {
            success(json);
        }else{
            failure(json[@"message"]);
            [RMHelper showToast:json[@"message"] toView:RMHelper.getCurrentVC.view];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"err=%@",error);
        [self loadNetworkAlertData:error];
    }];
}

- (void)loadNetworkAlertData:(NSError *)error{
    CTCellularData * cellularData = [[CTCellularData alloc] init];
    cellularData.cellularDataRestrictionDidUpdateNotifier = ^(CTCellularDataRestrictedState restrictedState){
        if (restrictedState == kCTCellularDataRestrictedStateUnknown || restrictedState == kCTCellularDataRestricted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [GlobelDescAlertView showAlertViewWithTitle:@"Tips" desc:@"Network permission required, please go to setting and enable usage" btnTitle:@"Setting" completion:^{
                    [UIApplication.sharedApplication openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {
                                    
                    }];
                }];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error.code == -1001) {
                    [RMHelper showToast:@"Connection timeout. Please try again later" toView:UIApplication.sharedApplication.keyWindow];
                }else if (error.code == -1009 || error.code == -1202) {
                    [RMHelper showToast:@"Network connection failed. Please check the network" toView:UIApplication.sharedApplication.keyWindow];
                }else if (error.code == -1011) {
                    [RMHelper showToast:@"The right resources were not found." toView:UIApplication.sharedApplication.keyWindow];
                }else{
                    [RMHelper showToast:@"unknown error" toView:UIApplication.sharedApplication.keyWindow];
                }
            });
        }
    };
}

- (void)cancelCurrentRequest{
    [self.manager.dataTasks makeObjectsPerformSelector:@selector(cancel)];
}

@end
