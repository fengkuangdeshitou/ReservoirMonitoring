//
//  HomeViewController.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/11.
//

#import "HomeViewController.h"
#import "HomeTableViewCell.h"
#import "DeviceSwitchView.h"
#import "SwitchModeViewController.h"
#import "DevideModel.h"
@import BRPickerView;
#import "AddDeviceViewController.h"
#import "GlobelDescAlertView.h"

@interface HomeViewController ()<DeviceSwitchViewDelegate,BleManagerDelegate,UITableViewDelegate,DeviceSwitchViewDelegate>

@property(nonatomic,weak)IBOutlet UIButton * addEquipmentBtn;
@property(nonatomic,weak)IBOutlet UITableView * tableView;
@property(nonatomic,strong)DevideModel * model;
@property(nonatomic,strong)BleManager * manager;
@property(nonatomic)NSInteger index;
@property(nonatomic,strong)NSTimer * refreshTimer;
@property(nonatomic,assign)NSInteger time;
@property(nonatomic,strong)NSArray<DevideModel*> * deviceArray;
@property(nonatomic,assign)BOOL isShowAlert;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.isShowAlert = true;
    self.tableView.refreshControl = self.refreshController;
    [self.refreshController addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    [[NSNotificationCenter defaultCenter] addObserverForName:SWITCH_DEVICE_NOTIFICATION object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        self.isShowAlert = false;
        [self getHomeDeviceData];
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addDeviceSuccess) name:ADD_DEVICE_NOTIFICATION object:nil];

    self.manager = BleManager.shareInstance;
    [self.addEquipmentBtn showBorderWithRadius:25];
    [self setLeftBarImageForSel:nil];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([HomeTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([HomeTableViewCell class])];
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeChangeAction) userInfo:nil repeats:true];
}

- (void)addDeviceSuccess{
    [self.navigationController popToViewController:self animated:true];
}

- (void)bluetoothDidDisconnectPeripheral:(CBPeripheral *)peripheral{
    [self.refreshController endRefreshing];
    self.model.gridPower = 0;
    self.model.solarPower = 0;
    self.model.generatorPower = 0;
    self.model.evPower = 0;
    self.model.nonBackUpPower = 0;
    self.model.backUpPower = 0;
    
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.manager.delegate = self;
    self.isShowAlert = true;
    [self getHomeDeviceData];
    [self.tableView reloadData];
    [self.refreshTimer setFireDate:[NSDate date]];
    self.time = 60;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    Request.shareInstance.hiddenHUD = false;
    [self.refreshTimer setFireDate:[NSDate distantFuture]];
}

- (void)timeChangeAction{
    self.time--;
    if (self.time <= 0) {
        self.time = 60;
        self.isShowAlert = true;
        Request.shareInstance.hiddenHUD = true;
        [self getHomeDeviceData];
    }
}

- (void)onRefresh{
    self.isShowAlert = true;
    Request.shareInstance.hiddenHUD = false;
    [self.refreshController endRefreshing];
    [self.refreshTimer setFireDate:[NSDate date]];
    [self getHomeDeviceData];
}

- (void)getHomeDeviceData{
    if (RMHelper.getUserType) {
        if (RMHelper.getLoadDataForBluetooth) {
            [self getCurrentDevice:^(DevideModel *model) {
                if (model) {
                    [self getBluetoothData];
                }
            }];
        }else{
            [self getNetworkData];
        }
    }else{
        [self getNetworkData];
    }
}

- (void)getCurrentDevice:(void(^)(DevideModel * model))completion{
    [Request.shareInstance getUrl:DeviceList params:@{} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        self.deviceArray = [DevideModel mj_objectArrayWithKeyValuesArray:result[@"data"]];
        DeviceManager.shareInstance.deviceNumber = self.deviceArray.count;
        if (self.deviceArray.count > 0){
            NSArray<DevideModel*> * array = [self.deviceArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"lastConnect = %@",@"1"]];
            if (array.count > 0) {
                self.model = array.firstObject;
                [self setRightBarButtonItemWithTitlt:array.firstObject.name sel:@selector(changeDevice)];
                [NSUserDefaults.standardUserDefaults setValue:self.model.deviceId forKey:CURRENR_DEVID];
                if (BleManager.shareInstance.isConnented) {
                    if (![BleManager.shareInstance.rtusn isEqualToString:self.model.rtuSn]) {
                        [BleManager.shareInstance disconnectPeripheral];
                    }
                }
                completion(self.model);
            }else{
                self.navigationItem.rightBarButtonItem = nil;
                completion(nil);
            }
            self.tableView.hidden = false;
        }else{
            self.tableView.hidden = true;
        }
        [self.refreshController endRefreshing];
    } failure:^(NSString * _Nonnull errorMsg) {
        [self.refreshController endRefreshing];
    }];
}

- (void)getNetworkData{
    [self getCurrentDevice:^(DevideModel *model) {
        if (model) {
            [self getHomeData:model.sgSn];
        }
    }];
}

- (void)getHomeData:(NSString *)sgSn{
    NSDate * date = [NSDate date];
    [Request.shareInstance getUrl:HomeDeviceInfo params:@{@"sgSn":sgSn,@"dayMonthYearFormat":[NSString stringWithFormat:@"%ld-%02ld-%02ld",date.br_year,date.br_month,date.br_day]} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        NSString * isOnline = self.model.isOnline;
        self.model = [DevideModel mj_objectWithKeyValues:result[@"data"]];
        self.model.isOnline = isOnline;
        [self.refreshController endRefreshing];
        [self getWeatherData:sgSn];
        [self.tableView reloadData];
    } failure:^(NSString * _Nonnull errorMsg) {
        [self.refreshController endRefreshing];
        [self getWeatherData:sgSn];
    }];
}

- (void)getWeatherData:(NSString *)sgSn{
    [Request.shareInstance getUrl:DeviceInfoWeather params:@{@"sgSn":sgSn} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        self.model.weather = result[@"data"];
        [self.tableView reloadData];
        Request.shareInstance.hiddenHUD = false;
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
}

- (IBAction)addDeviceAction:(id)sender{
    AddDeviceViewController * add = [[AddDeviceViewController alloc] init];
    add.title = @"Add Device".localized;
    add.hidesBottomBarWhenPushed = true;
    [self.navigationController pushViewController:add animated:true];
}

- (void)getBluetoothData{
    if (!BleManager.shareInstance.isConnented && self.isShowAlert && RMHelper.getLoadDataForBluetooth) {
        [GlobelDescAlertView showAlertViewWithTitle:@"Tips" desc:@"Please connect the bluetooth device first" btnTitle:nil completion:nil];
        return;
    }
    if (BleManager.shareInstance.isConnented) {
        [UIApplication.sharedApplication.keyWindow showHUDToast:@"Loading"];
    }else{
        [self.refreshController endRefreshing];
    }
    self.manager.delegate = self;
    if (!BleManager.shareInstance.isConnented) {
        NSString * deviceId = self.model.deviceId;
        NSString * sgSn = self.model.sgSn;
        self.model = [[DevideModel alloc] init];
        self.model.deviceId = deviceId;
        self.model.sgSn = sgSn;
        if (self.model.sgSn) {
            [self getWeatherData:self.model.sgSn];
        }
        [self.tableView reloadData];
        return;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [BleManager.shareInstance readWithCMDString:@"510" count:2 finish:^(NSArray * array){
            self.model.systemStatus = array.firstObject;
            self.model.workStatus = array.lastObject;
            dispatch_semaphore_signal(semaphore);
        }];

        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"625" count:1 finish:^(NSArray * array){
            NSLog(@"====%@",array);
            self.model.backUpType = [NSString stringWithFormat:@"%@",array.firstObject];
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"514" count:1 finish:^(NSArray * array){
            self.model.gridLight = [array.firstObject integerValue];
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"630" count:1 finish:^(NSArray * array){
            self.model.generatorLight = [array.firstObject integerValue];
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"62D" count:1 finish:^(NSArray * array){
            self.model.evLight = [array.firstObject integerValue];
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"625" count:1 finish:^(NSArray * array){
            self.model.backUpType = array.firstObject;
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"515" count:2 finish:^(NSArray * array){
            self.model.batterySoc = array.firstObject;
            self.model.batteryCurrentElectricity = [NSString stringWithFormat:@"%.0f kWh",[self cumulativeWithArray:@[array.lastObject]]/100];
            dispatch_semaphore_signal(semaphore);
        }];

        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"51F" count:1 finish:^(NSArray * array){
            self.model.gridPower = [array.firstObject floatValue];
            dispatch_semaphore_signal(semaphore);
        }];

//        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//        [BleManager.shareInstance readWithCMDString:@"527" count:2 finish:^(NSArray * array){
//            [self showCmd:@"527" message:array];
//            self.model.gridElectricity = ([array.firstObject floatValue]+[array.lastObject floatValue]*65536)/100;
//            dispatch_semaphore_signal(semaphore);
//        }];

//        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//        [BleManager.shareInstance readWithCMDString:@"529" count:4 finish:^(NSArray * array){
//            [self showCmd:@"529" message:array];
//            CGFloat left = ([array[0] floatValue]+[array[1] floatValue]*65536)/100;
//            CGFloat right = ([array[2] floatValue]+[array[3] floatValue]*65536)/100;
//            self.model.solarElectricity = left+right;
//            dispatch_semaphore_signal(semaphore);
//        }];
        
//        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//        [BleManager.shareInstance readWithCMDString:@"52D" count:2 finish:^(NSArray * array){
//            [self showCmd:@"52D" message:array];
//            self.model.generatorElectricity = ([array.firstObject floatValue]+[array.lastObject floatValue]*65536)/100;
//            dispatch_semaphore_signal(semaphore);
//        }];
        
//        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//        [BleManager.shareInstance readWithCMDString:@"52F" count:2 finish:^(NSArray * array){
//            [self showCmd:@"52F" message:array];
//            self.model.evElectricity = ([array.firstObject floatValue]+[array.lastObject floatValue]*65536)/100;
//            dispatch_semaphore_signal(semaphore);
//        }];
        
//        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//        [BleManager.shareInstance readWithCMDString:@"533" count:2 finish:^(NSArray * array){
//            [self showCmd:@"533" message:array];
//            self.model.nonBackUpElectricity = ([array.firstObject floatValue]+[array.lastObject floatValue]*65536)/100;
//            dispatch_semaphore_signal(semaphore);
//        }];
        
//        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//        [BleManager.shareInstance readWithCMDString:@"531" count:2 finish:^(NSArray * array){
//            [self showCmd:@"531" message:array];
//            self.model.backUpElectricity = ([array.firstObject floatValue]+[array.lastObject floatValue]*65536)/100;
//            dispatch_semaphore_signal(semaphore);
//        }];

        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"521" count:1 finish:^(NSArray * array){
            self.model.generatorPower = [array.firstObject floatValue];
            dispatch_semaphore_signal(semaphore);
        }];

        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"524" count:1 finish:^(NSArray * array){
            self.model.evPower = [array.firstObject floatValue];
            dispatch_semaphore_signal(semaphore);
        }];

        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"541" count:3 finish:^(NSArray * array){
            self.model.nonBackUpPower = [array[0] floatValue];
            self.model.backUpPower = [array[1] floatValue];
            self.model.solarPower = [array[2] floatValue];
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"544" count:8 finish:^(NSArray * array){
            if ([self formatPower:self.model.gridPower]) {
                self.model.gridElectricity = [array[0] floatValue]/100;
            }else{
                self.model.gridElectricity = [array[1] floatValue]/100;
            }
            self.model.solarElectricity = [array[2] floatValue]/100 + [array[3] floatValue]/100;
            self.model.generatorElectricity = [array[4] floatValue]/100;
            self.model.evElectricity = [array[5] floatValue]/100;
            self.model.nonBackUpElectricity = [array[7] floatValue]/100;
            self.model.backUpElectricity = [array[6] floatValue]/100;
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_semaphore_signal(semaphore);
            [self.tableView reloadData];
            [self.refreshController endRefreshing];
            [UIApplication.sharedApplication.keyWindow hiddenHUD];
            if (self.model.sgSn) {
                [self getWeatherData:self.model.sgSn];
            }
        });
    
    });
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

- (CGFloat)cumulativeWithArray:(NSArray *)array{
    __block CGFloat value = 0;
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        value +=  [obj floatValue];
    }];
    return value;
}

- (void)changeDevice{
    if (RMHelper.isTouristsModel){
        [RMHelper showToast:@"Visitor has no permission" toView:RMHelper.getCurrentVC.view];
        return;
    }
    [DeviceSwitchView showDeviceSwitchViewWithDelegate:self dataArray:self.deviceArray];
}

- (void)onSwitchDeviceSuccess{
    [self getHomeDeviceData];
}

- (void)changeCurrentDeviceStatusAction{
    if (RMHelper.isTouristsModel){
        [RMHelper showToast:@"Visitor has no permission" toView:RMHelper.getCurrentVC.view];
        return;
    }
    SwitchModeViewController * model = [[SwitchModeViewController alloc] init];
    model.title = @"Switch operation mode".localized;
    model.deviceId = self.model.deviceId;
    model.hidesBottomBarWhenPushed = true;
    [self.navigationController pushViewController:model animated:true];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HomeTableViewCell class]) forIndexPath:indexPath];
    cell.model = self.model;
    [cell.changeDeviceButton addTarget:self action:@selector(changeCurrentDeviceStatusAction) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.001;
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
