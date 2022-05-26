//
//  HelpTableViewCell.h
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HelpTableViewCell : UITableViewCell

@property(nonatomic,weak)IBOutlet UIView * line;
@property(nonatomic,weak)IBOutlet UILabel * titleLabel;
@property(nonatomic,weak)IBOutlet UILabel * content;

@end

NS_ASSUME_NONNULL_END
