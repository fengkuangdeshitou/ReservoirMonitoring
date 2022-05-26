//
//  RequestURL.m
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/5/24.
//

#import "RequestURL.h"

@implementation RequestURL

#ifdef DEBUG
NSString * const Host = @"http://52.8.81.210:8502";
#else
NSString * const Host = @"http://52.8.81.210:8502";
#endif

NSString * const EmailCode = @"/open/common/getEmailCode";

NSString * const CommonRegister = @"/open/common/register";

NSString * const Login = @"/open/common/login";

NSString * const ResetPwd = @"/open/common/resetPwd";

NSString * const UserInfo = @"/user/user/base";

NSString * const EditUserInfo = @"/user/user/editUserInfo";

NSString * const UploadImg = @"/open/common/uploadImg/123";

NSString * const HelpList = @"/help/helpList";

NSString * const HelpDetail = @"/help/helpDetail";
@end
