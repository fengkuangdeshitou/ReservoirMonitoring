//
//  InputTableViewCell.h
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/5/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface InputTableViewCell : UITableViewCell

@property(nonatomic,weak)IBOutlet UILabel * titleLabel;
@property(nonatomic,weak)IBOutlet UITextField * textfield;

@end

NS_ASSUME_NONNULL_END
