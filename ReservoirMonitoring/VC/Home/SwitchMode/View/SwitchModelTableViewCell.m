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
}

- (IBAction)help:(id)sender{
    if (self.indexPath.section == 0) {
        [GlobelDescAlertView showAlertViewWithTitle:self.titleLabel.text desc:@"Use stored solar energy to power your home after the sun goes down." btnTitle:nil completion:nil];
    }else if (self.indexPath.section == 1){
        [GlobelDescAlertView showAlertViewWithTitle:self.titleLabel.text desc:@"100% of battery energy is reserved for backup at all times." btnTitle:nil completion:nil];
    }else{
        [GlobelDescAlertView showAlertViewWithTitle:self.titleLabel.text desc:@"Time based control, best cost efficiency if your energy costs vary through the day.  \"Allow charging via grid\" gives you the option to charge up battery with grid power during off-peak period." btnTitle:nil completion:nil];
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
