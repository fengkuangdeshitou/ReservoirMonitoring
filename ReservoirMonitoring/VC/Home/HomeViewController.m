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

@interface HomeViewController ()<DeviceSwitchViewDelegate,BleManagerDelegate,UITableViewDelegate,DeviceSwitchViewDelegate>

@property(nonatomic,weak)IBOutlet UIButton * addEquipmentBtn;
@property(nonatomic,weak)IBOutlet UITableView * tableView;
@property(nonatomic,strong)DevideModel * model;
@property(nonatomic,strong)BleManager * manager;
@property(nonatomic)NSInteger index;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
                
    self.tableView.refreshControl = self.refreshController;
    [self.refreshController addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    self.manager = BleManager.shareInstance;
    [self.addEquipmentBtn showBorderWithRadius:25];
    [self setLeftBatButtonItemWithImage:[UIImage imageNamed:@"logo"] sel:nil];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([HomeTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([HomeTableViewCell class])];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getHomeDeviceData];
}

- (void)onRefresh{
    [self getHomeDeviceData];
}

- (void)getHomeDeviceData{
    if (RMHelper.getUserType) {
        if (RMHelper.getLoadDataForBluetooth) {
            self.model = [[DevideModel alloc] init];
            [self getCurrentDevice:^(DevideModel *model) {
                [self getBluetoothData];
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
        NSArray<DevideModel*> * array = [modelArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"lastConnect = %@",@"1"]];
        [self setRightBarButtonItemWithTitlt:array.firstObject.name sel:@selector(changeDevice)];
        completion(array.firstObject);
    } failure:^(NSString * _Nonnull errorMsg) {
        [self.refreshController endRefreshing];
    }];
}

- (void)getNetworkData{
    [self getCurrentDevice:^(DevideModel *model) {
        [self getHomeData:model.sgSn];
    }];
}

- (void)getHomeData:(NSString *)sgSn{
    NSDate * date = [NSDate date];
    [Request.shareInstance getUrl:HomeDeviceInfo params:@{@"sgSn":sgSn,@"dayMonthYearFormat":[NSString stringWithFormat:@"%ld-%02ld-%02ld",date.br_year,date.br_month,date.br_day]} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        self.model = [DevideModel mj_objectWithKeyValues:result[@"data"]];
        [self.tableView reloadData];
        [self.refreshController endRefreshing];
    } failure:^(NSString * _Nonnull errorMsg) {
        [self.refreshController endRefreshing];
    }];
}

- (void)getBluetoothData{
    self.manager.delegate = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [BleManager.shareInstance readWithCMDString:@"511" count:1 finish:^(NSArray * array){
            dispatch_semaphore_signal(semaphore);
        }];

        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"510" count:1 finish:^(NSArray * array){
            dispatch_semaphore_signal(semaphore);
        }];

        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"515" count:2 finish:^(NSArray * array){
            dispatch_semaphore_signal(semaphore);
        }];

        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"51F" count:1 finish:^(NSArray * array){
            dispatch_semaphore_signal(semaphore);
        }];

        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"527" count:2 finish:^(NSArray * array){
            self.model.gridElectricity = [array.firstObject intValue]+([array.lastObject intValue]*65536);
            dispatch_semaphore_signal(semaphore);
        }];

        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"543" count:1 finish:^(NSArray * array){
            dispatch_semaphore_signal(semaphore);
        }];

        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"529" count:4 finish:^(NSArray * array){
            int left = [array[0] intValue]+[array[1] intValue]*65536;
            int right = [array[2] intValue]+[array[3] intValue]*65536;
            self.model.solarElectricity = left+right*65536;
            dispatch_semaphore_signal(semaphore);
        }];

        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"521" count:1 finish:^(NSArray * array){
            dispatch_semaphore_signal(semaphore);
        }];

        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"52D" count:2 finish:^(NSArray * array){
            self.model.generatorElectricity = [array.firstObject intValue]+([array.lastObject intValue]*65536);
            dispatch_semaphore_signal(semaphore);
        }];

        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"524" count:1 finish:^(NSArray * array){
            dispatch_semaphore_signal(semaphore);
        }];

        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"52F" count:2 finish:^(NSArray * array){
            self.model.evElectricity = [array.firstObject intValue]+([array.lastObject intValue]*65536);
            dispatch_semaphore_signal(semaphore);
        }];

        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"541" count:1 finish:^(NSArray * array){
            dispatch_semaphore_signal(semaphore);
        }];

        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"533" count:2 finish:^(NSArray * array){
            self.model.nonBackUpElectricity = [array.firstObject intValue]+([array.lastObject intValue]*65536);
            dispatch_semaphore_signal(semaphore);
        }];

        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"542" count:1 finish:^(NSArray * array){
            dispatch_semaphore_signal(semaphore);
        }];

        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"531" count:2 finish:^(NSArray * array){
            self.model.backUpElectricity = [array.firstObject intValue]+([array.lastObject intValue]*65536);
            dispatch_semaphore_signal(semaphore);
        }];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    
    });
}

- (void)bluetoothDidReceivedCMD:(NSString *)cmd array:(NSArray *)array{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"cmd=%@",cmd);
        if ([cmd isEqualToString:@"511"]) {
            self.model.workStatus = array.firstObject;
        }
        if ([cmd isEqualToString:@"510"]) {
            self.model.deviceStatus = array.firstObject;
        }
        if ([cmd isEqualToString:@"515"]) {
            self.model.batterySoc = array.firstObject;
            self.model.batteryCurrentElectricity = [NSString stringWithFormat:@"%.0f kWh",[self cumulativeWithArray:@[array.lastObject]]/100];
        }
        if ([cmd isEqualToString:@"51F"]) {
            self.model.gridPower = [array.firstObject floatValue];
        }
        if ([cmd isEqualToString:@"51F"]) {
            self.model.gridElectricity = [self cumulativeWithArray:array]/100;
        }
        if ([cmd isEqualToString:@"543"]) {
            self.model.solarPower = [array.firstObject floatValue];
        }
        if ([cmd isEqualToString:@"529"]) {
            self.model.solarElectricity = [self cumulativeWithArray:array]/100;
        }
        if ([cmd isEqualToString:@"521"]) {
            self.model.generatorPower = [array.firstObject floatValue];
        }
        if ([cmd isEqualToString:@"52D"]) {
            self.model.generatorElectricity = [self cumulativeWithArray:array]/100;
        }
        if ([cmd isEqualToString:@"524"]) {
            self.model.evPower = [array.firstObject floatValue];
        }
        if ([cmd isEqualToString:@"52F"]) {
            self.model.evElectricity = [self cumulativeWithArray:array]/100;
        }
        if ([cmd isEqualToString:@"541"]) {
            self.model.nonBackUpPower = [array.firstObject floatValue];
        }
        if ([cmd isEqualToString:@"533"]) {
            self.model.nonBackUpElectricity = [self cumulativeWithArray:array]/100;
        }
        if ([cmd isEqualToString:@"542"]) {
            self.model.backUpPower = [array.firstObject floatValue];
        }
        if ([cmd isEqualToString:@"531"]) {
            self.model.backUpElectricity = [self cumulativeWithArray:array]/100;
        }
        [self.tableView reloadData];
    });
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
    if (!self.model.devId) {
        return;
    }
    SwitchModeViewController * model = [[SwitchModeViewController alloc] init];
    model.title = @"Switch operation mode".localized;
    model.devId = self.model.devId;
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
