//
//  SetTableViewCell.h
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SetTableViewCell : UITableViewCell

@property(nonatomic,weak)IBOutlet UIImageView * icon;
@property(nonatomic,weak)IBOutlet UILabel * titleLabel;
@property(nonatomic,weak)IBOutlet UIView * line;

@end

NS_ASSUME_NONNULL_END
