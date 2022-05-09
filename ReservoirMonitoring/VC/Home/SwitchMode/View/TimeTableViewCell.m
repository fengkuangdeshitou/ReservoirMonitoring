//
//  TimeTableViewCell.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/16.
//

#import "TimeTableViewCell.h"

@interface TimeTableViewCell ()

@property(nonatomic,weak)IBOutlet UILabel * time;
@property(nonatomic,weak)IBOutlet UILabel * price;

@end

@implementation TimeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.time.text = @"Price schedule".localized;
    self.price.text = @"Electricity price".localized;
    self.startTime.placeholder = @"Start time".localized;
    self.endTime.placeholder = @"End time".localized;
    self.electricity.placeholder = @"Input electricity price".localized;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
