//
//  MessageListTableViewCell.m
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/11/8.
//

#import "MessageListTableViewCell.h"
@import BRPickerView;
#import "InstallViewController.h"

@interface MessageListTableViewCell ()

@property(nonatomic,weak)IBOutlet UILabel * title;
@property(nonatomic,weak)IBOutlet UILabel * content;
@property(nonatomic,weak)IBOutlet UILabel * time;
@property(nonatomic,weak)IBOutlet UIView * ready;

@end

@implementation MessageListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setModel:(MessageModel *)model{
    _model = model;
    self.title.text = model.title;
    self.content.text = model.content;
    self.time.text = [NSDate br_stringFromDate:[NSDate dateWithTimeIntervalSince1970:model.createTimestamp.longLongValue/1000] dateFormat:@"yyyy-MM-dd HH:mm:ss"];
    self.ready.hidden = model.ready.intValue == 1;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
