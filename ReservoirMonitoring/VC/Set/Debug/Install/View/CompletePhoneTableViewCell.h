//
//  CompletePhoneTableViewCell.h
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/11/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CompletePhoneTableViewCell : UITableViewCell

@property(nonatomic,weak)IBOutlet UILabel * phone;
@property(nonatomic,weak)IBOutlet UITextField * textfield;
@property(nonatomic,weak)IBOutlet UIButton * codeBtn;

@end

NS_ASSUME_NONNULL_END
