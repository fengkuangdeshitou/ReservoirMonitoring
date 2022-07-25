//
//  TimeTableViewCell.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/16.
//

#import "TimeTableViewCell.h"
@import BRPickerView;

@interface TimeTableViewCell ()

@property(nonatomic,weak)IBOutlet UILabel * time;
@property(nonatomic,weak)IBOutlet UILabel * price;
@property(nonatomic,strong) BRPickerStyle * style;
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

- (BRPickerStyle *)style{
    if (!_style) {
        _style = [[BRPickerStyle alloc] init];
        _style.alertViewColor = [UIColor.blackColor colorWithAlphaComponent:0.7];
        _style.maskColor = [UIColor.blackColor colorWithAlphaComponent:0.7];
        _style.pickerColor = [UIColor colorWithHexString:COLOR_BACK_COLOR];
        _style.doneTextColor = [UIColor colorWithHexString:COLOR_MAIN_COLOR];
        _style.cancelTextColor = [UIColor colorWithHexString:@"#999999"];
        _style.titleBarColor = [UIColor colorWithHexString:COLOR_BACK_COLOR];
        _style.selectRowColor = UIColor.clearColor;
        _style.pickerTextColor = [UIColor colorWithHexString:@"#F6F6F6"];
        _style.titleLineColor = [UIColor colorWithHexString:@"#333333"];
        _style.doneBtnTitle = @"OK".localized;
        _style.cancelBtnTitle = @"Cancel".localized;
    }
    return _style;
}

- (void)layoutSubviews{
    self.startTime.placeholderColor = [UIColor colorWithHexString:COLOR_PLACEHOLDER_COLOR];
    self.endTime.placeholderColor = [UIColor colorWithHexString:COLOR_PLACEHOLDER_COLOR];
    self.electricity.placeholderColor = [UIColor colorWithHexString:COLOR_PLACEHOLDER_COLOR];
}

- (IBAction)startTimeAction:(id)sender{
    BRDatePickerView * picker = [[BRDatePickerView alloc] initWithPickerMode:BRDatePickerModeHM];
    picker.showUnitType = BRShowUnitTypeNone;
    picker.selectDate = [NSDate date];
    picker.selectValue = self.startTime.text;
    picker.pickerStyle = self.style;
    picker.resultBlock = ^(NSDate * _Nullable selectDate, NSString * _Nullable selectValue) {
        if (self.valueChangeCompletion) {
            self.valueChangeCompletion(self.indexPath,@"startTime",selectValue);
        }
        self.startTime.text = selectValue;
    };
    [picker show];
}

- (IBAction)endTimeAction:(id)sender{
    BRDatePickerView * picker = [[BRDatePickerView alloc] initWithPickerMode:BRDatePickerModeHM];
    picker.showUnitType = BRShowUnitTypeNone;
    picker.selectDate = [NSDate date];
    picker.selectValue = self.endTime.text;
    picker.pickerStyle = self.style;
    picker.resultBlock = ^(NSDate * _Nullable selectDate, NSString * _Nullable selectValue) {
        if (self.valueChangeCompletion) {
            self.valueChangeCompletion(self.indexPath,@"endTime",selectValue);
        }
        self.endTime.text = selectValue;
    };
    [picker show];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
