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

@interface HomeViewController ()<DeviceSwitchViewDelegate,BleManagerDelegate,UITableViewDelegate>

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
                
    self.model = [[DevideModel alloc] init];
    self.manager = BleManager.shareInstance;
    
    [self.addEquipmentBtn showBorderWithRadius:25];
    [self setLeftBatButtonItemWithImage:[UIImage imageNamed:@"logo"] sel:nil];
    [self setRightBarButtonItemWithTitlt:@"小明的家" sel:@selector(changeDevice)];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([HomeTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([HomeTableViewCell class])];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
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
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"543" count:1 finish:^(NSArray * array){
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"529" count:4 finish:^(NSArray * array){
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"521" count:1 finish:^(NSArray * array){
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"52D" count:2 finish:^(NSArray * array){
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"524" count:1 finish:^(NSArray * array){
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"52F" count:2 finish:^(NSArray * array){
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"541" count:1 finish:^(NSArray * array){
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"533" count:2 finish:^(NSArray * array){
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"542" count:1 finish:^(NSArray * array){
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"531" count:2 finish:^(NSArray * array){
            dispatch_semaphore_signal(semaphore);
        }];
        
    });
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSDictionary * dict = @{@"511":@"1",@"510":@"1",@"515":@"2",@"51F":@"1",@"527":@"2",@"543":@"2",
//                            @"529":@"4",@"521":@"1",@"52D":@"2",@"524":@"1",@"52F":@"1",@"541":@"1",@"533":@"2",@"542":@"1",@"531":@"2"
//    };
//    NSArray * keys = dict.allKeys;
//    if (self.index == keys.count) {
//        return;
//    }
//    self.index ++;
//    [BleManager.shareInstance readWithCMDString:keys[self.index] count:[dict[keys[self.index]] intValue] finish:^(NSArray * array){
//
//    }];
}

- (void)bluetoothDidReceivedCMD:(NSString *)cmd array:(NSArray *)array{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"cmd=%@",cmd);
        if ([cmd isEqualToString:@"511"]) {
            self.model.currentMode = array.firstObject;
        }
        if ([cmd isEqualToString:@"510"]) {
            self.model.deviceStatus = array.firstObject;
        }
        if ([cmd isEqualToString:@"515"]) {
            self.model.soc = array.firstObject;
            self.model.socValue = [NSString stringWithFormat:@"%.0f kWh",[self cumulativeWithArray:@[array.lastObject]]/100];
        }
        if ([cmd isEqualToString:@"51F"]) {
            self.model.gridDirection = array.firstObject;
        }
        if ([cmd isEqualToString:@"51F"]) {
            self.model.gridValue = [NSString stringWithFormat:@"%.0f kWh",[self cumulativeWithArray:array]/100];
        }
        if ([cmd isEqualToString:@"543"]) {
            self.model.solarDirection = array.firstObject;
        }
        if ([cmd isEqualToString:@"529"]) {
            self.model.solarValue = [NSString stringWithFormat:@"%.0f kWh",[self cumulativeWithArray:array]/100];
        }
        if ([cmd isEqualToString:@"521"]) {
            self.model.generatorDirection = array.firstObject;
        }
        if ([cmd isEqualToString:@"52D"]) {
            self.model.generatorValue = [NSString stringWithFormat:@"%.0f kWh",[self cumulativeWithArray:array]/100];
        }
        if ([cmd isEqualToString:@"524"]) {
            self.model.EVDirection = array.firstObject;
        }
        if ([cmd isEqualToString:@"52F"]) {
            self.model.EVValue = [NSString stringWithFormat:@"%.0f kWh",[self cumulativeWithArray:array]/100];
        }
        if ([cmd isEqualToString:@"541"]) {
            self.model.otherLoadsDirection = array.firstObject;
        }
        if ([cmd isEqualToString:@"533"]) {
            self.model.otherLoadsValue = [NSString stringWithFormat:@"%.0f kWh",[self cumulativeWithArray:array]/100];
        }
        if ([cmd isEqualToString:@"542"]) {
            self.model.backupLoadsDirection = array.firstObject;
        }
        if ([cmd isEqualToString:@"531"]) {
            self.model.backupLoadsValue = [NSString stringWithFormat:@"%.0f kWh",[self cumulativeWithArray:array]/100];
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

- (void)changeCurrentDeviceStatusAction{
    SwitchModeViewController * model = [[SwitchModeViewController alloc] init];
    model.title = @"Switch operation mode".localized;
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
