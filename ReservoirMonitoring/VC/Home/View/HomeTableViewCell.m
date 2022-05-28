//
//  HomeTableViewCell.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/13.
//

#import "HomeTableViewCell.h"
#import "HomeItemView.h"
#import "HomeProgressView.h"
#import "WeatherViewController.h"

@interface HomeTableViewCell ()

@property(nonatomic,weak)IBOutlet UIView * itemContentView;
@property(nonatomic,weak)IBOutlet UIView * currentModelView;
@property(nonatomic,strong) HomeProgressView * progressView;
@property(nonatomic,weak)IBOutlet UILabel * currentMode;
@property(nonatomic,weak)IBOutlet UILabel * currentModeValue;
@property(nonatomic,weak)IBOutlet UILabel * family;
@property(nonatomic,weak)IBOutlet UILabel * status;
@property(nonatomic,weak)IBOutlet UILabel * statusValue;
@property(nonatomic,weak)IBOutlet UILabel * titleLabel;

@end

@implementation HomeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.titleLabel.text = @"Power outage, backup energy in effect.".localized;
    self.currentMode.text = @"Current mode：".localized;
    self.family.text = @"Energy independence rating(Daily):".localized;
    self.status.text = @"Device status:".localized;
    self.statusValue.text = @"online".localized;
    [self.currentModelView showBorderWithRadius:16];
    self.currentModelView.layer.borderColor = [UIColor colorWithHexString:@"#2E2E2E"].CGColor;
    self.currentModelView.layer.borderWidth = 0.5;
    
    NSArray * normal = @[@"icon_grid_inactive",@"icon_solar_inactive",@"icon_generator_inactive",@"icon_ev_inactive",@"icon_non_backup_inactive",@"icon_backup_inactive"];
    NSArray * highlight = @[@"icon_grid_active",@"icon_solar_active",@"icon_generator_active",@"icon_ev_active",@"icon_non_backup_active",@"icon_backup_active"];
    NSArray * titleArray = @[@"Grid".localized,@"Solar".localized,@"Generator".localized,@"EV".localized,@"Other loads".localized,@"Backup loads".localized];
    for (int i=0; i<normal.count; i++) {
        HomeItemView * item = [[HomeItemView alloc] initWithFrame:CGRectMake(i%3*SCREEN_WIDTH/3, i/3*296, SCREEN_WIDTH/3, 100)];
        item.isFlip = i>2;
        item.titleLabel.text = titleArray[i];
        item.tag = i+10;
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
        animationImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"normal%d",i]];
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
//        [animationImageView startAnimating];
        [self.itemContentView addSubview:animationImageView];
    }
    
    self.progressView = [[HomeProgressView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-63, 134+70, 126, 126)];
    [self.contentView addSubview:self.progressView];
    
}

- (void)setModel:(DevideModel *)model{
    _model = model;
    if (model.currentMode.intValue == 0) {
        self.currentModeValue.text = @"Self-consumption";
    }else if(model.currentMode.intValue == 1){
        self.currentModeValue.text = @"Back up";
    }else if (model.currentMode.intValue == 2){
        self.currentModeValue.text = @"Time Of Use";
    }else{
        self.currentModeValue.text = @"Offine";
    }
    
    if (model.deviceStatus.intValue == 0) {
        self.statusValue.text = @"自检";
    }else if (model.deviceStatus.intValue == 1) {
        self.statusValue.text = @"故障";
    }else if (model.deviceStatus.intValue == 2) {
        self.statusValue.text = @"空闲";
    }else if (model.deviceStatus.intValue == 3) {
        self.statusValue.text = @"待机";
    }else{
        self.statusValue.text = @"运行";
    }
    
    for (UIView * view in self.itemContentView.subviews) {
        if ([view isKindOfClass:[HomeItemView class]]) {
            HomeItemView * itemView = (HomeItemView *)view;
            if (itemView.tag == 10) {
                itemView.descLabel.text = model.gridValue;
            }else if (itemView.tag == 11) {
                itemView.descLabel.text = model.socValue;
            }else if (itemView.tag == 12) {
                itemView.descLabel.text = model.generatorValue;
            }else if (itemView.tag == 13) {
                itemView.descLabel.text = model.EVValue;
            }else if (itemView.tag == 14) {
                itemView.descLabel.text = model.otherLoadsValue;
            }else{
                itemView.descLabel.text = model.backupLoadsValue;
            }
        }
    }
    self.progressView.titleLabel.text = [NSString stringWithFormat:@"%@ kWh (%@%)",model.socValue,model.soc];
}

- (IBAction)weatherAction:(id)sender{
    WeatherViewController * weather = [[WeatherViewController alloc] init];
    weather.title = @"Weather forecast".localized;
    weather.hidesBottomBarWhenPushed = true;
    [RMHelper.getCurrentVC.navigationController pushViewController:weather animated:true];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
