//
//  MessageListTableViewCell.m
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/11/8.
//

#import "MessageListTableViewCell.h"

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
    self.time.text = model.createTime;
    self.ready.hidden = model.ready.intValue == 1;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
