//
//  AddDeviceActionTableViewCell.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/5/6.
//

#import "AddDeviceActionTableViewCell.h"

@interface AddDeviceActionTableViewCell ()

@end

@implementation AddDeviceActionTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.addButton showBorderWithRadius:14];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
