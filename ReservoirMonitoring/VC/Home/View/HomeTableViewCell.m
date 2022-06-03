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
#import "GlobelDescAlertView.h"

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
@property(nonatomic,weak)IBOutlet UILabel * communication;
@property(nonatomic,weak)IBOutlet UILabel * communicationValue;

@end

@implementation HomeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.titleLabel.text = @"Power outage, backup energy in effect.".localized;
    self.currentMode.text = @"Current mode：".localized;
    self.family.text = @"Self reliable rating:".localized;
    self.status.text = @"Operation status:".localized;
    self.statusValue.text = @"online".localized;
    self.communication.text = @"Communication status：".localized;
    [self.currentModelView showBorderWithRadius:16];
    self.currentModelView.layer.borderColor = [UIColor colorWithHexString:@"#2E2E2E"].CGColor;
    self.currentModelView.layer.borderWidth = 0.5;
    
    NSArray * normal = @[@"icon_grid_inactive",@"icon_solar_inactive",@"icon_generator_inactive",@"icon_ev_inactive",@"icon_non_backup_inactive",@"icon_backup_inactive"];
    NSArray * highlight = @[@"icon_grid_active",@"icon_solar_active",@"icon_generator_active",@"icon_ev_active",@"icon_non_backup_active",@"icon_backup_active"];
    NSArray * titleArray = @[@"Grid".localized,@"Solar".localized,@"Generator".localized,@"EV".localized,@"Non-backup".localized,@"Backup loads".localized];
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
        self.statusValue.text = @"normal";
    }else{
        self.statusValue.text = @"fault";
    }
    
    if (BleManager.shareInstance.isConnented) {
        self.communicationValue.text = @"Online".localized;
        self.communicationValue.textColor = [UIColor colorWithHexString:COLOR_MAIN_COLOR];
    }else{
        self.communicationValue.text = @"Offline".localized;
        self.communicationValue.textColor = [UIColor colorWithHexString:@"#999999"];
    }
    
    
    for (UIView * view in self.itemContentView.subviews) {
        if ([view isKindOfClass:[HomeItemView class]]) {
            HomeItemView * itemView = (HomeItemView *)view;
            if (itemView.tag == 10) {
                itemView.descLabel.text = [NSString stringWithFormat:@"%.0f kWh",[model.gridValue floatValue]];
            }else if (itemView.tag == 11) {
                itemView.descLabel.text = [NSString stringWithFormat:@"%.0f kWh",[model.socValue floatValue]];
            }else if (itemView.tag == 12) {
                itemView.descLabel.text = [NSString stringWithFormat:@"%.0f kWh",[model.generatorValue floatValue]];
            }else if (itemView.tag == 13) {
                itemView.descLabel.text = [NSString stringWithFormat:@"%.0f kWh",[model.EVValue floatValue]];
            }else if (itemView.tag == 14) {
                itemView.descLabel.text = [NSString stringWithFormat:@"%.0f kWh",[model.otherLoadsValue floatValue]];
            }else{
                itemView.descLabel.text = [NSString stringWithFormat:@"%.0f kWh",[model.backupLoadsValue floatValue]];
            }
        }
    }
    self.progressView.titleLabel.text = [NSString stringWithFormat:@"%.0f kWh (%.0f%@)",[model.socValue floatValue],[model.soc floatValue],@"%"];
    self.progressView.progress = [model.soc floatValue]/100;
}

- (IBAction)timeAction:(id)sender{
    [GlobelDescAlertView showAlertViewWithTitle:@"Description".localized desc:@"Self reliable rating = (battery energy consumption/ total energy consumption ) %, daily rating stands for the performance of last 24h"];
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
