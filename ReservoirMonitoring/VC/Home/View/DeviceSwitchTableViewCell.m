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

@end

@implementation DeviceSwitchTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.name.text = @"Device name".localized;
    self.SN.text = @"Device SN".localized;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
