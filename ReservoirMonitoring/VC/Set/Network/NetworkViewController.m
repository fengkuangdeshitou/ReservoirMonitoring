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
#import "DevideModel.h"
#import "GlobelDescAlertView.h"
#import "WifiInfoTableViewCell.h"
#import <CoreLocation/CoreLocation.h>

@interface NetworkViewController ()<UITableViewDelegate,UITableViewDataSource,BleManagerDelegate>

@property(nonatomic,weak)IBOutlet UITableView * tableView;
@property(nonatomic,weak)IBOutlet UIView * normalView;
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
        NSArray * modelArray = [DevideModel mj_objectArrayWithKeyValuesArray:result[@"data"]];
        NSArray<DevideModel*> * filter = [modelArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"lastConnect == %@",@"1"]];
        if (filter.count > 0) {
            self.model = filter.firstObject;
            if (BleManager.shareInstance.isConnented) {
                if ([BleManager.shareInstance.rtusn isEqualToString:self.model.rtuSn]) {
                    self.model.isConnected = BleManager.shareInstance.isConnented;
                }else{
                    [BleManager.shareInstance disconnectPeripheral];
                }
            }
        }
        self.dataArray = [modelArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"lastConnect != %@",@"1"]];
        self.normalView.hidden = self.dataArray.count > 0;
        [self.tableView reloadData];
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
}

- (void)addDevice{
    if (DeviceManager.shareInstance.deviceNumber == 0) {
        [GlobelDescAlertView showAlertViewWithTitle:@"Tips" desc:@"Please add device to continue" btnTitle:nil completion:nil];
        return;
    }
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
        [GlobelDescAlertView showAlertViewWithTitle:@"Tips" desc:@"Location permission required, click \"Yes\" to enable location usage." btnTitle:@"YES" completion:^{
            [UIApplication.sharedApplication openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        }];
        return;
    }
    WifiViewController * wifi = [[WifiViewController alloc] init];
    wifi.title = @"Wi-Fi config".localized;
    wifi.devId = self.model.deviceId;
    [self.navigationController pushViewController:wifi animated:true];
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
        if (self.model) {
            cell.model = self.model;
        }
        return cell;
    }else{
        NetworkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([NetworkTableViewCell class]) forIndexPath:indexPath];
        cell.bleIcon.image = [UIImage imageNamed:@"bluetooth_gray"];
        cell.model = self.dataArray[indexPath.row];
        cell.line.hidden = indexPath.row == self.dataArray.count-1;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {

    }else{
        DevideModel * model = self.dataArray[indexPath.row];
        [GlobelDescAlertView showAlertViewWithTitle:@"Tips" desc:[NSString stringWithFormat:@"Please confirm switching to new device (SN: %@) for bluetooth connection.",model.sgSn] btnTitle:@"Acknowledge" completion:^{
            [BleManager.shareInstance disconnectPeripheral];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self switchDeviceAction:model.deviceId];
            });
        }];
    }
}

- (void)switchDeviceAction:(NSString *)deviceId{
    [Request.shareInstance getUrl:SwitchDevice params:@{@"id":deviceId} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        [NSUserDefaults.standardUserDefaults setValue:deviceId forKey:CURRENR_DEVID];
        [self getDeviceList];
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView * header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 52)];
    header.clipsToBounds = true;
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH-15, header.height)];
    titleLabel.text = section == 0 ? @"Current device".localized : (self.dataArray.count == 0 ? @"No other device" : @"Other device".localized);
    titleLabel.textColor = UIColor.whiteColor;
    titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    [header addSubview:titleLabel];
    return header;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section == 0 ? 1 : self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 52;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 135;
    }else{
        return 80;
    }
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
