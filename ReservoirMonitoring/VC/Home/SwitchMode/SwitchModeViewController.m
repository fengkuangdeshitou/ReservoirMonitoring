//
//  SwitchModeViewController.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/16.
//

#import "SwitchModeViewController.h"
#import "SwitchModelTableViewCell.h"
#import "SwitchProgressTableViewCell.h"
#import "PeakTimeTableViewCell.h"
#import "GlobelDescAlertView.h"

@interface SwitchModeViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,weak)IBOutlet UITableView * tableView;
@property(nonatomic,weak)IBOutlet UIButton * submitButton;
@property(nonatomic,weak)IBOutlet UIButton * weatherBtn;
@property(nonatomic,assign)NSInteger flag;
@property(nonatomic,weak)IBOutlet UILabel * weather;
@property(nonatomic,strong)NSArray * progressArray;

@end

@implementation SwitchModeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.weather.text = @"Weather watch".localized;
    [self.submitButton setTitle:@"Submit".localized forState:UIControlStateNormal];
    [[NSNotificationCenter defaultCenter] addObserverForName:TIME_TABLEVIEW_HEIGHT_CHANGE object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self.tableView reloadData];
    }];
    [self.submitButton showBorderWithRadius:25];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SwitchModelTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([SwitchModelTableViewCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SwitchProgressTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([SwitchProgressTableViewCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([PeakTimeTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([PeakTimeTableViewCell class])];
    
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [BleManager.shareInstance readWithCMDString:@"621" count:1 finish:^(NSArray * _Nonnull array) {
            self.weatherBtn.selected = [array.firstObject boolValue];
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"623" count:2 finish:^(NSArray * _Nonnull array) {
            self.progressArray = array;
            dispatch_semaphore_signal(semaphore);
        }];
    });
    
}

- (IBAction)helpAction:(id)sender{
    [GlobelDescAlertView showAlertViewWithTitle:@"Weather watch".localized desc:@"Monitor local weather condition, automatically stores energy for hazard backup."];
}

- (IBAction)submitAction:(id)sender{
    PeakTimeTableViewCell * cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]];
    SwitchProgressTableViewCell * cell1 = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    SwitchProgressTableViewCell * cell2 = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
    [params setValue:self.devId forKey:@"devId"];
    [params setValue:self.weatherBtn.selected ? @"1" : @"0" forKey:@"weatherWatch"];
    [params setValue:[NSString stringWithFormat:@"%ld",self.flag] forKey:@"workStatus"];
    [params setValue:[NSString stringWithFormat:@"%.0f",cell1.progress] forKey:@"selfConsumptioinReserveSoc"];
    [params setValue:[NSString stringWithFormat:@"%.0f",cell2.progress] forKey:@"backupPowerReserveSoc"];
    [params setValue:[NSString stringWithFormat:@"%@",cell.switchBtn.selected ? @"1" : @"0"] forKey:@"allowChargingXiaGrid"];
    NSMutableArray * offPeakArray = [[NSMutableArray alloc] init];
    for (int i=0; i<[cell.dataArray[0] count]; i++) {
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        TimeTableViewCell * timeCell = [cell.tableView cellForRowAtIndexPath:indexPath];
        NSLog(@"start=%@,end=%@",timeCell.startTime.text,timeCell.endTime.text);
        NSString * string = [NSString stringWithFormat:@"%@_%@_%@",timeCell.startTime.text,timeCell.endTime.text,timeCell.electricity.text];
        [offPeakArray addObject:string];
    }
    [params setValue:offPeakArray forKey:@"offPeakTimeList"];
    
    NSMutableArray * peakTimeArray = [[NSMutableArray alloc] init];
    for (int i=0; i<[cell.dataArray[1] count]; i++) {
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:1];
        TimeTableViewCell * timeCell = [cell.tableView cellForRowAtIndexPath:indexPath];
        NSLog(@"start=%@,end=%@",timeCell.startTime.text,timeCell.endTime.text);
        NSString * string = [NSString stringWithFormat:@"%@_%@_%@",timeCell.startTime.text,timeCell.endTime.text,timeCell.electricity.text];
        [peakTimeArray addObject:string];
    }
    [params setValue:peakTimeArray forKey:@"peakTimeList"];
    
    NSMutableArray * superPeakTimeArray = [[NSMutableArray alloc] init];
    for (int i=0; i<[cell.dataArray[2] count]; i++) {
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:2];
        TimeTableViewCell * timeCell = [cell.tableView cellForRowAtIndexPath:indexPath];
        NSLog(@"start=%@,end=%@",timeCell.startTime.text,timeCell.endTime.text);
        NSString * string = [NSString stringWithFormat:@"%@_%@_%@",timeCell.startTime.text,timeCell.endTime.text,timeCell.electricity.text];
        [superPeakTimeArray addObject:string];
    }
    [params setValue:superPeakTimeArray forKey:@"superPeakTimeList"];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        __block NSString * weather = @"";
        dispatch_async(dispatch_get_main_queue(), ^{
            weather = self.weatherBtn.selected ? @"1" : @"0";
        });
        [BleManager.shareInstance writeWithCMDString:@"621" array:@[weather] finish:^{
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance writeWithCMDString:@"623" array:@[[NSString stringWithFormat:@"%.0f",cell1.progress],[NSString stringWithFormat:@"%.0f",cell2.progress]] finish:^{
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance writeWithCMDString:@"6FF" array:@[[NSString stringWithFormat:@"%ld",[cell.dataArray[0] count]]] finish:^{
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        __block NSString * startTime0 = @"";
        __block NSString * endTime0 = @"";
        dispatch_async(dispatch_get_main_queue(), ^{
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            TimeTableViewCell * timeCell = [cell.tableView cellForRowAtIndexPath:indexPath];
            startTime0 = timeCell.startTime.text;
            endTime0 = timeCell.endTime.text;
        });
        [BleManager.shareInstance writeWithCMDString:@"702" array:@[[startTime0 componentsSeparatedByString:@":"].firstObject,[startTime0 componentsSeparatedByString:@":"].lastObject,[endTime0 componentsSeparatedByString:@":"].firstObject,[endTime0 componentsSeparatedByString:@":"].lastObject,] finish:^{
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSArray * timeArray = cell.dataArray[0];
        if (timeArray.count > 1) {
            __block NSString * startTime1 = @"";
            __block NSString * endTime1 = @"";
            dispatch_async(dispatch_get_main_queue(), ^{
                NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
                TimeTableViewCell * timeCell = [cell.tableView cellForRowAtIndexPath:indexPath];
                startTime1 = timeCell.startTime.text;
                endTime1 = timeCell.endTime.text;
            });
            [BleManager.shareInstance writeWithCMDString:@"708" array:@[[startTime1 componentsSeparatedByString:@":"].firstObject,[startTime1 componentsSeparatedByString:@":"].lastObject,[endTime1 componentsSeparatedByString:@":"].firstObject,[endTime1 componentsSeparatedByString:@":"].lastObject,] finish:^{
                dispatch_semaphore_signal(semaphore);
            }];
        }else{
            dispatch_semaphore_signal(semaphore);
        }
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        if (timeArray.count>2) {
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            __block NSString * startTime2 = @"";
            __block NSString * endTime2 = @"";
            dispatch_async(dispatch_get_main_queue(), ^{
                NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
                TimeTableViewCell * timeCell = [cell.tableView cellForRowAtIndexPath:indexPath];
                startTime2 = timeCell.startTime.text;
                endTime2 = timeCell.endTime.text;
            });
            [BleManager.shareInstance writeWithCMDString:@"70E" array:@[[startTime2 componentsSeparatedByString:@":"].firstObject,[startTime2 componentsSeparatedByString:@":"].lastObject,[endTime2 componentsSeparatedByString:@":"].firstObject,[endTime2 componentsSeparatedByString:@":"].lastObject,] finish:^{
                dispatch_semaphore_signal(semaphore);
            }];
        }else{
            dispatch_semaphore_signal(semaphore);
        }
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance writeWithCMDString:@"750" array:@[@"1"] finish:^{
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"752" count:1 finish:^(NSArray * _Nonnull array) {
            NSInteger idx = [array.firstObject intValue];
            if (idx == 1) {
                [RMHelper showToast:@"Configuration is successful" toView:self.view];
                [self switchWithParams:params];
            }
            if (idx == 2) {
                [RMHelper showToast:@"In the configuration" toView:self.view];
                [self switchWithParams:params];
            }
            if (idx == 3) {
                [RMHelper showToast:@"Configuration failed" toView:self.view];
            }
        }];
    });
}

- (void)switchWithParams:(NSDictionary *)params{
    [Request.shareInstance postUrl:SwitchMode params:params progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        [RMHelper showToast:@"swithc mode success" toView:self.view];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popToRootViewControllerAnimated:true];
        });
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        SwitchModelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchModelTableViewCell class]) forIndexPath:indexPath];
        cell.icon.image = [UIImage imageNamed:self.flag == indexPath.section ? @"icon_choose" : @"icon_unchoose"];
        cell.titleLabel.text = indexPath.section == 0 ? @"Self-consumption" : (indexPath.section == 1 ? @"Back up" : @"Time Of Use");
        cell.indexPath = indexPath;
        return cell;
    }else{
        if (indexPath.section == 2) {
            PeakTimeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([PeakTimeTableViewCell class]) forIndexPath:indexPath];
            return cell;
        }else{
            SwitchProgressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchProgressTableViewCell class]) forIndexPath:indexPath];
            cell.progress = [self.progressArray[indexPath.section] floatValue]/100;
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.flag = indexPath.section;
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.flag == section) {
        return 2;
    }else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 44;
    }else{
        if (indexPath.section == 2) {
            return [NSUserDefaults.standardUserDefaults objectForKey:TIME_TABLEVIEW_HEIGHT_CHANGE] ? [[NSUserDefaults.standardUserDefaults objectForKey:TIME_TABLEVIEW_HEIGHT_CHANGE] floatValue]+15 : 500;
        }else{
            return 77;
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 47)];
    headerView.backgroundColor = UIColor.clearColor;
    headerView.clipsToBounds = true;
    
    UIView * colorView = [[UIView alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH-30, 47)];
    colorView.backgroundColor = [UIColor colorWithHexString:@"#1B1B1B"];
    [headerView addSubview:colorView];
    
    UILabel * label = [[UILabel alloc] init];
    [colorView addSubview:label];
    label.text = @"Switch operation mode".localized;
    label.textColor = UIColor.whiteColor;
    label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.mas_equalTo(15);
            make.height.mas_equalTo(22);
    }];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section == 0 ? 47 : 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
