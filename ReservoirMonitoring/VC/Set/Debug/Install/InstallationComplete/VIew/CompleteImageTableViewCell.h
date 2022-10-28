//
//  CompleteImageTableViewCell.h
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/10/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CompleteImageTableViewCell : UITableViewCell

@property (copy, nonatomic) void(^updateFrameBlock)(CGRect frame);
@property (strong, nonatomic) NSArray * photos;

@end

NS_ASSUME_NONNULL_END
