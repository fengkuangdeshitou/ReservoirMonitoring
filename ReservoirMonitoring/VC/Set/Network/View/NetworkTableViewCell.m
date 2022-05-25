//
//  NetworkTableViewCell.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/5/9.
//

#import "NetworkTableViewCell.h"

@interface NetworkTableViewCell ()

@property(nonatomic,weak)IBOutlet UILabel * titleLabel;
@property(nonatomic,weak)IBOutlet UILabel * address;

@end

@implementation NetworkTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setModel:(PeripheralModel *)model{
    _model = model;
    self.titleLabel.text = model.peripheral.name;
    self.address.text = [NSString stringWithFormat:@"SN:%@",[model.peripheral.name componentsSeparatedByString:@"-"].lastObject];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end