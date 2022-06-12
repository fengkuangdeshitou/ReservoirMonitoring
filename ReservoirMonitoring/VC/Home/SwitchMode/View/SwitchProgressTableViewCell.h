//
//  SwitchProgressTableViewCell.h
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SwitchProgressTableViewCell : UITableViewCell

@property(nonatomic,assign) CGFloat progress;
@property(nonatomic,weak)IBOutlet UISlider * slider;
@property(nonatomic,weak)IBOutlet UILabel * titleLabel;

@end

NS_ASSUME_NONNULL_END
