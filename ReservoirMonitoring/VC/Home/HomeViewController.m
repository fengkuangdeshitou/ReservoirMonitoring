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

@interface HomeViewController ()<DeviceSwitchViewDelegate,BleManagerDelegate,UITableViewDelegate,DeviceSwitchViewDelegate>

@property(nonatomic,weak)IBOutlet UIButton * addEquipmentBtn;
@property(nonatomic,weak)IBOutlet UITableView * tableView;
@property(nonatomic,strong)DevideModel * model;
@property(nonatomic,strong)BleManager * manager;
@property(nonatomic)NSInteger index;
@property(nonatomic,strong)NSTimer * refreshTimer;
@property(nonatomic,assign)NSInteger time;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.refreshControl = self.refreshController;
    [self.refreshController addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    [[NSNotificationCenter defaultCenter] addObserverForName:SWITCH_DEVICE_NOTIFICATION object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self getHomeDeviceData];
    }];
    self.manager = BleManager.shareInstance;
    [self.addEquipmentBtn showBorderWithRadius:25];
    [self setLeftBarImageForSel:nil];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([HomeTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([HomeTableViewCell class])];
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeChangeAction) userInfo:nil repeats:true];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getHomeDeviceData];
    [self.tableView reloadData];
    [self.refreshTimer setFireDate:[NSDate date]];
    self.time = 180;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.refreshTimer setFireDate:[NSDate distantFuture]];
}

- (void)timeChangeAction{
    self.time--;
    if (self.time <= 0) {
        self.time = 180;
        [self getHomeDeviceData];
    }
}

- (void)onRefresh{
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
        NSArray * modelArray = [DevideModel mj_objectArrayWithKeyValuesArray:result[@"data"]];
        DeviceManager.shareInstance.deviceNumber = modelArray.count;
        if (modelArray.count > 0){
            NSArray<DevideModel*> * array = [modelArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"lastConnect = %@",@"1"]];
            if (array.count > 0) {
                self.model = array.firstObject;
                [self setRightBarButtonItemWithTitlt:array.firstObject.name sel:@selector(changeDevice)];
                completion(array.firstObject);
            }else{
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
    } failure:^(NSString * _Nonnull errorMsg) {
        [self.refreshController endRefreshing];
    }];
}

- (void)getWeatherData:(NSString *)sgSn{
    [Request.shareInstance getUrl:DeviceInfoWeather params:@{@"sgSn":sgSn} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        self.model.weather = result[@"data"];
        [self.tableView reloadData];
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
}

- (IBAction)addDeviceAction:(id)sender{
    AddDeviceViewController * add = [[AddDeviceViewController alloc] init];
    add.title = @"Add Device".localized;
    add.hidesBottomBarWhenPushed = true;
    [self.navigationController pushViewController:add animated:true];
}

- (void)showCmd:(NSString *)cmd message:(NSArray*)array{
    dispatch_async(dispatch_get_main_queue(), ^{
//        [RMHelper showToast:cmd toView:self.view];
//        NSData * data = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingSortedKeys error:nil];
//        NSString * string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        [RMHelper showToast:string toView:self.view];
//        [self.tableView reloadData];
    });
}

- (void)getBluetoothData{
    if (BleManager.shareInstance.isConnented) {
        [self.view showHUDToast:@"Loading"];
    }else{
        [self.refreshController endRefreshing];
    }
    self.manager.delegate = self;
    NSString * deviceId = self.model.deviceId;
    NSString * sgSn = self.model.sgSn;
    self.model = [[DevideModel alloc] init];
    self.model.deviceId = deviceId;
    self.model.sgSn = sgSn;
    if (self.model.sgSn) {
        [self getWeatherData:self.model.sgSn];
    }
    [self.tableView reloadData];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [BleManager.shareInstance readWithCMDString:@"510" count:2 finish:^(NSArray * array){
            [self showCmd:@"511" message:array];
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
            [self showCmd:@"514" message:array];
            self.model.gridLight = [array.firstObject integerValue];
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"630" count:1 finish:^(NSArray * array){
            [self showCmd:@"630" message:array];
            self.model.generatorLight = [array.firstObject integerValue];
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"62D" count:1 finish:^(NSArray * array){
            [self showCmd:@"62D" message:array];
            self.model.evLight = [array.firstObject integerValue];
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"625" count:1 finish:^(NSArray * array){
            [self showCmd:@"625" message:array];
            self.model.backUpType = array.firstObject;
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"515" count:2 finish:^(NSArray * array){
            [self showCmd:@"515" message:array];
            self.model.batterySoc = array.firstObject;
            self.model.batteryCurrentElectricity = [NSString stringWithFormat:@"%.0f kWh",[self cumulativeWithArray:@[array.lastObject]]/100];
            dispatch_semaphore_signal(semaphore);
        }];

        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"51F" count:1 finish:^(NSArray * array){
            [self showCmd:@"51F" message:array];
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
            [self showCmd:@"521" message:array];
            self.model.generatorPower = [array.firstObject floatValue];
            dispatch_semaphore_signal(semaphore);
        }];

        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"524" count:1 finish:^(NSArray * array){
            [self showCmd:@"524" message:array];
            self.model.evPower = [array.firstObject floatValue];
            dispatch_semaphore_signal(semaphore);
        }];

        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"541" count:3 finish:^(NSArray * array){
            [self showCmd:@"541" message:array];
            self.model.nonBackUpPower = [array[0] floatValue];
            self.model.backUpPower = [array[1] floatValue];
            self.model.solarPower = [array[2] floatValue];
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"544" count:8 finish:^(NSArray * array){
            [self showCmd:@"544" message:array];
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
            [self.view hiddenHUD];
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
    [DeviceSwitchView showDeviceSwitchViewWithDelegate:self];
}

- (void)onSwitchDeviceSuccess{
    [self getHomeDeviceData];
}

- (void)changeCurrentDeviceStatusAction{
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
