//
//  HomeTableViewCell.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/13.
//

#import "HomeTableViewCell.h"
#import "HomeItemView.h"
#import "HomeProgressView.h"

@interface HomeTableViewCell ()

@property(nonatomic,weak)IBOutlet UIView * itemContentView;
@property(nonatomic,weak)IBOutlet UIView * currentModelView;
@property(nonatomic,strong) HomeProgressView * progressView;
@property(nonatomic,weak)IBOutlet UILabel * currentMode;
@property(nonatomic,weak)IBOutlet UILabel * family;
@property(nonatomic,weak)IBOutlet UILabel * status;

@end

@implementation HomeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.currentMode.text = @"Current mode".localized;
    self.family.text = @"Energy independence rating(Daily):".localized;
    self.status.text = @"Device status:".localized;
    self.currentModelView.layer.cornerRadius = 16;
    self.currentModelView.layer.borderColor = [UIColor colorWithHexString:@"#2E2E2E"].CGColor;
    self.currentModelView.layer.borderWidth = 0.5;
    
    NSArray * normal = @[@"icon_grid_inactive",@"icon_solar_inactive",@"icon_generator_inactive",@"icon_ev_inactive",@"icon_non_backup_inactive",@"icon_backup_inactive"];
    NSArray * highlight = @[@"icon_grid_active",@"icon_solar_active",@"icon_generator_active",@"icon_ev_active",@"icon_non_backup_active",@"icon_backup_active"];
    for (int i=0; i<normal.count; i++) {
        HomeItemView * item = [[HomeItemView alloc] initWithFrame:CGRectMake(i%3*SCREEN_WIDTH/3, i/3*296, SCREEN_WIDTH/3, 100)];
        item.isFlip = i>2;
        item.titleLabel.text = @"Grid";
        item.descLabel.text = @"6 kWh";
        [item.statusButton setImage:[UIImage imageNamed:normal[i]] forState:UIControlStateNormal];
        [item.statusButton setImage:[UIImage imageNamed:highlight[i]] forState:UIControlStateSelected];
        [self.itemContentView addSubview:item];
        
        UIImageView * animationImageView = [[UIImageView alloc] init];
        animationImageView.contentMode = UIViewContentModeScaleToFill;
        if (i == 0 || i == 3) {
            animationImageView.frame = CGRectMake(SCREEN_WIDTH/6, i/3*160+99, SCREEN_WIDTH/3*2/2-21, 37);
        }else if (i == 1 || i == 4) {
            animationImageView.frame = CGRectMake(SCREEN_WIDTH/2-12, 162*i/3+46, 24, 35);
        }else{
            animationImageView.frame = CGRectMake((SCREEN_WIDTH/2+21), i/3*160+99, SCREEN_WIDTH/3*2/2-21, 37);
        }
        NSMutableArray * animationImageArray = [[NSMutableArray alloc] init];
        for (int j=0; j<3; j++) {
            if ((i == 1||i==4) && j == 2) {
                continue;;
            }
            [animationImageArray addObject:[UIImage imageNamed:[NSString stringWithFormat:@"%d-%d",i+1,j+1]]];
        }
        animationImageView.animationImages = animationImageArray;
        animationImageView.animationDuration = 2;
        animationImageView.animationRepeatCount = 0;
        [animationImageView startAnimating];
        [self.itemContentView addSubview:animationImageView];
    }
    
    self.progressView = [[HomeProgressView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-63, 134+70, 126, 126)];
    [self.contentView addSubview:self.progressView];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
