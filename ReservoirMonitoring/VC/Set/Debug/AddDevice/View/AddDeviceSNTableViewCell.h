//
//  AddDeviceSNTableViewCell.h
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/5/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AddDeviceSNTableViewCell : UITableViewCell

@property(nonatomic,weak)IBOutlet UITextField * textfield;
@property(nonatomic,weak)IBOutlet UIButton * scanBtn;
@property(nonatomic,weak)IBOutlet UIButton * deleteBtm;
@property(nonatomic,weak)IBOutlet UILabel * label;
@property(nonatomic,weak)IBOutlet UIView * line;
@property(nonatomic,weak)IBOutlet NSLayoutConstraint * deleteBtnWidth;
@property(nonatomic,weak)IBOutlet NSLayoutConstraint * deleteBtnLeft;

@end

NS_ASSUME_NONNULL_END
