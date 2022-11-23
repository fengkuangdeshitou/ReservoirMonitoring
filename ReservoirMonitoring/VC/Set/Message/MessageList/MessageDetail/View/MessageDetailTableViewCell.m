//
//  MessageDetailTableViewCell.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/11/10.
//

#import "MessageDetailTableViewCell.h"
#import "InstallViewController.h"
@import BRPickerView;

@interface MessageDetailTableViewCell ()

@property(nonatomic,weak)IBOutlet UILabel * titleLabel;
@property(nonatomic,weak)IBOutlet UILabel * timeLabel;
@property(nonatomic,weak)IBOutlet UILabel * content;
@property(nonatomic,weak)IBOutlet UIButton * detailBtn;

@end

@implementation MessageDetailTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setModel:(MessageModel *)model{
    _model = model;
    self.titleLabel.text = model.title;
    self.timeLabel.text = [NSDate br_stringFromDate:[NSDate dateWithTimeIntervalSince1970:model.createTimestamp.longLongValue/1000] dateFormat:@"yyyy-MM-dd HH:mm:ss"];
    self.timeLabel.hidden = !model.createTimestamp;
    self.content.text = model.content;
    self.detailBtn.userInteractionEnabled = model.type.intValue == 3 && model.reserved2.intValue == 0;
    self.detailBtn.backgroundColor = self.detailBtn.userInteractionEnabled ? UIColor.clearColor : [UIColor colorWithHexString:COLOR_BACK_COLOR];
}

- (IBAction)installAction:(id)sender{
    if (self.model.installType.intValue != 1 && self.model.installType.intValue != 3){
        return;
    }
    InstallViewController * install = [[InstallViewController alloc] init];
    if (self.model.installType.intValue == 1){
        install.deviceId = self.model.deviceId;
    }else if (self.model.installType.intValue == 3){
        install.installLogId = self.model.reserved1;
    }
    install.title = @"Installation";
    [RMHelper.getCurrentVC.navigationController pushViewController:install animated:true];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
