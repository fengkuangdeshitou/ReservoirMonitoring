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

@interface NetworkViewController ()<UITableViewDelegate,UITableViewDataSource,BleManagerDelegate>

@property(nonatomic,weak)IBOutlet UITableView * tableView;
@property(nonatomic,strong) PeripheralModel * model;
@property(nonatomic,strong) BleManager * manager;
@property(nonatomic,strong) NSMutableArray<PeripheralModel *> * dataArray;

@end

@implementation NetworkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.dataArray = [[NSMutableArray alloc] init];
    
    self.tableView.rowHeight = 80;
    [self.tableView registerNib:[UINib  nibWithNibName:NSStringFromClass([NetworkTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([NetworkTableViewCell class])];
    self.manager = BleManager.shareInstance;
    self.manager.delegate = self;
    [self.manager startScanning];
//    self.tableView.hidden = true;
}

//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
////    [self.manager readWithCMDString:@"634" count:6];
//    [self.manager writeWithCMDString:@"634" value:@[@"1",@"2",@"3",@"4",@"5",@"6"]];
////    [self.manager writeWithCMDString:@"620" string:@"1"];
//}

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
                    [BleManager.shareInstance startScanning];
                    break;;
                }
            }
        });
    });
}

- (void)bluetoothDidConnectPeripheral:(CBPeripheral *)peripheral{
    self.model = [[PeripheralModel alloc] init];
    self.model.peripheral = peripheral;
    self.model.isConnected = true;
    [self.tableView reloadData];
}

- (void)bluetoothDidDisconnectPeripheral:(CBPeripheral *)peripheral{
    if (self.model) {
        self.model.isConnected = false;
        [self.tableView reloadData];
    }
}

- (void)bluetoothdidDiscoverPeripheral:(CBPeripheral *)peripheral RSSI:(NSNumber *)RSSI{
    dispatch_async(dispatch_get_main_queue(), ^{
        PeripheralModel * model = [[PeripheralModel alloc] init];
        model.peripheral = peripheral;
        model.rssi = RSSI;
        [self.dataArray addObject:model];
        [self.tableView reloadData];
    });
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NetworkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([NetworkTableViewCell class]) forIndexPath:indexPath];
    if (indexPath.section == 0) {
        cell.bleIcon.image = [UIImage imageNamed:self.model.isConnected ? @"bluetooth_active" : @"bluetooth_gray"];
    }else{
        cell.bleIcon.image = [UIImage imageNamed:@"bluetooth_gray"];
    }
    cell.model = indexPath.section == 0 ? self.model : self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        WifiViewController * wifi = [[WifiViewController alloc] init];
        wifi.title = @"Wi-Fi config".localized;
        wifi.model = self.model;
        [self.navigationController pushViewController:wifi animated:true];
    }else{
        [self.manager connectPeripheral:self.dataArray[indexPath.row].peripheral];
//        [self.dataArray removeObjectAtIndex:indexPath.row];
//        [self.tableView reloadData];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
