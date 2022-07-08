//
//  Request.m
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/5/24.
//

#import "Request.h"
#import "AFNetworking.h"
@import MBProgressHUD;

@interface Request ()

@property(nonatomic,strong) AFHTTPSessionManager *manager;
@property(nonatomic,strong) NSMutableDictionary *headers;
@property(nonatomic,strong) MBProgressHUD *hud;

@end

@implementation Request

static Request * _request = nil;

+ (instancetype)shareInstance{
    if (_request == nil) {
        _request = [[Request alloc] init];
    }
    return _request;
}

- (MBProgressHUD *)hud{
    if (!_hud) {
        _hud = [[MBProgressHUD alloc] init];
    }
    _hud.mode = MBProgressHUDModeIndeterminate;
    _hud.removeFromSuperViewOnHide = true;
    _hud.label.text = @"Loading";
    _hud.contentColor = UIColor.whiteColor;
    _hud.bezelView.color = [UIColor colorWithHexString:@"#181818"];
    _hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    [UIApplication.sharedApplication.keyWindow addSubview:_hud];
    return _hud;
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
        _manager.operationQueue.maxConcurrentOperationCount = 5;
        _manager.requestSerializer.timeoutInterval = 5;
    }
    return _manager;
}

- (void)getUrl:(NSString *)url
        params:(NSDictionary *)params
      progress:(RequestProgressBlock)progress
       success:(RequestSuccessBlock)success
       failure:(RequestFailureBlock)failure{
    [self.hud showAnimated:true];
    [self.manager GET:[Host stringByAppendingString:url] parameters:params headers:self.headers progress:^(NSProgress * _Nonnull downloadProgress) {
            
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * json = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSString * code = json[@"status"];
        NSLog(@"url=%@,params=%@,result=%@",url,params,json);
        [self.hud hideAnimated:true];
        if (code.intValue == 200) {
            success(json);
        }else{
            failure(json[@"message"]);
            [RMHelper showToast:json[@"message"] toView:UIApplication.sharedApplication.keyWindow];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"err=%@",error);
        [RMHelper showToast:error.description toView:RMHelper.getCurrentVC.view];
        [self.hud hideAnimated:true];
    }];
}

- (void)postUrl:(NSString *)url
         params:(NSDictionary *)params
       progress:(RequestProgressBlock)progress
        success:(RequestSuccessBlock)success
        failure:(RequestFailureBlock)failure{
    [self.hud showAnimated:true];
    [self.manager POST:[Host stringByAppendingString:url] parameters:params headers:self.headers progress:^(NSProgress * _Nonnull downloadProgress) {
            
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * json = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSString * code = json[@"status"];
        NSLog(@"url=%@,result=%@",url,json);
        [self.hud hideAnimated:true];
        if (code.intValue == 200) {
            success(json);
        }else{
            failure(json[@"message"]);
            [RMHelper showToast:json[@"message"] toView:UIApplication.sharedApplication.keyWindow];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"err=%@",error);
        [RMHelper showToast:error.description toView:RMHelper.getCurrentVC.view];
        [self.hud hideAnimated:true];
    }];
}

- (void)putUrl:(NSString *)url
         params:(NSDictionary *)params
        success:(RequestSuccessBlock)success
       failure:(RequestFailureBlock)failure{
    [self.hud showAnimated:true];
    [self.manager PUT:[Host stringByAppendingString:url] parameters:params headers:self.headers success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * json = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSString * code = json[@"status"];
        NSLog(@"url=%@,result=%@",url,json);
        [self.hud hideAnimated:true];
        if (code.intValue == 200) {
            success(json);
        }else{
            failure(json[@"message"]);
            [RMHelper showToast:json[@"message"] toView:UIApplication.sharedApplication.keyWindow];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"err=%@",error);
        [RMHelper showToast:error.description toView:RMHelper.getCurrentVC.view];
        [self.hud hideAnimated:true];
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
    }];
}

@end
