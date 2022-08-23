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
@property(nonatomic,strong)NSString * touCount;
@property(nonatomic,assign)BOOL allowChargingXiaGrid;
@property(nonatomic,strong)NSMutableArray * touArray;
@property(nonatomic,strong)NSMutableArray * peakTimeArray;
@property(nonatomic,strong)NSMutableArray * superPeakTimeArray;
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
        if (!BleManager.shareInstance.isConnented) {
            self.weatherBtn.selected = [data[@"weatherWatch"] boolValue];
            NSInteger workStatus = [data[@"workStatus"] intValue];
            if (workStatus == 1) {
                self.flag = 0;
            }else if (workStatus == 3){
                self.flag = 1;
            }else if (workStatus == 2){
                self.flag = 2;
            }
            if (data[@"selfConsumptioinReserveSoc"]) {
                NSString * selfConsumptioinReserveSoc = data[@"selfConsumptioinReserveSoc"];
                [self.progressArray replaceObjectAtIndex:0 withObject:selfConsumptioinReserveSoc];
            }
            if (data[@"backupPowerReserveSoc"]) {
                NSString * backupPowerReserveSoc = data[@"backupPowerReserveSoc"];
                [self.progressArray replaceObjectAtIndex:1 withObject:backupPowerReserveSoc];
            }
            self.allowChargingXiaGrid = [data[@"allowChargingXiaGrid"] boolValue];
            NSArray * offPeakTimeList = data[@"offPeakTimeList"];
            for (int i=0; i<offPeakTimeList.count; i++) {
                NSString * string = offPeakTimeList[i];
                if ([string containsString:@"_"]) {
                    NSArray * timeArray = [string componentsSeparatedByString:@"_"];
                    NSString * startTime = timeArray[0];
                    NSString * endTime = timeArray[1];
                    NSDictionary * dict = @{@"startTime":startTime,@"endTime":endTime,@"price":timeArray.count>=2?timeArray[2]:@"0"};
                    [self.touArray addObject:dict];
                }else{
                    [self.touArray addObject:@{@"startTime":@"",@"endTime":@"",@"price":@""}];
                }
            }
        }else{
            if (data[@"offPeakTimeList"]) {
                NSArray * offPeakTimeList = data[@"offPeakTimeList"];
                NSMutableArray * priceArray = [[NSMutableArray alloc] init];
                for (int i=0; i<offPeakTimeList.count; i++) {
                    NSString * string = offPeakTimeList[i];
                    if ([string containsString:@"_"]) {
                        NSArray * timeArray = [string componentsSeparatedByString:@"_"];
                        [priceArray addObject:timeArray.count>2?timeArray[2]:@""];
                    }else{
                        [priceArray addObject:@""];
                    }
                }
                if (priceArray.count < self.touArray.count) {
                    for (int i=0; i<self.touArray.count-priceArray.count; i++) {
                        [priceArray addObject:@""];
                    }
                }
                NSMutableArray * array = [[NSMutableArray alloc] init];
                for (int i=0; i<self.touArray.count; i++) {
                    NSMutableDictionary * item = [[NSMutableDictionary alloc] initWithDictionary:self.touArray[i]];
                    [item setValue:priceArray[i] forKey:@"price"];
                    [array addObject:item];
                }
                self.touArray = [[NSMutableArray alloc] initWithArray:array];
            }
        }
        if (data[@"peakTimeList"]) {
            NSArray * peakTimeArray = data[@"peakTimeList"];
            for (int i=0; i<peakTimeArray.count; i++) {
                NSString * string = peakTimeArray[i];
                if ([string containsString:@"_"]) {
                    NSArray * timeArray = [string componentsSeparatedByString:@"_"];
                    NSString * startTime = timeArray[0];
                    NSString * endTime = timeArray[1];
                    NSDictionary * dict = @{@"startTime":startTime,@"endTime":endTime,@"price":timeArray.count>=2?timeArray[2]:@"0"};
                    [self.peakTimeArray addObject:dict];
                }else{
                    [self.peakTimeArray addObject:@{@"startTime":@"",@"endTime":@"",@"price":@""}];
                }
            }
        }
        if (data[@"superPeakTimeList"]) {
            NSArray * superPeakTimeArray = data[@"superPeakTimeList"];
            for (int i=0; i<superPeakTimeArray.count; i++) {
                NSString * string = superPeakTimeArray[i];
                if ([string containsString:@"_"]) {
                    NSArray * timeArray = [string componentsSeparatedByString:@"_"];
                    NSString * startTime = timeArray[0];
                    NSString * endTime = timeArray[1];
                    NSDictionary * dict = @{@"startTime":startTime,@"endTime":endTime,@"price":timeArray.count>=2?timeArray[2]:@"0"};
                    [self.superPeakTimeArray addObject:dict];
                }else{
                    [self.superPeakTimeArray addObject:@{@"startTime":@"",@"endTime":@"",@"price":@""}];
                }
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
    self.peakTimeArray = [[NSMutableArray alloc] init];
    self.superPeakTimeArray = [[NSMutableArray alloc] init];

    if (BleManager.shareInstance.isConnented) {
        [self loadBluetoothData];
    }else{
        [self getSwitchModeData];
    }
}

- (void)loadBluetoothData{
    if (BleManager.shareInstance.isConnented) {
        [UIApplication.sharedApplication.keyWindow showHUDToast:@"Loading"];
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [BleManager.shareInstance readWithCMDString:@"621" count:1 finish:^(NSArray * _Nonnull array) {
            weakSelf.weatherBtn.selected = [array.firstObject boolValue];
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"511" count:1 finish:^(NSArray * _Nonnull array) {
            int value = [array.firstObject intValue];
            NSLog(@"flag=%d",value);
            if (value == 3) {
                weakSelf.flag = 1;
            }else if (value == 2){
                weakSelf.flag = 2;
            }else if (value == 1){
                weakSelf.flag = 0;
            }else{
                weakSelf.flag = 0;
            }
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"624" count:1 finish:^(NSArray * _Nonnull array) {
            [weakSelf.progressArray replaceObjectAtIndex:0 withObject:array.firstObject];
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"623" count:1 finish:^(NSArray * _Nonnull array) {
            [self.progressArray replaceObjectAtIndex:1 withObject:array.firstObject];
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"6FE" count:2 finish:^(NSArray * _Nonnull array) {
            weakSelf.allowChargingXiaGrid = [array.firstObject boolValue];
            weakSelf.touCount = array.lastObject;
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        if (weakSelf.touCount.intValue == 0) {
            NSDictionary * item = @{@"startTime":@"",@"endTime":@"",@"price":@""};
            [weakSelf.touArray addObject:item];
            dispatch_semaphore_signal(semaphore);
        }else if (weakSelf.touCount.intValue == 1) {
            [BleManager.shareInstance readWithCMDString:@"702" count:4 finish:^(NSArray * _Nonnull array) {
                if (array.count == 4) {
                    NSDictionary * item = @{
                        @"startTime":[NSString stringWithFormat:@"%02d:%02d",[array[0] intValue],[array[1] intValue]],
                        @"endTime":[NSString stringWithFormat:@"%02d:%02d",[array[2] intValue],[array[3] intValue]],
                    };
                    [weakSelf.touArray addObject:item];
                }else{
                    NSDictionary * item = @{@"startTime":@"",@"endTime":@"",@"price":@""};
                    [weakSelf.touArray addObject:item];
                }
                dispatch_semaphore_signal(semaphore);
            }];
        }else if (weakSelf.touCount.intValue == 2) {
            [BleManager.shareInstance readWithCMDString:@"702" count:4 finish:^(NSArray * _Nonnull array) {
                if (array.count == 4) {
                    NSDictionary * item = @{
                        @"startTime":[NSString stringWithFormat:@"%02d:%02d",[array[0] intValue],[array[1] intValue]],
                        @"endTime":[NSString stringWithFormat:@"%02d:%02d",[array[2] intValue],[array[3] intValue]],
                    };
                    [weakSelf.touArray addObject:item];
                }else{
                    NSDictionary * item = @{@"startTime":@"",@"endTime":@"",@"price":@""};
                    [weakSelf.touArray addObject:item];
                }
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            [BleManager.shareInstance readWithCMDString:@"708" count:4 finish:^(NSArray * _Nonnull array) {
                if (array.count == 4) {
                    NSDictionary * item = @{
                        @"startTime":[NSString stringWithFormat:@"%02d:%02d",[array[0] intValue],[array[1] intValue]],
                        @"endTime":[NSString stringWithFormat:@"%02d:%02d",[array[2] intValue],[array[3] intValue]],
                    };
                    [weakSelf.touArray addObject:item];
                }else{
                    NSDictionary * item = @{@"startTime":@"",@"endTime":@"",@"price":@""};
                    [weakSelf.touArray addObject:item];
                }
                dispatch_semaphore_signal(semaphore);
            }];
        }else if (weakSelf.touCount.intValue == 3) {
            [BleManager.shareInstance readWithCMDString:@"702" count:4 finish:^(NSArray * _Nonnull array) {
                if (array.count == 4) {
                    NSDictionary * item = @{
                        @"startTime":[NSString stringWithFormat:@"%02d:%02d",[array[0] intValue],[array[1] intValue]],
                        @"endTime":[NSString stringWithFormat:@"%02d:%02d",[array[2] intValue],[array[3] intValue]],
                    };
                    [weakSelf.touArray addObject:item];
                }else{
                    NSDictionary * item = @{@"startTime":@"",@"endTime":@"",@"price":@""};
                    [weakSelf.touArray addObject:item];
                }
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            [BleManager.shareInstance readWithCMDString:@"708" count:4 finish:^(NSArray * _Nonnull array) {
                if (array.count == 4) {
                    NSDictionary * item = @{
                        @"startTime":[NSString stringWithFormat:@"%02d:%02d",[array[0] intValue],[array[1] intValue]],
                        @"endTime":[NSString stringWithFormat:@"%02d:%02d",[array[2] intValue],[array[3] intValue]],
                    };
                    [weakSelf.touArray addObject:item];
                }else{
                    NSDictionary * item = @{@"startTime":@"",@"endTime":@"",@"price":@""};
                    [weakSelf.touArray addObject:item];
                }
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            [BleManager.shareInstance readWithCMDString:@"70E" count:4 finish:^(NSArray * _Nonnull array) {
                if (array.count == 4) {
                    NSDictionary * item = @{
                        @"startTime":[NSString stringWithFormat:@"%02d:%02d",[array[0] intValue],[array[1] intValue]],
                        @"endTime":[NSString stringWithFormat:@"%02d:%02d",[array[2] intValue],[array[3] intValue]],
                    };
                    [weakSelf.touArray addObject:item];
                }else{
                    NSDictionary * item = @{@"startTime":@"",@"endTime":@"",@"price":@""};
                    [weakSelf.touArray addObject:item];
                }
                dispatch_semaphore_signal(semaphore);
            }];
        }else{
            NSDictionary * item = @{@"startTime":@"",@"endTime":@"",@"price":@""};
            [weakSelf.touArray addObject:item];
            dispatch_semaphore_signal(semaphore);
        }
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication.sharedApplication.keyWindow hiddenHUD];
            [weakSelf getSwitchModeData];
            dispatch_semaphore_signal(semaphore);
        });
    });
}

- (IBAction)helpAction:(id)sender{
    [GlobelDescAlertView showAlertViewWithTitle:@"Weather watch".localized desc:@"This will enable the EP CUBE to monitor local weather and charge the batteries for backup in case of extreme future weather event." btnTitle:nil completion:nil];
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

    NSString * selfConsumptioinReserveSoc = [NSString stringWithFormat:@"%.0f",cell1.progress];
    [params setValue:selfConsumptioinReserveSoc forKey:@"selfConsumptioinReserveSoc"];

    NSString * backupPowerReserveSoc = [NSString stringWithFormat:@"%.0f",cell2.progress];
    [params setValue:backupPowerReserveSoc forKey:@"backupPowerReserveSoc"];

    self.allowChargingXiaGrid = cell.switchBtn.selected;
    [params setValue:[NSString stringWithFormat:@"%@",self.allowChargingXiaGrid ? @"1" : @"0"] forKey:@"allowChargingXiaGrid"];
    if (self.flag != 2) {
        [params setValue:@[@"__"] forKey:@"offPeakTimeList"];
        [params setValue:@[@"__"] forKey:@"peakTimeList"];
        [params setValue:@[@"__"] forKey:@"superPeakTimeList"];
    }else{
        for (int i=0; i<[cell.dataArray[0] count]; i++) {
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            TimeTableViewCell * timeCell = [cell.tableView cellForRowAtIndexPath:indexPath];
            NSLog(@"start=%@,end=%@",timeCell.startTime.text,timeCell.endTime.text);
            if (timeCell.startTime.text.length == 0 && timeCell.endTime.text.length > 0) {
                [RMHelper showToast:@"Please select off-peak start time" toView:self.view];
                return;
            }
            if (timeCell.endTime.text.length == 0 && timeCell.startTime.text.length > 0) {
                [RMHelper showToast:@"Please select off-peak end time" toView:self.view];
                return;
            }
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
            if (timeCell.startTime.text.length == 0 && timeCell.endTime.text.length > 0) {
                [RMHelper showToast:@"Please select peak start time" toView:self.view];
                return;
            }
            if (timeCell.endTime.text.length == 0 && timeCell.startTime.text.length > 0) {
                [RMHelper showToast:@"Please select peak end time" toView:self.view];
                return;
            }
            NSString * string = [NSString stringWithFormat:@"%@_%@_%@",timeCell.startTime.text,timeCell.endTime.text,timeCell.electricity.text];
            [peakTimeArray addObject:string];
        }
        [params setValue:peakTimeArray forKey:@"peakTimeList"];
        if ([RMHelper hasRepeatedTimeForArray:peakTimeArray]) {
            [RMHelper showToast:@"Peak time overlap" toView:self.view];
            return;
        }
        NSMutableArray * superPeakTimeArray = [[NSMutableArray alloc] init];
        for (int i=0; i<[cell.dataArray[2] count]; i++) {
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:2];
            TimeTableViewCell * timeCell = [cell.tableView cellForRowAtIndexPath:indexPath];
            NSLog(@"start=%@,end=%@",timeCell.startTime.text,timeCell.endTime.text);
            if (timeCell.startTime.text.length == 0 && timeCell.endTime.text.length > 0) {
                [RMHelper showToast:@"Please select super peak start time" toView:self.view];
                return;
            }
            if (timeCell.endTime.text.length == 0 && timeCell.startTime.text.length > 0) {
                [RMHelper showToast:@"Please select super peak end time" toView:self.view];
                return;
            }
            NSString * string = [NSString stringWithFormat:@"%@_%@_%@",timeCell.startTime.text,timeCell.endTime.text,timeCell.electricity.text];
            [superPeakTimeArray addObject:string];
        }
        [params setValue:superPeakTimeArray forKey:@"superPeakTimeList"];
        if ([RMHelper hasRepeatedTimeForArray:superPeakTimeArray]) {
            [RMHelper showToast:@"Super peak time overlap" toView:self.view];
            return;
        }
        NSMutableArray * selectedTime = [[NSMutableArray alloc] init];
        NSArray * offPeakTimeList = params[@"offPeakTimeList"];
        NSArray * peakTimeList = params[@"peakTimeList"];
        NSArray * superPeakTimeList = params[@"superPeakTimeList"];
        [selectedTime addObjectsFromArray:offPeakTimeList];
        [peakTimeList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![obj isEqualToString:@"__"]) {
                [selectedTime addObject:obj];
            }
        }];
        [superPeakTimeList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![obj isEqualToString:@"__"]) {
                [selectedTime addObject:obj];
            }
        }];
        if ([RMHelper hasRepeatedTimeForArray:selectedTime]) {
            [RMHelper showToast:@"Selected time overlap" toView:self.view];
            return;
        }
    }
    NSLog(@"params=%@",params);
    if (RMHelper.getUserType || (!RMHelper.getUserType && BleManager.shareInstance.isConnented)) {
        if (!BleManager.shareInstance.isConnented) {
            [GlobelDescAlertView showAlertViewWithTitle:@"Tips" desc:@"Please connect the bluetooth device first" btnTitle:nil completion:nil];
            return;
        }
        [params setValue:@"1" forKey:@"onlySave"];
        if (self.flag == 2) {
            if ([offPeakArray[0] componentsSeparatedByString:@"_"][0].length == 0) {
                [RMHelper showToast:@"please select start time" toView:self.view];
                return;
            }
            if ([offPeakArray[0] componentsSeparatedByString:@"_"][1].length == 0) {
                [RMHelper showToast:@"please select end time" toView:self.view];
                return;
            }
            if (offPeakArray.count > 1) {
                if ([offPeakArray[1] componentsSeparatedByString:@"_"][0].length == 0) {
                    [RMHelper showToast:@"please select start time" toView:self.view];
                    return;
                }
                if ([offPeakArray[1] componentsSeparatedByString:@"_"][1].length == 0) {
                    [RMHelper showToast:@"please select end time" toView:self.view];
                    return;
                }
            }
            if (offPeakArray.count > 2) {
                if ([offPeakArray[2] componentsSeparatedByString:@"_"][0].length == 0) {
                    [RMHelper showToast:@"please select start time" toView:self.view];
                    return;
                }
                if ([offPeakArray[2] componentsSeparatedByString:@"_"][1].length == 0) {
                    [RMHelper showToast:@"please select end time" toView:self.view];
                    return;
                }
            }
        }
        __weak typeof(self) weakSelf = self;
        if (BleManager.shareInstance.isConnented) {
            [UIApplication.sharedApplication.keyWindow showHUDToast:@"Loading"];
        }
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
                    [UIApplication.sharedApplication.keyWindow hiddenHUD];
                    [weakSelf switchWithParams:params];
                }];
            }else if (self.flag == 1){
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                [BleManager.shareInstance writeWithCMDString:@"623" array:@[params[@"backupPowerReserveSoc"]] finish:^{
                    dispatch_semaphore_signal(semaphore);
                    [UIApplication.sharedApplication.keyWindow hiddenHUD];
                    [weakSelf switchWithParams:params];
                }];
            }else{
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                [BleManager.shareInstance writeWithCMDString:@"6FE" array:@[self.allowChargingXiaGrid?@"1":@"0",[NSString stringWithFormat:@"%ld",offPeakArray.count]] finish:^{
                    dispatch_semaphore_signal(semaphore);
                }];
                
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                NSString * startTime0 = [offPeakArray[0] componentsSeparatedByString:@"_"][0];
                NSString * endTime0 = [offPeakArray[0] componentsSeparatedByString:@"_"][1];;
                [BleManager.shareInstance writeWithCMDString:@"702" array:@[[startTime0 componentsSeparatedByString:@":"].firstObject,[startTime0 componentsSeparatedByString:@":"].lastObject,[endTime0 componentsSeparatedByString:@":"].firstObject,[endTime0 componentsSeparatedByString:@":"].lastObject,] finish:^{
                    dispatch_semaphore_signal(semaphore);
                }];
                
                if (offPeakArray.count > 1) {
                    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                    NSString * startTime1 = [offPeakArray[1] componentsSeparatedByString:@"_"][0];
                    NSString * endTime1 = [offPeakArray[1] componentsSeparatedByString:@"_"][1];;
                    [BleManager.shareInstance writeWithCMDString:@"708" array:@[[startTime1 componentsSeparatedByString:@":"].firstObject,[startTime1 componentsSeparatedByString:@":"].lastObject,[endTime1 componentsSeparatedByString:@":"].firstObject,[endTime1 componentsSeparatedByString:@":"].lastObject,] finish:^{
                        dispatch_semaphore_signal(semaphore);
                    }];
                }
                
                if (offPeakArray.count > 2) {
                    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                    NSString * startTime2 = [offPeakArray[2] componentsSeparatedByString:@"_"][0];
                    NSString * endTime2 = [offPeakArray[2] componentsSeparatedByString:@"_"][1];;
                    [BleManager.shareInstance writeWithCMDString:@"70E" array:@[[startTime2 componentsSeparatedByString:@":"].firstObject,[startTime2 componentsSeparatedByString:@":"].lastObject,[endTime2 componentsSeparatedByString:@":"].firstObject,[endTime2 componentsSeparatedByString:@":"].lastObject,] finish:^{
                        dispatch_semaphore_signal(semaphore);
                    }];
                }

                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                [BleManager.shareInstance writeWithCMDString:@"750" array:@[@"1"] finish:^{
                    dispatch_semaphore_signal(semaphore);
                }];
                
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                [BleManager.shareInstance readWithCMDString:@"752" count:1 finish:^(NSArray * _Nonnull array) {
                    [UIApplication.sharedApplication.keyWindow hiddenHUD];
                    NSInteger idx = [array.firstObject intValue];
                    if (idx == 1) {
                        [RMHelper showToast:@"Failure" toView:self.view];
                    }
                    if (idx == 2) {
                        [self switchWithParams:params];
                    }
                    if (idx == 3) {
                        [self switchWithParams:params];
                    }
                }];
            }
        });
    }else{
        [params setValue:@"0" forKey:@"onlySave"];
        [self switchWithParams:params];
    }
    
}

- (void)switchWithParams:(NSDictionary *)params{
    [Request.shareInstance postUrl:SwitchMode params:params progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        [RMHelper showToast:result[@"message"] toView:self.view];
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        SwitchModelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchModelTableViewCell class]) forIndexPath:indexPath];
        cell.icon.image = [UIImage imageNamed:self.flag == indexPath.section ? @"icon_choose" : @"icon_unchoose"];
        cell.titleLabel.text = self.titleArray[indexPath.section];
        cell.indexPath = indexPath;
        cell.clearBtn.hidden = indexPath.section != self.titleArray.count-1;
        [cell.clearBtn addTarget:self action:@selector(clearBtnClick) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }else{
        if (indexPath.section == 2) {
            PeakTimeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([PeakTimeTableViewCell class]) forIndexPath:indexPath];
            cell.touArray = self.touArray;
            cell.peakTimeArray = self.peakTimeArray;
            cell.superPeakTimeArray = self.superPeakTimeArray;
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

- (void)clearBtnClick{
    if (RMHelper.getUserType || (!RMHelper.getUserType && BleManager.shareInstance.isConnented)) {
        if (!BleManager.shareInstance.isConnented) {
            [GlobelDescAlertView showAlertViewWithTitle:@"Tips" desc:@"Please connect the bluetooth device first" btnTitle:nil completion:nil];
            return;
        }
        __weak typeof(self) weakSelf = self;
        [GlobelDescAlertView showAlertViewWithTitle:@"Clear" desc:@"Are you sure you want to clear the configuration" btnTitle:nil completion:^{
            [BleManager.shareInstance writeWithCMDString:@"751" string:@"1" finish:^{
                [weakSelf clearDataAction];
            }];
        }];
    }else{
        [GlobelDescAlertView showAlertViewWithTitle:@"Clear" desc:@"Are you sure you want to clear the configuration" btnTitle:nil completion:^{
            [self clearDataAction];
        }];
    }
}

- (void)clearDataAction{
    [Request.shareInstance getUrl:ClearTouMode params:@{@"devId":self.deviceId} progress:^(float progress) {
                        
    } success:^(NSDictionary * _Nonnull result) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CLEAR_NOTIFICATION object:nil];
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
}

- (void)progressValueChange:(UISlider *)slider{
    SwitchProgressTableViewCell *cell = (SwitchProgressTableViewCell*)[[[slider superview] superview] superview];
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    [self.progressArray replaceObjectAtIndex:indexPath.section withObject:[NSString stringWithFormat:@"%.0f",slider.value]];
    cell.progress = slider.value;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        self.flag = indexPath.section;
        [self.tableView reloadData];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.titleArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 2) {
        if (self.flag == section) {
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
            if (self.flag != indexPath.section) {
                return 0.001;
            }else{
                return [NSUserDefaults.standardUserDefaults objectForKey:TIME_TABLEVIEW_HEIGHT_CHANGE] ? [[NSUserDefaults.standardUserDefaults objectForKey:TIME_TABLEVIEW_HEIGHT_CHANGE] floatValue]+15 : 500;
            }
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
