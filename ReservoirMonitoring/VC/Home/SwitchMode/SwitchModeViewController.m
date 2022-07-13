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
@property(nonatomic,strong)IBOutlet UIButton * weatherBtn;
@property(nonatomic,assign)NSInteger flag;
@property(nonatomic,weak)IBOutlet UILabel * weather;
@property(nonatomic,strong)NSMutableArray * progressArray;
@property(nonatomic,strong)NSString * viagrid;
@property(nonatomic,strong)NSString * touCount;
@property(nonatomic,assign)BOOL allowChargingXiaGrid;
@property(nonatomic,strong)NSMutableArray * touArray;
@property(nonatomic,strong)NSArray * titleArray;

@end

@implementation SwitchModeViewController

- (IBAction)weatherClick:(UIButton *)sender{
    sender.selected = !sender.selected;
}

- (void)getSwitchModeData{
    [Request.shareInstance getUrl:GetSwitchMode params:@{@"devId":self.deviceId} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        NSDictionary * data = result[@"data"];
        if (data.count == 0) {
            return;
        }
        self.weatherBtn.selected = [data[@"weatherWatch"] boolValue];
        NSInteger workStatus = [data[@"workStatus"] intValue];
        if (workStatus == 1) {
            self.flag = 0;
            NSString * selfConsumptioinReserveSoc = data[@"selfConsumptioinReserveSoc"];
            [self.progressArray replaceObjectAtIndex:self.flag withObject:selfConsumptioinReserveSoc];
        }else if (workStatus == 3){
            self.flag = 1;
            NSString * backupPowerReserveSoc = data[@"backupPowerReserveSoc"];
            [self.progressArray replaceObjectAtIndex:self.flag withObject:backupPowerReserveSoc];
        }else if (workStatus == 2){
            self.flag = 2;
            self.allowChargingXiaGrid = [data[@"allowChargingXiaGrid"] boolValue];
            NSArray * offPeakTimeList = data[@"offPeakTimeList"];
            for (int i=0; i<offPeakTimeList.count; i++) {
                NSString * string = offPeakTimeList[i];
                if ([string componentsSeparatedByString:@"_"].count < 2) {
                    continue;
                }
                NSArray * timeArray = [string componentsSeparatedByString:@"_"];
                NSString * startTime = timeArray[0];
                NSString * endTime = timeArray[1];
                NSDictionary * dict = @{@"startTime":startTime,@"endTime":endTime,@"price":timeArray[2]};
                [self.touArray addObject:dict];
            }
        }
        [self.tableView reloadData];
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.titleArray = @[@"Self-consumption",@"Back up",@"Time Of Use"];
    self.progressArray = [[NSMutableArray alloc] initWithObjects:@"0",@"0",@"", nil];
    self.weather.text = @"Weather watch".localized;
    [self.submitButton setTitle:@"Submit".localized forState:UIControlStateNormal];
    [[NSNotificationCenter defaultCenter] addObserverForName:TIME_TABLEVIEW_HEIGHT_CHANGE object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [UIView performWithoutAnimation:^{
            [self.tableView beginUpdates];
            [self.tableView endUpdates];
        }];
    }];
    [self.submitButton showBorderWithRadius:25];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SwitchModelTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([SwitchModelTableViewCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SwitchProgressTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([SwitchProgressTableViewCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([PeakTimeTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([PeakTimeTableViewCell class])];
    
    self.progressArray = [[NSMutableArray alloc] initWithArray:@[@"0",@"0",@""]];
    self.touArray = [[NSMutableArray alloc] init];
    
    if (RMHelper.getUserType) {
        if (RMHelper.getLoadDataForBluetooth) {
            [self loadBluetoothData];
        }else{
            [self getSwitchModeData];
        }
    }else{
        [self getSwitchModeData];
    }
}

- (void)loadBluetoothData{
    if (BleManager.shareInstance.isConnented) {
        [self.view showHUDToast:@"Loading"];
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [BleManager.shareInstance readWithCMDString:@"621" count:1 finish:^(NSArray * _Nonnull array) {
            self.weatherBtn.selected = [array.firstObject boolValue];
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"511" count:1 finish:^(NSArray * _Nonnull array) {
            int value = [array.firstObject intValue];
            NSLog(@"flag=%d",value);
            if (value == 3) {
                self.flag = 1;
            }else if (value == 2){
                self.flag = 2;
            }else if (value == 1){
                self.flag = 0;
            }else{
                self.flag = 0;
            }
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        if (self.flag == 0) {
            [BleManager.shareInstance readWithCMDString:@"624" count:1 finish:^(NSArray * _Nonnull array) {
                [self.progressArray replaceObjectAtIndex:0 withObject:array.firstObject];
                dispatch_semaphore_signal(semaphore);
            }];
        }else if (self.flag == 1){
            [BleManager.shareInstance readWithCMDString:@"623" count:1 finish:^(NSArray * _Nonnull array) {
                [self.progressArray replaceObjectAtIndex:1 withObject:array.firstObject];
                dispatch_semaphore_signal(semaphore);
            }];
        }else if (self.flag == 2){
            [BleManager.shareInstance readWithCMDString:@"6FE" count:2 finish:^(NSArray * _Nonnull array) {
                self.viagrid = array.firstObject;
                self.touCount = array.lastObject;
                dispatch_semaphore_signal(semaphore);
            }];
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            if (self.touCount.intValue == 0) {
                NSDictionary * item = @{@"startTime":@"",@"endTime":@"",@"price":@""};
                [self.touArray addObject:item];
                dispatch_semaphore_signal(semaphore);
            }else if (self.touCount.intValue == 1) {
                [BleManager.shareInstance readWithCMDString:@"702" count:4 finish:^(NSArray * _Nonnull array) {
                    NSDictionary * item = @{
                        @"startTime":[NSString stringWithFormat:@"%@:%@",array[0],array[1]],
                        @"endTime":[NSString stringWithFormat:@"%@:%@",array[2],array[3]],
                    };
                    [self.touArray addObject:item];
                    dispatch_semaphore_signal(semaphore);
                }];
            }else if (self.touCount.intValue == 2) {
                [BleManager.shareInstance readWithCMDString:@"702" count:4 finish:^(NSArray * _Nonnull array) {
                    NSDictionary * item = @{
                        @"startTime":[NSString stringWithFormat:@"%@:%@",array[0],array[1]],
                        @"endTime":[NSString stringWithFormat:@"%@:%@",array[2],array[3]],
                    };
                    [self.touArray addObject:item];
                    dispatch_semaphore_signal(semaphore);
                }];
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                [BleManager.shareInstance readWithCMDString:@"708" count:4 finish:^(NSArray * _Nonnull array) {
                    NSDictionary * item = @{
                        @"startTime":[NSString stringWithFormat:@"%@:%@",array[0],array[1]],
                        @"endTime":[NSString stringWithFormat:@"%@:%@",array[2],array[3]],
                    };
                    [self.touArray addObject:item];
                    dispatch_semaphore_signal(semaphore);
                }];
            }else if (self.touCount.intValue == 3) {
                [BleManager.shareInstance readWithCMDString:@"702" count:4 finish:^(NSArray * _Nonnull array) {
                    NSDictionary * item = @{
                        @"startTime":[NSString stringWithFormat:@"%@:%@",array[0],array[1]],
                        @"endTime":[NSString stringWithFormat:@"%@:%@",array[2],array[3]],
                    };
                    [self.touArray addObject:item];
                    dispatch_semaphore_signal(semaphore);
                }];
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                [BleManager.shareInstance readWithCMDString:@"708" count:4 finish:^(NSArray * _Nonnull array) {
                    NSDictionary * item = @{
                        @"startTime":[NSString stringWithFormat:@"%@:%@",array[0],array[1]],
                        @"endTime":[NSString stringWithFormat:@"%@:%@",array[2],array[3]],
                    };
                    [self.touArray addObject:item];
                    dispatch_semaphore_signal(semaphore);
                }];
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                [BleManager.shareInstance readWithCMDString:@"70E" count:4 finish:^(NSArray * _Nonnull array) {
                    NSDictionary * item = @{
                        @"startTime":[NSString stringWithFormat:@"%@:%@",array[0],array[1]],
                        @"endTime":[NSString stringWithFormat:@"%@:%@",array[2],array[3]],
                    };
                    [self.touArray addObject:item];
                    dispatch_semaphore_signal(semaphore);
                }];
            }else{
                NSDictionary * item = @{@"startTime":@"",@"endTime":@"",@"price":@""};
                [self.touArray addObject:item];
                dispatch_semaphore_signal(semaphore);
            }
        }
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"reload");
            [self.tableView reloadData];
            [self.view hiddenHUD];
        });
    });
}

- (IBAction)helpAction:(id)sender{
    [GlobelDescAlertView showAlertViewWithTitle:@"Weather watch".localized desc:@"Monitor local weather condition, automatically stores energy for hazard backup."];
}

- (IBAction)submitAction:(id)sender{
    NSString * weather = self.weatherBtn.isSelected ? @"1" : @"0";
    PeakTimeTableViewCell * cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]];
    SwitchProgressTableViewCell * cell1 = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    SwitchProgressTableViewCell * cell2 = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
    [params setValue:self.deviceId forKey:@"devId"];
    [params setValue:weather forKey:@"weatherWatch"];
    [params setValue:self.flag == 0 ? @"1" : self.flag == 1 ? @"3" : @"2" forKey:@"workStatus"];
    NSMutableArray * offPeakArray = [[NSMutableArray alloc] init];
    if (self.flag == 0) {
        NSString * selfConsumptioinReserveSoc = [NSString stringWithFormat:@"%.0f",cell1.progress];
        [params setValue:selfConsumptioinReserveSoc forKey:@"selfConsumptioinReserveSoc"];
    }else if (self.flag == 1){
        NSString * backupPowerReserveSoc = [NSString stringWithFormat:@"%.0f",cell2.progress];
        [params setValue:backupPowerReserveSoc forKey:@"backupPowerReserveSoc"];
    }else if (self.flag == 2) {
        [params setValue:[NSString stringWithFormat:@"%@",cell.switchBtn.selected ? @"1" : @"0"] forKey:@"allowChargingXiaGrid"];
        for (int i=0; i<[cell.dataArray[0] count]; i++) {
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            TimeTableViewCell * timeCell = [cell.tableView cellForRowAtIndexPath:indexPath];
            NSLog(@"start=%@,end=%@",timeCell.startTime.text,timeCell.endTime.text);
            NSString * string = [NSString stringWithFormat:@"%@_%@_%@",timeCell.startTime.text,timeCell.endTime.text,timeCell.electricity.text];
            [offPeakArray addObject:string];
        }
        [params setValue:offPeakArray forKey:@"offPeakTimeList"];
        if ([RMHelper hasRepeatedTimeForArray:offPeakArray]) {
            [RMHelper showToast:@"Off-peak time overlap" toView:self.view];
            return;
        }
        NSMutableArray * peakTimeArray = [[NSMutableArray alloc] init];
        for (int i=0; i<[cell.dataArray[1] count]; i++) {
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:1];
            TimeTableViewCell * timeCell = [cell.tableView cellForRowAtIndexPath:indexPath];
            NSLog(@"start=%@,end=%@",timeCell.startTime.text,timeCell.endTime.text);
            NSString * string = [NSString stringWithFormat:@"%@_%@_%@",timeCell.startTime.text,timeCell.endTime.text,timeCell.electricity.text];
            [peakTimeArray addObject:string];
        }
        [params setValue:peakTimeArray forKey:@"peakTimeList"];
        if ([RMHelper hasRepeatedTimeForArray:peakTimeArray]) {
            [RMHelper showToast:@"Ppeak time overlap" toView:self.view];
            return;
        }
        NSMutableArray * superPeakTimeArray = [[NSMutableArray alloc] init];
        for (int i=0; i<[cell.dataArray[2] count]; i++) {
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:2];
            TimeTableViewCell * timeCell = [cell.tableView cellForRowAtIndexPath:indexPath];
            NSLog(@"start=%@,end=%@",timeCell.startTime.text,timeCell.endTime.text);
            NSString * string = [NSString stringWithFormat:@"%@_%@_%@",timeCell.startTime.text,timeCell.endTime.text,timeCell.electricity.text];
            [superPeakTimeArray addObject:string];
        }
        [params setValue:superPeakTimeArray forKey:@"superPeakTimeList"];
        if ([RMHelper hasRepeatedTimeForArray:superPeakTimeArray]) {
            [RMHelper showToast:@"Super peak time overlap" toView:self.view];
            return;
        }
    }
    if (RMHelper.getUserType && RMHelper.getLoadDataForBluetooth) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            [BleManager.shareInstance writeWithCMDString:@"621" array:@[weather] finish:^{
                dispatch_semaphore_signal(semaphore);
            }];
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            NSString * deviceMode = @"";
            if (self.flag == 0){
                deviceMode = @"1";
            }else if (self.flag == 1){
                deviceMode = @"3";
            }else if (self.flag == 2) {
                deviceMode = @"2";
            }
            [BleManager.shareInstance writeWithCMDString:@"601" array:@[deviceMode] finish:^{
                dispatch_semaphore_signal(semaphore);
            }];
            
            if (self.flag == 0) {
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                [BleManager.shareInstance writeWithCMDString:@"624" array:@[params[@"selfConsumptioinReserveSoc"]] finish:^{
                    dispatch_semaphore_signal(semaphore);
                    [self switchWithParams:params];
                    [RMHelper showToast:@"Configuration success" toView:self.view];
                }];
            }else if (self.flag == 1){
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                [BleManager.shareInstance writeWithCMDString:@"623" array:@[params[@"backupPowerReserveSoc"]] finish:^{
                    dispatch_semaphore_signal(semaphore);
                    [self switchWithParams:params];
                    [RMHelper showToast:@"Configuration success" toView:self.view];
                }];
            }else{
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                [BleManager.shareInstance writeWithCMDString:@"6FF" array:@[[NSString stringWithFormat:@"%ld",offPeakArray.count]] finish:^{
                    dispatch_semaphore_signal(semaphore);
                }];
                
                __block NSString * startTime0 = @"";
                __block NSString * endTime0 = @"";
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                    TimeTableViewCell * timeCell = [cell.tableView cellForRowAtIndexPath:indexPath];
                    startTime0 = timeCell.startTime.text;
                    endTime0 = timeCell.endTime.text;
                });
                if (startTime0.length > 0 && endTime0.length > 0) {
                    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                    [BleManager.shareInstance writeWithCMDString:@"702" array:@[[startTime0 componentsSeparatedByString:@":"].firstObject,[startTime0 componentsSeparatedByString:@":"].lastObject,[endTime0 componentsSeparatedByString:@":"].firstObject,[endTime0 componentsSeparatedByString:@":"].lastObject,] finish:^{
                        dispatch_semaphore_signal(semaphore);
                    }];
                }

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
            }
        });
    }else{
        [self switchWithParams:params];
    }
    
}

- (void)switchWithParams:(NSDictionary *)params{
    [Request.shareInstance postUrl:SwitchMode params:params progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        BOOL value = [result[@"data"] boolValue];
        if (value) {
            [RMHelper showToast:@"swithc mode success" toView:self.view];
        }else{
            [RMHelper showToast:result[@"message"] toView:self.view];
        }
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        SwitchModelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchModelTableViewCell class]) forIndexPath:indexPath];
        cell.icon.image = [UIImage imageNamed:self.flag == indexPath.section ? @"icon_choose" : @"icon_unchoose"];
        cell.titleLabel.text = self.titleArray[indexPath.section];
        cell.indexPath = indexPath;
        return cell;
    }else{
        if (indexPath.section == 2) {
            PeakTimeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([PeakTimeTableViewCell class]) forIndexPath:indexPath];
            cell.touArray = self.touArray;
            cell.switchBtn.selected = self.allowChargingXiaGrid;
            return cell;
        }else{
            SwitchProgressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchProgressTableViewCell class]) forIndexPath:indexPath];
            cell.progress = [self.progressArray[indexPath.section] floatValue];
            [cell.slider addTarget:self action:@selector(progressValueChange:) forControlEvents:UIControlEventValueChanged];
            return cell;
        }
    }
}

- (void)progressValueChange:(UISlider *)slider{
    SwitchProgressTableViewCell *cell = (SwitchProgressTableViewCell*)[[[slider superview] superview] superview];
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    [self.progressArray replaceObjectAtIndex:indexPath.section withObject:[NSString stringWithFormat:@"%.0f",slider.value]];
    cell.progress = slider.value;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.flag = indexPath.section;
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.titleArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 2){
        if(self.flag == section){
            return 2;
        }else{
            return 1;
        }
    }else{
        return 2;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 44;
    }else{
        if (indexPath.section == 2) {
            return [NSUserDefaults.standardUserDefaults objectForKey:TIME_TABLEVIEW_HEIGHT_CHANGE] ? [[NSUserDefaults.standardUserDefaults objectForKey:TIME_TABLEVIEW_HEIGHT_CHANGE] floatValue]+15 : 500;
        }else{
            if (self.flag == indexPath.section) {
                return 77;
            }else{
                return 0.1;
            }
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
