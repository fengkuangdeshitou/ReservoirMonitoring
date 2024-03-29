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

- (void)setIndex:(NSInteger)index{
    _index = index;
    if (index == 1) {
        self.slider.minimumValue = 50;
    }else{
        self.slider.minimumValue = 0;
    }
}

- (void)setProgress:(CGFloat)progress{
    _progress = progress;
    if (progress <= 50 && self.index == 1) {
        self.slider.value = 50;
        self.titleLabel.text = @"50";
    }else{
        self.slider.value = progress;
        self.titleLabel.text = [NSString stringWithFormat:@"%.0f",progress];
    }
}

- (IBAction)addAction:(id)sender{
    if (self.progress < 100) {
        self.progress++;
        if (self.progress <= 50 && self.index == 1) {
            self.progress = 51;
        }
        if (self.progress>100) {
            self.progress = 100;
        }
        self.slider.value = self.progress;
        self.titleLabel.text = [NSString stringWithFormat:@"%.0f",self.progress];
    }
    if (self.progressChangeBlock) {
        self.progressChangeBlock(self.index, self.progress);
    }
}

- (IBAction)subAction:(id)sender{
    self.progress--;
    if (self.index == 1) {
        if (self.progress <= 50) {
            self.progress = 50;
        }
    }else{
        if (self.progress <= 0) {
            self.progress = 0;
        }
    }
    self.slider.value = self.progress;
    self.titleLabel.text = [NSString stringWithFormat:@"%.0f",self.progress];
    if (self.progressChangeBlock) {
        self.progressChangeBlock(self.index, self.progress);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
