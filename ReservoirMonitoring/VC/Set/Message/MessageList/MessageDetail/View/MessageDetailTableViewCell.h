//
//  MessageDetailTableViewCell.h
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/11/10.
//

#import <UIKit/UIKit.h>
#import "MessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MessageDetailTableViewCell : UITableViewCell

@property(nonatomic,strong) MessageModel * model;

@end

NS_ASSUME_NONNULL_END
