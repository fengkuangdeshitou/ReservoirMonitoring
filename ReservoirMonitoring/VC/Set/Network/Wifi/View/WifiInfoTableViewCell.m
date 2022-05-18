//
//  WifiInfoTableViewCell.m
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/5/18.
//

#import "WifiInfoTableViewCell.h"
#import "BleManager.h"

@implementation WifiInfoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.address.text = @"SN Address：".localized;
    self.status.text = @"BLE status：".localized;
    self.statusButton.layer.cornerRadius = 15;
    self.statusButton.layer.borderWidth = 0.5;
}

- (void)setModel:(PeripheralModel *)model{
    _model = model;
    self.addressLabel.text = [model.peripheral.name componentsSeparatedByString:@"-"].lastObject;
    if (model.isConnected) {
        [self.statusButton setTitle:@"Disconnect".localized forState:UIControlStateNormal];
        self.statusButton.layer.borderColor = [UIColor colorWithHexString:COLOR_MAIN_COLOR].CGColor;
        self.status.text = @"Connected".localized;
        self.status.textColor = [UIColor colorWithHexString:COLOR_MAIN_COLOR];
    }else{
        self.statusButton.layer.borderColor = [UIColor colorWithHexString:@"#999999"].CGColor;
        [self.statusButton setTitle:@"Connect".localized forState:UIControlStateNormal];
        self.status.text = @"Disconnected".localized;
        self.status.textColor = [UIColor colorWithHexString:@"#999999"];
    }
}

- (IBAction)disconnectAction:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {
        [BleManager.shareInstance disconnectPeripheral];
    }else{
        [BleManager.shareInstance connectPeripheral:self.model.peripheral];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
