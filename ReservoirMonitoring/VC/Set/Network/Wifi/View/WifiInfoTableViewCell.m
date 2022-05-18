//
//  WifiInfoTableViewCell.m
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/5/18.
//

#import "WifiInfoTableViewCell.h"

@implementation WifiInfoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.address.text = @"SN Address：".localized;
    self.status.text = @"BLE status：".localized;
    [self.statusButton setTitle:@"Disconnect".localized forState:UIControlStateNormal];
    self.statusButton.layer.cornerRadius = 15;
    self.statusButton.layer.borderColor = [UIColor colorWithHexString:COLOR_MAIN_COLOR].CGColor;
    self.statusButton.layer.borderWidth = 0.5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
