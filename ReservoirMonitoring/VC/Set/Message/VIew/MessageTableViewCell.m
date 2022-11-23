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
    self.subTitleLabel.text = model.content?:@"No message";
    self.timeLabel.text = [NSDate br_stringFromDate:[NSDate dateWithTimeIntervalSince1970:model.createTimeStamp.longLongValue/1000] dateFormat:@"yyyy-MM-dd HH:mm:ss"];
    self.timeLabel.hidden = !model.createTime;
    NSString * num = model.unReadyNum.intValue > 99 ? @"99" : model.unReadyNum;
    self.unReadyNum.text = [num stringByAppendingString:@"  "];
    self.unReadyNum.hidden = num.intValue == 0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
