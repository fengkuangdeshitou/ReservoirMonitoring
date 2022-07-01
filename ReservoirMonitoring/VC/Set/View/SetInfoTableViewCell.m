//
//  SetInfoTableViewCell.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/18.
//

#import "SetInfoTableViewCell.h"
#import "SDWebImage.h"

@interface SetInfoTableViewCell ()

@property(nonatomic,weak)IBOutlet UILabel * nickname;
@property(nonatomic,weak)IBOutlet UILabel * email;
@property(nonatomic,weak)IBOutlet UILabel * type;
@property(nonatomic,weak)IBOutlet UIImageView * avatar;

@end

@implementation SetInfoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setModel:(UserModel *)model{
    _model = model;
    self.type.text = model.userType.intValue == 1 ? @"Installer".localized : @"User".localized;
    self.nickname.text = model.nickName;
    self.email.text = model.email;
    [self.avatar sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",Host,model.avatar]] placeholderImage:[UIImage imageNamed:@"info"]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
