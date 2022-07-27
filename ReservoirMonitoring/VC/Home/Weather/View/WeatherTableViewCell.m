//
//  WeatherTableViewCell.m
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/5/17.
//

#import "WeatherTableViewCell.h"
@import BRPickerView;

@interface WeatherTableViewCell ()

@property(nonatomic,weak)IBOutlet UILabel * weak;
@property(nonatomic,weak)IBOutlet UILabel * max;
@property(nonatomic,weak)IBOutlet UILabel * min;

@end

@implementation WeatherTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setModel:(NSArray *)model{
    _model = model;
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:[model[0][@"date"] longLongValue]/1000];
    self.weak.text = [self formatWeekString:date.br_weekdayString];
    // - 32)*5/9
    self.max.text = [NSString stringWithFormat:@"%.2f",[model[0][@"main"][@"temp_max"] floatValue]];
    self.min.text = [NSString stringWithFormat:@"%.2f",[model[0][@"main"][@"temp_min"] floatValue]];
    self.icon.image = [UIImage imageNamed:model[0][@"weather"][0][@"icon"]];
}

- (NSString *)formatWeekString:(NSString *)string{
    NSString * value = @"";
    if ([string isEqualToString:@"周日"]) {
        value = @"Sun";
    }else if ([string isEqualToString:@"周一"]) {
        value = @"Mon";
    }else if ([string isEqualToString:@"周二"]) {
        value = @"Tue";
    }else if ([string isEqualToString:@"周三"]) {
        value = @"Wed";
    }else if ([string isEqualToString:@"周四"]) {
        value = @"Thu";
    }else if ([string isEqualToString:@"周五"]) {
        value = @"Fri";
    }else if ([string isEqualToString:@"周六"]) {
        value = @"Sat";
    }
    return value;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
