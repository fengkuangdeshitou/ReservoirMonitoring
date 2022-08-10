//
//  WifiViewController.m
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/5/18.
//

#import "WifiViewController.h"
#import "WifiTableViewCell.h"
#import "NetworkTableViewCell.h"
#import "WifiAlertView.h"
#import "BleManager.h"
#import <NetworkExtension/NetworkExtension.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <CoreLocation/CoreLocation.h>

@interface WifiViewController ()<UITableViewDelegate,CLLocationManagerDelegate>

@property(nonatomic,weak)IBOutlet UITableView * tableView;
@property(nonatomic,strong)IBOutlet UIView * headerView;
@property(nonatomic,strong)IBOutlet UIView * footerView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSString * wifi;
@property (strong, nonatomic) NSString * deviceSSID;
@property (strong, nonatomic) NSTimer * timer;
@property (assign, nonatomic) NSInteger number;

@end

@implementation WifiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([NetworkTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([NetworkTableViewCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([WifiTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([WifiTableViewCell class])];
//    [self getWifiList];
//    // 如果是iOS13 未开启地理位置权限 需要提示一下
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        [self.locationManager requestWhenInUseAuthorization];
    }
    __weak typeof(self) weakSelf = self;
    if (BleManager.shareInstance.isConnented) {
        [BleManager.shareInstance readWithDictionary:@{@"type":@"NetInfo"} finish:^(NSDictionary * _Nonnull dict) {
            if (dict[@"SSID"]) {
                weakSelf.wifi = dict[@"wifi"];
                weakSelf.deviceSSID = dict[@"SSID"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
        }];
    }
    
    id info = nil;
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSString *str = info[@"SSID"];//name
        NSLog(@"info=%@",info);
        NSLog(@"str=%@",str);
        NSData * SSIDDATA = info[@"SSIDDATA"];
        id value = [[NSString alloc] initWithData:SSIDDATA encoding:NSUTF8StringEncoding];
        NSLog(@"value=%@",value);
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    [self.tableView reloadData];
}

- (NSString *)wifiName{
    NSString *wifiName = @"";
    CFArrayRef array = CNCopySupportedInterfaces();
    if (array != nil) {
        CFDictionaryRef dict =CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(array, 0));
        if (dict != nil) {
            NSDictionary * info = (NSDictionary*)CFBridgingRelease(dict);
            wifiName = [info valueForKey:@"SSID"];
        }
    }
    return wifiName;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        NetworkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([NetworkTableViewCell class]) forIndexPath:indexPath];
        cell.bleIcon.hidden = true;
        cell.address.text = @"WIFI status：";
        if (self.deviceSSID) {
            if ([self.wifi isEqualToString:@"connected"]) {
                cell.status.text = @"Connected";
                cell.status.textColor = [UIColor colorWithHexString:COLOR_MAIN_COLOR];
            }else{
                cell.status.text = @"Disconnect";
                cell.status.textColor = [UIColor colorWithHexString:@"#999999"];
            }
            cell.titleLabel.text = self.deviceSSID;
        }else{
            cell.titleLabel.text = @"--";
            cell.status.text = @"--";
            cell.status.textColor = [UIColor colorWithHexString:@"#999999"];
        }
        return cell;
    }else{
        WifiTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WifiTableViewCell class]) forIndexPath:indexPath];
        cell.titleLabel.text = [self wifiName];
        cell.line.hidden = true;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        [WifiAlertView showWifiAlertViewWithTitle:[self wifiName]
                                     showWifiName:false
                                       completion:^(NSString * wifiName, NSString * password) {
            [BleManager.shareInstance readWithDictionary:@{@"setwifi":@{[self wifiName]:password}} finish:^(NSDictionary * _Nonnull item) {
                if ([item[@"code"] intValue] == 0) {
                    [self loadTime];
                }
            }];
        }];
//        [BleManager.shareInstance readWithCMDString:@"620" count:1];
    }
    
}

- (void)loadTime{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view showHUDToast:@"Loading"];
        self.number = 10;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeChange) userInfo:nil repeats:true];
    });
}

- (void)timeChange{
    __weak typeof(self) weakSelf = self;
    self.number--;
    if (self.number == 0) {
        [self removeTimeAction];
        return;
    };
    [BleManager.shareInstance readWithDictionary:@{@"type":@"NetInfo"} finish:^(NSDictionary * _Nonnull dict) {
        if (dict[@"wifi"]) {
            NSString * wifi = dict[@"wifi"];
            if ([wifi isEqualToString:@"connected"]) {
                weakSelf.wifi = dict[@"wifi"];
                weakSelf.deviceSSID = dict[@"SSID"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [RMHelper showToast:@"config wifi success" toView:self.view];
                    [weakSelf.tableView reloadData];
                    [weakSelf.timer invalidate];
                    weakSelf.timer = nil;
                    [weakSelf.view hiddenHUD];
                });
            }else if ([wifi isEqualToString:@"connecting"]){
        
            }else if ([wifi isEqualToString:@"auth_failed"]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf removeTimeAction];
                    [RMHelper showToast:wifi toView:weakSelf.view];
                    [weakSelf.view hiddenHUD];
                });
            }else if ([wifi isEqualToString:@"ap_no_found"]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf removeTimeAction];
                    [RMHelper showToast:wifi toView:weakSelf.view];
                    [weakSelf.view hiddenHUD];
                });
            }
        }
    }];
}

- (void)removeTimeAction{
    [self.timer invalidate];
    self.timer = nil;
    [self.view hiddenHUD];
}

- (IBAction)addWiriAction{
    [WifiAlertView showWifiAlertViewWithTitle:@"Config Wi-Fi"
                                 showWifiName:true
                                   completion:^(NSString * wifiName, NSString * password) {
        [BleManager.shareInstance readWithDictionary:@{@"setwifi":@{wifiName:password}} finish:^(NSDictionary * _Nonnull item) {
            if ([item[@"code"] intValue] == 0) {
                [self loadTime];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [RMHelper showToast:@"Config wi-fi success" toView:self.view];
            });
        }];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if ([self wifiName].length > 0 && ![[self wifiName] hasSuffix:@"5G"]) {
        tableView.tableFooterView = [UIView new];
        return 2;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.section == 0 ? 80 : 78;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section == 0 ? 20 : 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 54;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return section == 0 ? self.headerView : self.footerView;
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
