//
//  SetViewController.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/11.
//

#import "SetViewController.h"
#import "SetInfoTableViewCell.h"
#import "SetTableViewCell.h"
#import "InfoViewController.h"
#import "NetworkViewController.h"
#import "UpdateViewController.h"
#import "HelpViewController.h"
#import "WarningViewController.h"
#import "DebugViewController.h"
#import "UserModel.h"
#import "GlobelDescAlertView.h"
#import "WriteOffViewController.h"
#import "MessageViewController.h"

@interface SetViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,weak)IBOutlet UITableView * tableView;
@property(nonatomic,weak)IBOutlet UIButton * loginout;
@property(nonatomic,strong)NSMutableArray * dataArray;
@property(nonatomic,strong)NSMutableArray * iconArray;
@property(nonatomic,strong)UserModel * model;

@end

@implementation SetViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self requestUserInfo];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setLeftBarImageForSel:nil];
    
    NSString * version = NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"];
#ifdef DEBUG
    NSString * string = @"debug_";
#else
    NSString * string = @"";
#endif
    [self setRightBarButtonItemWithTitlt:[NSString stringWithFormat:@"%@%@",string,version] sel:nil];
    self.dataArray = [[NSMutableArray alloc] initWithArray:@[@"User Info".localized,@"Network".localized,@"Update".localized,@"FAQ".localized,@"Cancel account".localized]];
    self.iconArray = [[NSMutableArray alloc] initWithArray:@[@"icon_information",@"icon_list",@"icon_update",@"icon_help",@"icon_delete"]];
    if (RMHelper.getUserType){
        [self.dataArray insertObject:@"Fault&Warning".localized atIndex:self.dataArray.count-1];
        [self.dataArray insertObject:@"Commissioning".localized atIndex:self.dataArray.count-1];
        [self.dataArray insertObject:@"Message".localized atIndex:self.dataArray.count-1];
        
        [self.iconArray insertObject:@"icon_warning" atIndex:self.iconArray.count-1];
        [self.iconArray insertObject:@"icon_test" atIndex:self.iconArray.count-1];
        [self.iconArray insertObject:@"icon_message" atIndex:self.iconArray.count-1];
    }
    [self.loginout setTitle:@"Log Out".localized forState:UIControlStateNormal];
    [self.loginout showBorderWithRadius:25];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SetInfoTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([SetInfoTableViewCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SetTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([SetTableViewCell class])];
    
}

- (void)requestUserInfo{
    [Request.shareInstance getUrl:UserInfo params:@{} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        self.loginout.hidden = false;
        self.model = [UserModel mj_objectWithKeyValues:result[@"data"]];
        if (RMHelper.isTouristsModel){
            self.model.userType = @"2";
        }
        [NSUserDefaults.standardUserDefaults setValue:self.model.defDevId forKey:CURRENR_DEVID];
        [self.tableView reloadData];
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
}

- (IBAction)logoutAtion:(id)sender{
    [RMHelper saveTouristsModel:false];
    [BleManager.shareInstance disconnectPeripheral];
    [NSUserDefaults.standardUserDefaults removeObjectForKey:@"token"];
    [[NSNotificationCenter defaultCenter] postNotificationName:LOG_OUT object:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        SetInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SetInfoTableViewCell class]) forIndexPath:indexPath];
        if (self.model) {
            cell.model = self.model;
        }
        return cell;
    }else{
        SetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SetTableViewCell class]) forIndexPath:indexPath];
        cell.icon.image = [UIImage imageNamed:self.iconArray[indexPath.row]];
        cell.titleLabel.text = self.dataArray[indexPath.row];
        cell.line.hidden = indexPath.row == self.dataArray.count-1;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (RMHelper.isTouristsModel){
        return;
    }
    if (indexPath.section == 1) {
        NSString * string = self.dataArray[indexPath.row];
        if ([string isEqualToString:@"User Info".localized]){
            InfoViewController * info = [[InfoViewController alloc] init];
            info.model = self.model;
            info.hidesBottomBarWhenPushed = true;
            info.title = self.dataArray[indexPath.row];
            [self.navigationController pushViewController:info animated:true];
        }else if ([string isEqualToString:@"Network".localized]){
            NetworkViewController * network = [[NetworkViewController alloc] init];
            network.title = @"Bluetooth config".localized;
            network.showNext = true;
            network.hidesBottomBarWhenPushed = true;
            [self.navigationController pushViewController:network animated:true];
        }else if ([string isEqualToString:@"Update".localized]){
            if (DeviceManager.shareInstance.deviceNumber == 0) {
                [GlobelDescAlertView showAlertViewWithTitle:@"Tips" desc:@"Please add device to continue" btnTitle:nil completion:nil];
                return;
            }
            UpdateViewController * update = [[UpdateViewController alloc] init];
            update.title = @"Software Version".localized;
            update.hidesBottomBarWhenPushed = true;
            [self.navigationController pushViewController:update animated:true];
        }else if ([string isEqualToString:@"FAQ".localized]){
            HelpViewController * help = [[HelpViewController alloc] init];
            help.title = self.dataArray[indexPath.row];
            help.hidesBottomBarWhenPushed = true;
            [self.navigationController pushViewController:help animated:true];
        }else if ([string isEqualToString:@"Fault&Warning".localized]){
            WarningViewController * warning = [[WarningViewController alloc] init];
            warning.title = self.dataArray[indexPath.row];
            warning.hidesBottomBarWhenPushed = true;
            [self.navigationController pushViewController:warning animated:true];
        }else if ([string isEqualToString:@"Commissioning".localized]){
            DebugViewController * debug = [[DebugViewController alloc] init];
            debug.title = self.dataArray[indexPath.row];
            debug.hidesBottomBarWhenPushed = true;
            [self.navigationController pushViewController:debug animated:true];
        }else if ([string isEqualToString:@"Message".localized]){
            MessageViewController * message = [[MessageViewController alloc] init];
            message.title = self.dataArray[indexPath.row];
            message.hidesBottomBarWhenPushed = true;
            [self.navigationController pushViewController:message animated:true];
        }else if ([string isEqualToString:@"Cancel account".localized]){
            WriteOffViewController * writeoff = [[WriteOffViewController alloc] init];
            writeoff.title = @"Cancel account";
            writeoff.hidesBottomBarWhenPushed = true;
            [self.navigationController pushViewController:writeoff animated:true];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }else{
        return self.dataArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.section == 0 ? 110 : 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 15;
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
