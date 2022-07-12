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
//#import <NetworkExtension/NEHotspotConfigurationManager.h>

@interface WifiViewController ()<UITableViewDelegate>

@property(nonatomic,weak)IBOutlet UITableView * tableView;

@end

@implementation WifiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([WifiInfoTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([WifiInfoTableViewCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([WifiTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([WifiTableViewCell class])];
    [self.model addObserver:self forKeyPath:@"isConnected" options:NSKeyValueObservingOptionNew context:nil];
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
    
//    NEHotspotConfiguration * hotmode = [[NEHotspotConfiguration alloc] initWithSSID:@"wifiSSID" passphrase:@"password" isWEP:NO];
//    __weak typeof(self) weakSelf = self;
//    [[NEHotspotConfigurationManager sharedManager] applyConfiguration:hotmode completionHandler:^(NSError * _Nullable error) {
//        if (error) {
//            if (error.code == NEHotspotConfigurationErrorAlreadyAssociated) {
//                //已连接
//            }
//            else if (error.code == NEHotspotConfigurationErrorUserDenied) {
//                //用户点击取消
//            }
//            else{
//                //注：这个方法存在一个问题，如果你加入一个不存在的WiFi，会弹出无法加入WiFi的弹框，但是本方法的回调error没有值。在这里，我是通过判断当前wifi是否是我要加入的wifi来解决这个问题的
//            }
//        }
//    }];
    
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
