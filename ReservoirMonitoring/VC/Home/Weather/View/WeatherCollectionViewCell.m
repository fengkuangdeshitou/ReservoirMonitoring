//
//  WeatherCollectionViewCell.m
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/5/17.
//

#import "WeatherCollectionViewCell.h"

@interface WeatherCollectionViewCell ()

@property(nonatomic,weak)IBOutlet UILabel * time;
@property(nonatomic,weak)IBOutlet UIImageView * icon;
@property(nonatomic,weak)IBOutlet UILabel * temp;

@end

@implementation WeatherCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setModel:(NSDictionary *)model{
    _model = model;
//    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"HH"];
//    NSDate * date = [NSDate dateWithTimeIntervalSince1970:[model[@"dt"] longLongValue]];
//    NSTimeZone * zone = [NSTimeZone timeZoneForSecondsFromGMT:-5];
//    [formatter setTimeZone:zone];
//    NSString * time = [formatter stringFromDate:date];
//    self.time.text = [NSString stringWithFormat:@"%@ h",time];
    NSString * string = [model[@"dt_txt"] componentsSeparatedByString:@" "].lastObject;
    self.time.text = [NSString stringWithFormat:@"%@ h",[string substringToIndex:2]];
    self.icon.image = [UIImage imageNamed:model[@"weather"][0][@"icon"]];
    self.temp.text = [NSString stringWithFormat:@"%.0f",[model[@"main"][@"temp"] floatValue]];
}

@end
