//
//  SwitchProgressTableViewCell.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/16.
//

#import "SwitchProgressTableViewCell.h"

@interface SwitchProgressTableViewCell ()

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
    self.titleLabel.text = [NSString stringWithFormat:@"%.0f",progress];
}

- (IBAction)addAction:(id)sender{
    if (self.progress < 100) {
        self.progress++;
        self.slider.value = self.progress;
        self.titleLabel.text = [NSString stringWithFormat:@"%.0f",self.progress];
    }
}

- (IBAction)subAction:(id)sender{
    if (self.progress > 0) {
        self.progress--;
        self.slider.value = self.progress;
        self.titleLabel.text = [NSString stringWithFormat:@"%.0f",self.progress];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
