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
    self.electricity.delegate = self;
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
    if(self.startTime.text.length > 0){
        picker.selectValue = self.startTime.text;
    }else{
        picker.selectDate = [NSDate date];
    }
    picker.pickerStyle = self.style;
    picker.resultBlock = ^(NSDate * _Nullable selectDate, NSString * _Nullable selectValue) {
        if(self.endTime.text.length > 0 && [self compareOneDay:selectDate withAnotherDay:[NSDate br_dateFromString:self.endTime.text dateFormat:@"HH:mm"]] != -1){
            [RMHelper showToast:@"Start time cannot be later than end time" toView:RMHelper.getCurrentVC.view];
        }else{
            if (self.valueChangeCompletion) {
                self.valueChangeCompletion(self.indexPath,@"startTime",selectValue);
            }
            self.startTime.text = selectValue;
        }
    };
    [picker show];
}

- (IBAction)endTimeAction:(id)sender{
    BRDatePickerView * picker = [[BRDatePickerView alloc] initWithPickerMode:BRDatePickerModeHM];
    picker.showUnitType = BRShowUnitTypeNone;
    if(self.endTime.text.length > 0){
        picker.selectValue = self.endTime.text;
    }else{
        picker.selectDate = [NSDate date];
    }
    picker.pickerStyle = self.style;
    picker.resultBlock = ^(NSDate * _Nullable selectDate, NSString * _Nullable selectValue) {
        if(self.startTime.text.length > 0 && [self compareOneDay:selectDate withAnotherDay:[NSDate br_dateFromString:self.startTime.text dateFormat:@"HH:mm"]] != 1){
            [RMHelper showToast:@"End time cannot be earlier than start time" toView:RMHelper.getCurrentVC.view];
        }else{
            if (self.valueChangeCompletion) {
                self.valueChangeCompletion(self.indexPath,@"endTime",selectValue);
            }
            self.endTime.text = selectValue;
        }
    };
    [picker show];
}

- (int)compareOneDay:(NSDate *)oneDay withAnotherDay:(NSDate *)anotherDay{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"HH:mm"];
    
    NSString *oneDayStr = [dateFormatter stringFromDate:oneDay];
    
    NSString *anotherDayStr = [dateFormatter stringFromDate:anotherDay];
    
    NSDate *dateA = [dateFormatter dateFromString:oneDayStr];
    
    NSDate *dateB = [dateFormatter dateFromString:anotherDayStr];
    
    NSComparisonResult result = [dateA compare:dateB];
    
    if (result == NSOrderedDescending) {
        //NSLog(@"oneDay比 anotherDay时间晚");
        return 1;
    }
    else if (result == NSOrderedAscending){
        //NSLog(@"oneDay比 anotherDay时间早");
        return -1;
    }
    //NSLog(@"两者时间是同一个时间");
    return 0;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField.text containsString:@"."] && [string isEqualToString:@"."]) {
        return NO;
    }
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];

    NSArray *sep = [newString componentsSeparatedByString:@"."];
    if([sep count] >= 2)
    {
        NSString *sepStr=[NSString stringWithFormat:@"%@",[sep objectAtIndex:1]];
        return !([sepStr length]>2);
    }
    return YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
