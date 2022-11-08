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
@property(nonatomic,strong) NSString * unReadyNum;
@property(nonatomic,strong) NSString * type;

@end

NS_ASSUME_NONNULL_END
