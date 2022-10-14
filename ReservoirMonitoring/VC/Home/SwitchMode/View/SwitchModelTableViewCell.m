//
//  SwitchModelTableViewCell.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/16.
//

#import "SwitchModelTableViewCell.h"
#import "GlobelDescAlertView.h"

@implementation SwitchModelTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.clearBtn.layer.cornerRadius = 13;
    self.clearBtn.layer.borderColor = [UIColor colorWithHexString:COLOR_MAIN_COLOR].CGColor;
    self.clearBtn.layer.borderWidth = 1;
}

- (IBAction)help:(id)sender{
    if (self.indexPath.section == 0) {
        [GlobelDescAlertView showAlertViewWithTitle:self.titleLabel.text desc:@"Under this mode, batteries are discharged to power your home. In self-consumption mode, the user can set the lowest threshold for the Reserve SOC value in order to save some energy for emergency use only." btnTitle:nil completion:nil];
    }else if (self.indexPath.section == 1){
        [GlobelDescAlertView showAlertViewWithTitle:self.titleLabel.text desc:@"Under this mode, energy stored by the battery modules is reserved for backup only, and only gets discharged in case of grid blackout or other power failures." btnTitle:nil completion:nil];
    }else{
        [GlobelDescAlertView showAlertViewWithTitle:self.titleLabel.text desc:@"This mode offers time-based control for best cost efficiency if the electricity cost varies throughout the day. In this mode, the user can choose and decide whether to charge the batteries via grid power or not during off-peak hours." btnTitle:nil completion:nil];
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
