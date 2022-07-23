//
//  UserModel.h
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/5/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserModel : NSObject
//用户ID
@property(nonatomic,strong) NSString * userId;
//用户账号
@property(nonatomic,strong) NSString * userName;
//用户姓名
@property(nonatomic,strong) NSString * nickName;
//用户类型 1-安装商 2-用户
@property(nonatomic,strong) NSString * userType;
//邮箱
@property(nonatomic,strong) NSString * email;
//电话
@property(nonatomic,strong) NSString * phonenumber;
//头像
@property(nonatomic,strong) NSString * avatar;

@property(nonatomic,strong) NSString * defDevSgSn;

@property(nonatomic,strong) NSString * defDevId;

@end

NS_ASSUME_NONNULL_END
