//
//  SwitchProgressTableViewCell.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/16.
//

#import "SwitchProgressTableViewCell.h"

@interface SwitchProgressTableViewCell ()

@property(nonatomic,weak)IBOutlet UISlider * slider;
@property(nonatomic,weak)IBOutlet UILabel * titleLabel;

@end

@implementation SwitchProgressTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.slider setThumbImage:[UIImage imageNamed:@"process_line"] forState:UIControlStateNormal];
}

- (void)setProgress:(CGFloat)progress{
    _progress = progress;
    self.slider.value = progress;
    self.titleLabel.text = [NSString stringWithFormat:@"%.0f",progress*100];
}

- (IBAction)valueChante:(id)sender{
    self.progress = self.slider.value*100;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
