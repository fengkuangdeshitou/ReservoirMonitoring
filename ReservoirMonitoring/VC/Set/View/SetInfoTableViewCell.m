//
//  SetInfoTableViewCell.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/18.
//

#import "SetInfoTableViewCell.h"

@interface SetInfoTableViewCell ()

@property(nonatomic,weak)IBOutlet UILabel * type;

@end

@implementation SetInfoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.type.text = @"User/Installer".localized;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
