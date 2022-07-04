//
//  SwitchTableViewCell.h
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/5/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SwitchTableViewCell : UITableViewCell

@property(nonatomic,weak)IBOutlet UILabel * titleLabel;
@property(nonatomic,weak)IBOutlet UIButton * loadSwitch;

@end

NS_ASSUME_NONNULL_END
