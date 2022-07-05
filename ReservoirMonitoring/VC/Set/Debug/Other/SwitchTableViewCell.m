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
    self.loadSwitch.selected = RMHelper.getLoadDataForBluetooth;
}

- (IBAction)switchAction:(UIButton *)sender{
    sender.selected = !sender.selected;
    [RMHelper setLoadDataForBluetooth:sender.isSelected];
    [[NSNotificationCenter defaultCenter] postNotificationName:DATA_TYPE_CHANGE_NOTIFICATION object:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
