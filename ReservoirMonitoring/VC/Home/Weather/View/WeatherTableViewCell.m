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
    CGFloat min = 1000;
    CGFloat max = 0;
    for (int i=0; i<model.count; i++) {
        NSDictionary * item = model[i];
        if ([item[@"main"][@"temp_min"] floatValue] < min){
            min = [item[@"main"][@"temp_min"] floatValue];
        }
        if ([item[@"main"][@"temp_max"] floatValue] > max){
            max = [item[@"main"][@"temp_max"] floatValue];
        }
    }
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:[model[0][@"date"] longLongValue]/1000];
    self.weak.text = [self formatWeekString:date.br_weekdayString];
    // - 32)*5/9
    self.min.text = [NSString stringWithFormat:@"%.0f°",min];
    self.max.text = [NSString stringWithFormat:@"%.0f°",max];
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
