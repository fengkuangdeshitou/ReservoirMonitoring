//
//  WifiInfoTableViewCell.h
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/5/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WifiInfoTableViewCell : UITableViewCell

@property(nonatomic,weak)IBOutlet UILabel * address;
@property(nonatomic,weak)IBOutlet UILabel * status;
@property(nonatomic,weak)IBOutlet UIButton * statusButton;

@end

NS_ASSUME_NONNULL_END
