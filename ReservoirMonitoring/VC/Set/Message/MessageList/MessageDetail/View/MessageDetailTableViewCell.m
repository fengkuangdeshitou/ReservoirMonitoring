//
//  MessageDetailTableViewCell.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/11/10.
//

#import "MessageDetailTableViewCell.h"

@interface MessageDetailTableViewCell ()

@property(nonatomic,weak)IBOutlet UILabel * titleLabel;
@property(nonatomic,weak)IBOutlet UILabel * timeLabel;
@property(nonatomic,weak)IBOutlet UILabel * content;

@end

@implementation MessageDetailTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setModel:(MessageModel *)model{
    _model = model;
    self.titleLabel.text = model.title;
    self.timeLabel.text = model.createTime;
    self.content.text = model.content;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
