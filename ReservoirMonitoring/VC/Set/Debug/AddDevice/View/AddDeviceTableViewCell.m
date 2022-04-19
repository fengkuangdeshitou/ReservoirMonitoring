//
//  AddDeviceTableViewCell.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/19.
//

#import "AddDeviceTableViewCell.h"
#import "ScanViewController.h"

@implementation AddDeviceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)scanAction:(id)sender{
    ScanViewController * scan = [[ScanViewController alloc] init];
    [RMHelper.getCurrentVC.navigationController pushViewController:scan animated:true];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
