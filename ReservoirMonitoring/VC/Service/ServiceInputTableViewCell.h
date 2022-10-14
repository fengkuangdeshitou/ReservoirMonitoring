//
//  ServiceInputTableViewCell.h
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/10/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ServiceInputTableViewCell : UITableViewCell

@property(nonatomic,weak)IBOutlet UILabel * titleLabel;
@property(nonatomic,weak)IBOutlet UITextView * content;
@property(nonatomic,weak)IBOutlet UIView * line;

@end

NS_ASSUME_NONNULL_END
