//
//  WifiViewController.m
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/5/18.
//

#import "WifiViewController.h"
#import "WifiTableViewCell.h"
#import "WifiInfoTableViewCell.h"
#import "WifiAlertView.h"
#import "BleManager.h"
#import <NetworkExtension/NetworkExtension.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <CoreLocation/CoreLocation.h>

@interface WifiViewController ()<UITableViewDelegate>

@property(nonatomic,weak)IBOutlet UITableView * tableView;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation WifiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([WifiInfoTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([WifiInfoTableViewCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([WifiTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([WifiTableViewCell class])];
    [self.model addObserver:self forKeyPath:@"isConnected" options:NSKeyValueObservingOptionNew context:nil];
    [self getWifiList];
//    NSLog(@"currentWifi=%@",[self wifiName]);
//    NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
//    CGFloat version = [phoneVersion floatValue];
//    // 如果是iOS13 未开启地理位置权限 需要提示一下
//    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined && version >= 13) {
//        self.locationManager = [[CLLocationManager alloc] init];
//        [self.locationManager requestWhenInUseAuthorization];
//    }
//    id info = nil;
//    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
//    for (NSString *ifnam in ifs) {
//        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
//        NSString *str = info[@"SSID"];//name
//        NSLog(@"str=%@",str);
//    }
}

- (NSString *)wifiName{
    NSString *wifiName = @"";
    CFArrayRef myArray = CNCopySupportedInterfaces();
    NSLog(@"myArray=%@",myArray);
    if (myArray != nil) {
        CFDictionaryRef myDict =CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
        if (myDict != nil) {
            NSDictionary *dict = (NSDictionary*)CFBridgingRelease(myDict);
            wifiName = [dict valueForKey:@"SSID"];
        }
    }
    return wifiName;
}

- (void)getWifiList{

    NSMutableDictionary* options = [[NSMutableDictionary alloc] init];
    [options setObject:@"🔑Wifi子标题🔑" forKey:kNEHotspotHelperOptionDisplayName];

    dispatch_queue_t queue = dispatch_queue_create("com.pronetwayXY", NULL);
    BOOL returnType = [NEHotspotHelper registerWithOptions:options queue:queue handler: ^(NEHotspotHelperCommand * cmd) {
        NEHotspotNetwork* network;
        NSLog(@"COMMAND TYPE:   %ld", (long)cmd.commandType);
        [cmd createResponse:kNEHotspotHelperResultAuthenticationRequired];
        if (cmd.commandType == kNEHotspotHelperCommandTypeEvaluate || cmd.commandType ==kNEHotspotHelperCommandTypeFilterScanList) {
            NSLog(@"WIFILIST:   %@", cmd.networkList);
            for (network  in cmd.networkList) {
                // NSLog(@"COMMAND TYPE After:   %ld", (long)cmd.commandType);
                if ([network.SSID isEqualToString:@"ssid"]|| [network.SSID isEqualToString:@"proict_test"]) {

                    double signalStrength = network.signalStrength;
                    NSLog(@"Signal Strength: %f", signalStrength);
                    [network setConfidence:kNEHotspotHelperConfidenceHigh];
                    [network setPassword:@"password"];

                    NEHotspotHelperResponse *response = [cmd createResponse:kNEHotspotHelperResultSuccess];
                    NSLog(@"Response CMD %@", response);

                    [response setNetworkList:@[network]];
                    [response setNetwork:network];
                    [response deliver];
                }
            }
        }
    }];
    NSLog(@"result :%d", returnType);
    NSArray *array = [NEHotspotHelper supportedNetworkInterfaces];
    NSLog(@"wifiArray:%@", array);
    NEHotspotNetwork *connectedNetwork = [array lastObject];
    NSLog(@"supported Network Interface: %@", connectedNetwork);

}

- (void)connectWifi{
    NEHotspotConfiguration * hotmode = [[NEHotspotConfiguration alloc] initWithSSID:@"wifiSSID" passphrase:@"password" isWEP:NO];
    __weak typeof(self) weakSelf = self;
    [[NEHotspotConfigurationManager sharedManager] applyConfiguration:hotmode completionHandler:^(NSError * _Nullable error) {
        if (error) {
            if (error.code == NEHotspotConfigurationErrorAlreadyAssociated) {
                //已连接
            }
            else if (error.code == NEHotspotConfigurationErrorUserDenied) {
                //用户点击取消
            }
            else{
                //注：这个方法存在一个问题，如果你加入一个不存在的WiFi，会弹出无法加入WiFi的弹框，但是本方法的回调error没有值。在这里，我是通过判断当前wifi是否是我要加入的wifi来解决这个问题的
            }
        }
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        WifiInfoTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WifiInfoTableViewCell class]) forIndexPath:indexPath];
        cell.model = self.model;
        [cell.wifiBtn addTarget:self action:@selector(wifiChangeClick:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }else{
        WifiTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WifiTableViewCell class]) forIndexPath:indexPath];
        return cell;
    }
}

- (void)wifiChangeClick:(UIButton *)btn{
    btn.selected = !btn.selected;
    [[NEHotspotConfigurationManager sharedManager] getConfiguredSSIDsWithCompletionHandler:^(NSArray<NSString *> * _Nonnull wifiArray) {
        NSLog(@"wifiArray=%@",wifiArray);
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        [WifiAlertView showWifiAlertViewWithTitle:@"Config Wi-Fi"
                                     showWifiName:YES
                                       completion:^(NSString * wifiName, NSString * password) {
            [BleManager.shareInstance readWithDictionary:@{@"setwifi":@{wifiName:password}} finish:^(NSDictionary * _Nonnull item) {
                [RMHelper showToast:@"Config wi-fi success" toView:self.view];
            }];
        }];
//        [BleManager.shareInstance readWithCMDString:@"620" count:1];
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section == 0 ? 1 : 5;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.section == 0 ? 185 : 78;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}

- (void)dealloc{
    [self.model removeObserver:self forKeyPath:@"isConnected"];
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
