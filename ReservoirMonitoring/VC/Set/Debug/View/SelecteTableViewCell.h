//
//  SelecteTableViewCell.h
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/5/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SelecteTableViewCell : UITableViewCell

@property(nonatomic,weak)IBOutlet UILabel * titleLabel;
@property(nonatomic,weak)IBOutlet UILabel * content;

@end

NS_ASSUME_NONNULL_END
