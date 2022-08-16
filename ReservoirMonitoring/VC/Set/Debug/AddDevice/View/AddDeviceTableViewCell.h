//
//  AddDeviceTableViewCell.h
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AddDeviceTableViewCell : UITableViewCell

@property(nonatomic,weak)IBOutlet UITextField * idtextfield;
@property(nonatomic,weak)IBOutlet UITextField * nametextfield;
@property(nonatomic,weak)IBOutlet UIButton * scanBtn;

@end

NS_ASSUME_NONNULL_END
