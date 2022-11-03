//
//  ServiceDescTableViewCell.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/10/28.
//

#import "ServiceDescTableViewCell.h"
#import "HelpViewController.h"
@import MLLabel;

@interface ServiceDescTableViewCell ()<MLLinkLabelDelegate>

@property(nonatomic,weak)IBOutlet MLLinkLabel * question;

@end

@implementation ServiceDescTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    NSString * faq = @"FAQ";
    NSString * hotline = @"hotline";
    self.question.text = [NSString stringWithFormat:@"For more information about troubleshooting, please refer to our %@.\nOur %@ will be available 24hrs Monday through Friday.",faq,hotline];
    self.question.lineBreakMode = NSLineBreakByWordWrapping;
    self.question.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    self.question.font = [UIFont systemFontOfSize:13];
    self.question.numberOfLines = 0;
    self.question.dataDetectorTypes = MLDataDetectorTypeAttributedLink;
    self.question.linkTextAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:COLOR_MAIN_COLOR]};
    self.question.activeLinkTextAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:COLOR_MAIN_COLOR],NSBackgroundColorAttributeName:UIColor.clearColor};
    self.question.activeLinkToNilDelay = 0.3;
    self.question.lineSpacing = 8;
    self.question.delegate = self;

    NSString * likeString = self.question.text;
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:likeString];
    [attributedText setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSLinkAttributeName:faq}
                            range:[likeString rangeOfString:faq]];
    [attributedText setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSLinkAttributeName:hotline}
                            range:[likeString rangeOfString:hotline]];
    self.question.attributedText = attributedText;
    
}

- (void)didClickLink:(MLLink *)link linkText:(NSString *)linkText linkLabel:(MLLinkLabel *)linkLabel{
    if ([linkText isEqualToString:@"FAQ"]){
        HelpViewController * help = [[HelpViewController alloc] init];
        help.hidesBottomBarWhenPushed = true;
        help.title = linkText;
        [RMHelper.getCurrentVC.navigationController pushViewController:help animated:true];
    }else if ([linkText isEqualToString:@"hotline"]){
        NSString *telephoneNumber = @"+18007612990";
        NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",telephoneNumber];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str] options:@{} completionHandler:nil];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
