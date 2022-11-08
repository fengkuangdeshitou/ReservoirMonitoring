//
//  MessageListTableViewCell.h
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/11/8.
//

#import <UIKit/UIKit.h>
#import "MessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MessageListTableViewCell : UITableViewCell

@property(nonatomic,strong) MessageModel * model;

@end

NS_ASSUME_NONNULL_END
