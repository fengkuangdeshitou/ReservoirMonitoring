//
//  SetTableViewCell.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/18.
//

#import "SetTableViewCell.h"

@interface SetTableViewCell ()

@property(nonatomic,weak)IBOutlet UIView * container;

@end

@implementation SetTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    if (RMHelper.isTouristsModel){
        self.container.backgroundColor = [UIColor colorWithHexString:COLOR_TOURISTS_COLOR];
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
