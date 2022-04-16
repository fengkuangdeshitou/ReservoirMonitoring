//
//  SwitchProgressTableViewCell.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/16.
//

#import "SwitchProgressTableViewCell.h"

@interface SwitchProgressTableViewCell ()

@property(nonatomic,weak)IBOutlet UISlider * slider;

@end

@implementation SwitchProgressTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.slider setThumbImage:[UIImage imageNamed:@"process_line"] forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
