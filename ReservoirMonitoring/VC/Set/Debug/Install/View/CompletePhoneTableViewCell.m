//
//  CompletePhoneTableViewCell.m
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/11/5.
//

#import "CompletePhoneTableViewCell.h"
#import "CountryCodeViewController.h"

@implementation CompletePhoneTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.textfield.placeholderColor = [UIColor colorWithHexString:COLOR_PLACEHOLDER_COLOR];
}

- (IBAction)selectCountryCodeAction:(UIButton *)sender{
    CountryCodeViewController * code = [[CountryCodeViewController alloc] init];
    code.selectCountryCode = ^(NSDictionary * _Nonnull item) {
        self.phone.text = [NSString stringWithFormat:@"+%@",item[@"countryCode"]];
    };
    [RMHelper.getCurrentVC.navigationController pushViewController:code animated:true];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
