//
//  SwitchTableViewCell.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/5/15.
//

#import "SwitchTableViewCell.h"

@implementation SwitchTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)switchAction:(UIButton *)sender{
    sender.selected = !sender.selected;
    [RMHelper setLoadDataForBluetooth:sender.isSelected];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
