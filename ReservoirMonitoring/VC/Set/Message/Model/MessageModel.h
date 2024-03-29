//
//  MessageModel.h
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/11/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MessageModel : NSObject

@property(nonatomic,strong) NSString * content;
@property(nonatomic,strong) NSString * typeName;
@property(nonatomic,strong) NSString * createTime;
@property(nonatomic,strong) NSString * createTimestamp;
@property(nonatomic,strong) NSString * createTimeStamp;
@property(nonatomic,strong) NSString * unReadyNum;
@property(nonatomic,strong) NSString * type;
/// 1未安装类型 2=安装审核通过 3=安装审核驳回
@property(nonatomic,strong) NSString * installType;
@property(nonatomic,strong) NSString * deviceId;
@property(nonatomic,strong) NSString * Id;
@property(nonatomic,strong) NSString * ready;
@property(nonatomic,strong) NSString * title;
@property(nonatomic,strong) NSString * reserved1;
@property(nonatomic,strong) NSString * reserved2;

@end

NS_ASSUME_NONNULL_END
