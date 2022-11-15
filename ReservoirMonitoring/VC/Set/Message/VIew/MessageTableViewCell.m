//
//  MessageListTableViewCell.m
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/11/7.
//

#import "MessageTableViewCell.h"
@import BRPickerView;

@interface MessageTableViewCell ()

@property(nonatomic,weak)IBOutlet UIImageView * icon;
@property(nonatomic,weak)IBOutlet UILabel * titleLabel;
@property(nonatomic,weak)IBOutlet UILabel * subTitleLabel;
@property(nonatomic,weak)IBOutlet UILabel * timeLabel;
@property(nonatomic,weak)IBOutlet UILabel * unReadyNum;

@end

@implementation MessageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setModel:(MessageModel *)model{
    _model = model;
    self.icon.image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_message_%@",model.type]];
    self.titleLabel.text = model.typeName;
    self.subTitleLabel.text = model.content;
    self.timeLabel.text = [NSDate br_stringFromDate:[NSDate dateWithTimeIntervalSince1970:model.createTimeStamp.longLongValue/1000] dateFormat:@"yyyy-MM-dd HH:mm:ss"];
    self.unReadyNum.text = [model.unReadyNum stringByAppendingString:@" "];
    self.unReadyNum.hidden = model.unReadyNum.intValue == 0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
