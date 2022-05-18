//
//  WarningTableViewCell.h
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WarningTableViewCell : UITableViewCell

@property(nonatomic,weak)IBOutlet UILabel * typeLabel;
@property(nonatomic,weak)IBOutlet UILabel * time;

@end

NS_ASSUME_NONNULL_END
