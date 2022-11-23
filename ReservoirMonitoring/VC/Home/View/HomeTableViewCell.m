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
#import "LineAnimatiionView.h"

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
@property(nonatomic,weak)IBOutlet UILabel * selfHelpRate;
@property(nonatomic,weak)IBOutlet UIButton * weather;

@end

@implementation HomeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
//    self.titleLabel.text = @"Power outage, backup energy in effect.".localized;
    self.currentMode.text = @"Current mode：".localized;
    self.family.text = @"EP CUBE contribution ratio:".localized;
    self.status.text = @"Operation status:".localized;
    self.statusValue.text = @"online".localized;
    self.communication.text = @"Communication status：".localized;
    
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
        
        LineAnimatiionView * animationImageView = [[LineAnimatiionView alloc] init];
        if (i == 0 || i == 3) {
            animationImageView.frame = CGRectMake(SCREEN_WIDTH/6-4, i/3*160+99, SCREEN_WIDTH/3*2/2-21+4, 37);
        }else if (i == 1 || i == 4) {
            animationImageView.frame = CGRectMake(SCREEN_WIDTH/2-12, 162*i/3+46, 24, 35);
        }else{
            animationImageView.frame = CGRectMake((SCREEN_WIDTH/2+21), i/3*160+99, SCREEN_WIDTH/3*2/2-21+4, 37);
        }
        animationImageView.source = i;
        animationImageView.direction = i;
        animationImageView.tag = i+100;
        [self.itemContentView addSubview:animationImageView];
    }
    
    self.progressView = [[HomeProgressView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-63, 134+70, 126, 126)];
    [self.contentView addSubview:self.progressView];
    
}

- (NSArray *)loadAnimationArray:(int)i count:(int)count{
    NSMutableArray * animationImageArray = [[NSMutableArray alloc] init];
    for (int j=0; j<count; j++) {
        [animationImageArray addObject:[UIImage imageNamed:[NSString stringWithFormat:@"%d-%d",i+1,j+1]]];
    }
    return animationImageArray;
}

- (void)setModel:(DevideModel *)model{
    _model = model;
    self.titleLabel.text = model.off_ON_Grid_Hint;
    if (model.weather) {
        [self.weather setTitle:@"" forState:UIControlStateNormal];
        [self.weather setImage:[UIImage imageNamed:model.weather[@"icon"]] forState:UIControlStateNormal];
    }else{
        [self.weather setImage:[UIImage new] forState:UIControlStateNormal];
        [self.weather setTitle:@"--" forState:UIControlStateNormal];
    }
    if (model.workStatus.intValue == 1) {
        self.currentModeValue.text = @"Self-consumption";
    }else if (model.workStatus.intValue == 2){
        self.currentModeValue.text = @"Time of Use";
    }else if(model.workStatus.intValue == 3){
        self.currentModeValue.text = @"Back up";
    }else{
        self.currentModeValue.text = @"Offline";
    }
    
    self.progressView.titleLabel.text = [NSString stringWithFormat:@"%.2f kWh (%.0f%@)",[model.batteryCurrentElectricity floatValue],[model.batterySoc floatValue],@"%"];
    self.progressView.progress = [model.batterySoc floatValue]/100;
    
    if (BleManager.shareInstance.isConnented) {
        CGFloat divided = model.evElectricity+model.nonBackUpElectricity+model.backUpElectricity;
        CGFloat rate = ((model.evElectricity + model.nonBackUpElectricity + model.backUpElectricity)-model.gridElectricity)/divided*100;
        self.selfHelpRate.text = [[NSString stringWithFormat:@"%.0f",divided==0?0:rate] stringByAppendingString:@"%"];
    }else{
        self.selfHelpRate.text = [[NSString stringWithFormat:@"%.0f",model.selfHelpRate] stringByAppendingString:@"%"];
    }
    if ([RMHelper getBleDataValue:model.gridPower min:-50 max:50] > 0) {
        LineAnimatiionView * animation = [self.itemContentView viewWithTag:100];
        animation.direction = AnimationStartDirectionLeftTop;
        animation.showAnimation = true;
    }else if ([RMHelper getBleDataValue:model.gridPower min:-50 max:50] < 0){
        LineAnimatiionView * animation = [self.itemContentView viewWithTag:100];
        animation.direction = AnimationStartDirectionRightBottom;
        animation.showAnimation = true;
    }else{
        LineAnimatiionView * animation = [self.itemContentView viewWithTag:100];
        animation.showAnimation = false;
    }
    
    if ([RMHelper getBleDataValue:model.solarPower min:-5 max:5] > 0) {
        LineAnimatiionView * animation = [self.itemContentView viewWithTag:101];
        animation.showAnimation = true;
    }else{
        LineAnimatiionView * animation = [self.itemContentView viewWithTag:101];
        animation.showAnimation = false;
    }
    
    if ([RMHelper getBleDataValue:model.generatorPower min:-50 max:50] > 0) {
        LineAnimatiionView * animation = [self.itemContentView viewWithTag:102];
        animation.showAnimation = true;
    }else{
        LineAnimatiionView * animation = [self.itemContentView viewWithTag:102];
        animation.showAnimation = false;
    }
    
    if ([RMHelper getBleDataValue:model.evPower min:-50 max:50] > 0) {
        LineAnimatiionView * animation = [self.itemContentView viewWithTag:103];
        animation.showAnimation = true;
    }else{
        LineAnimatiionView * animation = [self.itemContentView viewWithTag:103];
        animation.showAnimation = false;
    }
    
    if ([RMHelper getBleDataValue:model.nonBackUpPower min:-50 max:50] > 0) {
        LineAnimatiionView * animation = [self.itemContentView viewWithTag:104];
        animation.showAnimation = true;
    }else{
        LineAnimatiionView * animation = [self.itemContentView viewWithTag:104];
        animation.showAnimation = false;
    }
    
    if ([RMHelper getBleDataValue:model.backUpPower min:-50 max:50] > 0) {
        LineAnimatiionView * animation = [self.itemContentView viewWithTag:105];
        animation.showAnimation = true;
    }else{
        LineAnimatiionView * animation = [self.itemContentView viewWithTag:105];
        animation.showAnimation = false;
    }
    
    if (RMHelper.getUserType && RMHelper.getLoadDataForBluetooth) {
        if (BleManager.shareInstance.isConnented) {
            self.communicationValue.text = @"Online".localized;
            self.communicationValue.textColor = [UIColor colorWithHexString:COLOR_MAIN_COLOR];
            [self loadItemIconWithHighlighted:true];
            if (model.systemStatus.intValue == 1) {
                self.statusValue.text = @"Fault";
                self.statusValue.textColor = [UIColor redColor];
            }else{
                self.statusValue.text = @"Normal";
                self.statusValue.textColor = [UIColor colorWithHexString:COLOR_MAIN_COLOR];
            }
        }else{
            self.communicationValue.text = @"Offline".localized;
            self.communicationValue.textColor = [UIColor colorWithHexString:@"#999999"];
            self.statusValue.text = @"Offline".localized;
            self.statusValue.textColor = [UIColor colorWithHexString:@"#999999"];
            [self hiddenAnimationView];
            [self loadItemIconWithHighlighted:false];
        }
    }else{
        if (model.isOnline.intValue == 1){
            self.communicationValue.text = @"Online".localized;
            self.communicationValue.textColor = [UIColor colorWithHexString:COLOR_MAIN_COLOR];
            [self loadItemIconWithHighlighted:true];
            if (model.systemStatus) {
                if (model.systemStatus.intValue == 1) {
                    self.statusValue.text = @"Fault";
                    self.statusValue.textColor = [UIColor redColor];
                }else{
                    self.statusValue.text = @"Normal";
                    self.statusValue.textColor = [UIColor colorWithHexString:COLOR_MAIN_COLOR];
                }
            }else{
                self.statusValue.text = @"Offline".localized;
                self.statusValue.textColor = [UIColor colorWithHexString:@"#999999"];
                [self hiddenAnimationView];
                [self loadItemIconWithHighlighted:false];
            }
        }else{
            self.statusValue.text = @"Offline".localized;
            self.statusValue.textColor = [UIColor colorWithHexString:@"#999999"];
            self.communicationValue.text = @"Offline".localized;
            self.communicationValue.textColor = [UIColor colorWithHexString:@"#999999"];
            [self hiddenAnimationView];
            [self loadItemIconWithHighlighted:false];
        }
    }
    
    LineAnimatiionView * animation = [self.itemContentView viewWithTag:104];
    HomeItemView * itemView = [self.itemContentView viewWithTag:14];
    animation.hidden = model.backUpType.intValue == 1;
    itemView.hidden = model.backUpType.intValue == 1;
    
}


/// 动画隐藏
- (void)hiddenAnimationView{
    for (UIView * view in self.itemContentView.subviews) {
        if ([view isKindOfClass:[LineAnimatiionView class]]) {
            ((LineAnimatiionView *)view).showAnimation = false;
        }
    }
}

/// 图标是否高亮
- (void)loadItemIconWithHighlighted:(BOOL)highlighte{
    for (UIView * view in self.itemContentView.subviews) {
        if ([view isKindOfClass:[HomeItemView class]]) {
            HomeItemView * itemView = (HomeItemView *)view;
            if (itemView.tag == 10) {
                if (highlighte) {
                    BOOL value = BleManager.shareInstance.isConnented ? self.model.gridLight == 1 : [self.model.isOnline boolValue] && self.model.gridLight == 1;
                    itemView.descLabel.textColor = [UIColor colorWithHexString:value?COLOR_MAIN_COLOR:@"#747474"];
                    itemView.statusButton.selected = value;
                }else{
                    itemView.descLabel.textColor = [UIColor colorWithHexString:@"#747474"];
                    itemView.statusButton.selected = false;
                }
                itemView.descLabel.text = [NSString stringWithFormat:@"%.2f kWh",self.model.gridElectricity];
            }else if (itemView.tag == 11) {
                if (highlighte) {
                    BOOL value = [self.model.isOnline boolValue] || BleManager.shareInstance.isConnented;
                    itemView.descLabel.textColor = [UIColor colorWithHexString:value?COLOR_MAIN_COLOR:@"#747474"];
                    itemView.statusButton.selected = value;
                }else{
                    itemView.descLabel.textColor = [UIColor colorWithHexString:@"#747474"];
                    itemView.statusButton.selected = false;
                }
                itemView.descLabel.text = [NSString stringWithFormat:@"%.2f kWh",self.model.solarElectricity];
            }else if (itemView.tag == 12) {
                if (highlighte) {
                    BOOL value = BleManager.shareInstance.isConnented ? self.model.generatorLight == 1 : [self.model.isOnline boolValue] && self.model.generatorLight == 1;
                    itemView.descLabel.textColor = [UIColor colorWithHexString:value?COLOR_MAIN_COLOR:@"#747474"];
                    itemView.statusButton.selected = value;
                }else{
                    itemView.descLabel.textColor = [UIColor colorWithHexString:@"#747474"];
                    itemView.statusButton.selected = false;
                }
                itemView.descLabel.text = [NSString stringWithFormat:@"%.2f kWh",self.model.generatorElectricity];
            }else if (itemView.tag == 13) {
                if (highlighte) {
                    BOOL value = BleManager.shareInstance.isConnented ? (self.model.evLight == 2 || self.model.generatorLight == 2) : ([self.model.isOnline boolValue] && (self.model.evLight == 2 || self.model.generatorLight == 2));
                    itemView.descLabel.textColor = [UIColor colorWithHexString:value?COLOR_MAIN_COLOR:@"#747474"];
                    itemView.statusButton.selected = value;
                }else{
                    itemView.descLabel.textColor = [UIColor colorWithHexString:@"#747474"];
                    itemView.statusButton.selected = false;
                }
                itemView.descLabel.text = [NSString stringWithFormat:@"%.2f kWh",self.model.evElectricity];
            }else if (itemView.tag == 14) {
                if (highlighte) {
                    BOOL value = BleManager.shareInstance.isConnented ? self.model.backUpType.intValue == 0 : [self.model.isOnline boolValue] && self.model.backUpType.intValue == 0;
                    itemView.descLabel.textColor = [UIColor colorWithHexString:value?COLOR_MAIN_COLOR:@"#747474"];
                    itemView.statusButton.selected = value;
                }else{
                    itemView.descLabel.textColor = [UIColor colorWithHexString:@"#747474"];
                    itemView.statusButton.selected = false;
                }
                itemView.descLabel.text = [NSString stringWithFormat:@"%.2f kWh",self.model.nonBackUpElectricity];
            }else{
                if (highlighte) {
                    BOOL value = [self.model.isOnline boolValue] || BleManager.shareInstance.isConnented;
                    itemView.descLabel.textColor = [UIColor colorWithHexString:value?COLOR_MAIN_COLOR:@"#747474"];
                    itemView.statusButton.selected = value;
                }else{
                    itemView.descLabel.textColor = [UIColor colorWithHexString:@"#747474"];
                    itemView.statusButton.selected = false;
                }
                itemView.descLabel.text = [NSString stringWithFormat:@"%.2f kWh",self.model.backUpElectricity];
            }
        }
    }
}

- (IBAction)timeAction:(id)sender{
    [GlobelDescAlertView showAlertViewWithTitle:@"Description".localized desc:@"EP CUBE contribution ratio = (battery energy consumption / total energy consumption)%, daily rating stands for the performance of the current day." btnTitle:nil completion:nil];
}

- (IBAction)weatherAction:(id)sender{
    WeatherViewController * weather = [[WeatherViewController alloc] init];
    weather.title = @"Weather forecast".localized;
    weather.hidesBottomBarWhenPushed = true;
    weather.deviceId = self.model.deviceId;
    [RMHelper.getCurrentVC.navigationController pushViewController:weather animated:true];
}

- (BOOL)formatPower:(CGFloat)value{
    BOOL power = false;
    if (value > 32768) {
        int result = value-65535;
        if (result > 50) {
            power = true;
        }
    }else{
        if (value > 0) {
            power = true;
        }
    }
    return power;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
