//
//  AddDeviceSNTableViewCell.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/5/6.
//

#import "AddDeviceSNTableViewCell.h"

@implementation AddDeviceSNTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)layoutSubviews{
    self.textfield.placeholderColor = [UIColor colorWithHexString:COLOR_PLACEHOLDER_COLOR];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
