//
//  MessageListTableViewCell.h
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/11/7.
//

#import <UIKit/UIKit.h>
#import "MessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MessageTableViewCell : UITableViewCell

@property(nonatomic,strong) MessageModel * model;
@property(nonatomic,weak)IBOutlet UIView * line;

@end

NS_ASSUME_NONNULL_END
