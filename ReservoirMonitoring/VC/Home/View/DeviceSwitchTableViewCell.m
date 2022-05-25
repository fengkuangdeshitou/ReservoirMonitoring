//
//  DeviceSwitchTableViewCell.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/16.
//

#import "DeviceSwitchTableViewCell.h"

@interface DeviceSwitchTableViewCell ()

@property(nonatomic,weak)IBOutlet UILabel * name;
@property(nonatomic,weak)IBOutlet UILabel * SN;
@property(nonatomic,weak)IBOutlet UILabel * status;

@end

@implementation DeviceSwitchTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.name.text = @"Device name".localized;
    self.SN.text = @"Device SN".localized;
    self.status.text = @"On-line".localized;// Offine
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end