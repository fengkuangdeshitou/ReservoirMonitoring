//
//  AddDeviceTableViewCell.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/19.
//

#import "AddDeviceTableViewCell.h"
#import "ScanViewController.h"

@interface AddDeviceTableViewCell ()

@property(nonatomic,weak)IBOutlet UILabel * titleLabel;

@end

@implementation AddDeviceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.titleLabel.text = @"Smart Gateway info".localized;
    self.idtextfield.placeholder = @"Please input device SN".localized;
    self.nametextfield.placeholder = @"Please input name for this device".localized;
}

- (IBAction)scanAction:(id)sender{
    ScanViewController * scan = [[ScanViewController alloc] init];
    [RMHelper.getCurrentVC.navigationController pushViewController:scan animated:true];
}

- (void)layoutSubviews{
    self.idtextfield.placeholderColor = [UIColor colorWithHexString:COLOR_PLACEHOLDER_COLOR];
    self.nametextfield.placeholderColor = [UIColor colorWithHexString:COLOR_PLACEHOLDER_COLOR];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
