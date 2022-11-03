//
//  ServiceInputTableViewCell.m
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/10/13.
//

#import "ServiceInputTableViewCell.h"
#import "UITextView+Placeholder.h"

@interface ServiceInputTableViewCell ()

@property(nonatomic,weak)IBOutlet UIView * contarner;

@end

@implementation ServiceInputTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.contarner.layer.borderColor = [UIColor.whiteColor colorWithAlphaComponent:0.2].CGColor;
    self.contarner.layer.borderWidth = 1;
    self.contarner.layer.cornerRadius = 4;
    self.content.placeholder = @"Please enter the description";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
