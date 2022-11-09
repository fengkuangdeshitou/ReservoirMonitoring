//
//  WifiInfoTableViewCell.m
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/5/18.
//

#import "WifiInfoTableViewCell.h"
#import "BleManager.h"
#import "GlobelDescAlertView.h"

@implementation WifiInfoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.address.text = @"SN：".localized;
    self.status.text = @"BLE status：".localized;
    self.statusButton.layer.cornerRadius = 15;
    self.statusButton.layer.borderWidth = 0.5;
    
    self.statusButton.layer.borderColor = [UIColor colorWithHexString:COLOR_MAIN_COLOR].CGColor;
    [self.statusButton setTitle:@"Connect".localized forState:UIControlStateNormal];
    self.status.text = @"Disconnected".localized;
    self.status.textColor = [UIColor colorWithHexString:@"#999999"];
    self.statusImageView.image = [UIImage imageNamed:@"bluetooth_gray"];
}

- (void)setModel:(DevideModel *)model{
    _model = model;
    self.deviceName.text = model.name;
    self.addressLabel.text = model.sgSn;
    if (model.isConnected) {
        [self.statusButton setTitle:@"Disconnect".localized forState:UIControlStateNormal];
        self.statusButton.layer.borderColor = [UIColor colorWithHexString:COLOR_MAIN_COLOR].CGColor;
        self.status.text = @"Connected".localized;
        self.status.textColor = [UIColor colorWithHexString:COLOR_MAIN_COLOR];
        self.statusImageView.image = [UIImage imageNamed:@"bluetooth_active"];
    }else{
        self.statusButton.layer.borderColor = [UIColor colorWithHexString:COLOR_MAIN_COLOR].CGColor;
        [self.statusButton setTitle:@"Connect".localized forState:UIControlStateNormal];
        self.status.text = @"Disconnected".localized;
        self.status.textColor = [UIColor colorWithHexString:@"#999999"];
        self.statusImageView.image = [UIImage imageNamed:@"bluetooth_gray"];
    }
}

- (IBAction)disconnectAction:(UIButton *)sender{
    if (DeviceManager.shareInstance.deviceNumber == 0) {
        [GlobelDescAlertView showAlertViewWithTitle:@"Tips" desc:@"Please add device to continue" btnTitle:nil completion:nil];
        return;
    }
    if (BleManager.shareInstance.isConnented) {
        [BleManager.shareInstance disconnectPeripheral];
    }else{
        BleManager.shareInstance.rtusn = self.model.rtuSn;
        [BleManager.shareInstance startScanning];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
