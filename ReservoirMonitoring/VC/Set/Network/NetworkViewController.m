//
//  NetworkViewController.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/5/9.
//

#import "NetworkViewController.h"
#import "NetworkTableViewCell.h"
#import "WifiViewController.h"
#import "BleManager.h"
#import "PeripheralModel.h"
#import "AddDeviceViewController.h"
#import "DevideModel.h"
#import "GlobelDescAlertView.h"
#import "WifiInfoTableViewCell.h"

@interface NetworkViewController ()<UITableViewDelegate,UITableViewDataSource,BleManagerDelegate>

@property(nonatomic,weak)IBOutlet UITableView * tableView;
@property(nonatomic,strong) DevideModel * model;
@property(nonatomic,strong) NSArray * dataArray;

@end

@implementation NetworkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (self.showNext) {
        UIBarButtonItem * add = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(addDevice)];
        self.navigationItem.rightBarButtonItem = add;
    }
    
    [self.tableView registerNib:[UINib  nibWithNibName:NSStringFromClass([NetworkTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([NetworkTableViewCell class])];
    [self.tableView registerNib:[UINib  nibWithNibName:NSStringFromClass([WifiInfoTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([WifiInfoTableViewCell class])];
    [self getDeviceList];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    BleManager.shareInstance.delegate = self;
}

- (void)getDeviceList{
    [Request.shareInstance getUrl:DeviceList params:@{} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        self.dataArray = [DevideModel mj_objectArrayWithKeyValuesArray:result[@"data"]];
        NSArray<DevideModel*> * filter = [self.dataArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"lastConnect == %@",@"1"]];
        if (filter.count > 0) {
            self.model = filter.firstObject;
            self.model.isConnected = BleManager.shareInstance.isConnented;
        }
        [self.tableView reloadData];
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
}

- (void)addDevice{
//    AddDeviceViewController * add = [[AddDeviceViewController alloc] init];
//    add.title = @"Add Device".localized;
//    [self.navigationController pushViewController:add animated:true];
    WifiViewController * wifi = [[WifiViewController alloc] init];
    wifi.title = @"Wi-Fi config".localized;
    [self.navigationController pushViewController:wifi animated:true];
}

- (void)bluetoothDidUpdateState:(CBCentralManager *)central{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (central.state) {
                case CBManagerStateUnknown:
                    NSLog(@"未知状态");
                    break;
                case CBManagerStateResetting:
                    NSLog(@"重启状态");
                    break;
                case CBManagerStateUnsupported:
                    NSLog(@"不支持");
                    break;
                case CBManagerStateUnauthorized:
                    NSLog(@"未授权");
                    break;
                case CBManagerStatePoweredOff:{
                    NSLog(@"蓝牙未开启");
                    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"TIPS" message:@"Current device Bluetooth is not enabled, if you want to continue, now turn on Bluetooth." preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"Cancel".localized style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        [self.navigationController popViewControllerAnimated:YES];
                    }];
                    UIAlertAction * action = [UIAlertAction actionWithTitle:@"Confirm".localized style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [UIApplication.sharedApplication openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {
                                                    
                        }];
                    }];
                    [alert addAction:cancel];
                    [alert addAction:action];
                    [self presentViewController:alert animated:YES completion:^{
                                            
                    }];
                }
                    break;
                case CBManagerStatePoweredOn:{
                    NSLog(@"蓝牙已开启");
                    break;;
                }
            }
        });
    });
}

- (void)bluetoothDidConnectPeripheral:(CBPeripheral *)peripheral{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.model) {
            self.model.isConnected = true;
            [self.tableView reloadData];
        }
    });
}

- (void)bluetoothDidDisconnectPeripheral:(CBPeripheral *)peripheral{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.model) {
            self.model.isConnected = false;
            [self.tableView reloadData];
        }
    });
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        WifiInfoTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WifiInfoTableViewCell class]) forIndexPath:indexPath];
        cell.model = self.model;
        return cell;
    }else{
        NetworkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([NetworkTableViewCell class]) forIndexPath:indexPath];
        cell.bleIcon.image = [UIImage imageNamed:@"bluetooth_gray"];
        cell.model = self.dataArray[indexPath.row];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
//        WifiViewController * wifi = [[WifiViewController alloc] init];
//        wifi.title = @"Wi-Fi config".localized;
//        wifi.model = self.model;
//        [self.navigationController pushViewController:wifi animated:true];
    }else{
        if (self.model.isConnected) {
            [RMHelper showToast:@"do not reconnect" toView:self.view];
        }else{
            DevideModel * model = self.dataArray[indexPath.row];
            if ([model.rtuSn isEqualToString:self.model.rtuSn]) {
                BleManager.shareInstance.rtusn = model.rtuSn;
                [BleManager.shareInstance startScanning];
            }else{
                [GlobelDescAlertView showAlertViewWithTitle:@"Tips" desc:[NSString stringWithFormat:@"Please switch the %@ to the current device",self.model.rtuSn] btnTitle:nil completion:nil];
            }
        }
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView * header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 52)];
    header.clipsToBounds = true;
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH-15, header.height)];
    titleLabel.text = section == 0 ? @"Current device".localized : @"Other device".localized;
    titleLabel.textColor = UIColor.whiteColor;
    titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    [header addSubview:titleLabel];
    return header;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section == 0 ? (self.model == nil ? 0 : 1) : self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return (self.model == nil && section == 0) ? 0.01 : 52;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.section == 0 ? 135 : 80;
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
