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

@interface SetViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,weak)IBOutlet UITableView * tableView;
@property(nonatomic,weak)IBOutlet UIButton * loginout;
@property(nonatomic,strong)NSArray * dataArray;
@property(nonatomic,strong)NSArray * iconArray;
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
    [self setRightBarButtonItemWithTitlt:version sel:nil];
    self.loginout.hidden = true;
    self.dataArray = @[@"User Info".localized,@"Network".localized,@"Update".localized,@"FAQ".localized,@"Fault&Warning".localized,@"Commissioning".localized];
    self.iconArray = @[@"icon_information",@"icon_list",@"icon_update",@"icon_help",@"icon_warning",@"icon_test"];
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
        if (self.model.defDevId) {
            [NSUserDefaults.standardUserDefaults setValue:self.model.defDevId forKey:CURRENR_DEVID];
        }
        [self.tableView reloadData];
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
}

- (IBAction)logoutAtion:(id)sender{
    [NSUserDefaults.standardUserDefaults removeObjectForKey:@"token"];
    [[NSNotificationCenter defaultCenter] postNotificationName:LOG_OUT object:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        SetInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SetInfoTableViewCell class]) forIndexPath:indexPath];
        cell.model = self.model;
        return cell;
    }else{
        SetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SetTableViewCell class]) forIndexPath:indexPath];
        cell.icon.image = [UIImage imageNamed:self.iconArray[indexPath.row]];
        cell.titleLabel.text = self.dataArray[indexPath.row];
        cell.line.hidden = self.model.userType.intValue == 1 ? indexPath.row == self.dataArray.count-1 : indexPath.row == 3;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            InfoViewController * info = [[InfoViewController alloc] init];
            info.model = self.model;
            info.hidesBottomBarWhenPushed = true;
            info.title = self.dataArray[indexPath.row];
            [self.navigationController pushViewController:info animated:true];
        }else if(indexPath.row == 1){
            NetworkViewController * network = [[NetworkViewController alloc] init];
            network.title = @"Bluetooth config".localized;
            network.hidesBottomBarWhenPushed = true;
            [self.navigationController pushViewController:network animated:true];
        }else if(indexPath.row == 2){
            UpdateViewController * update = [[UpdateViewController alloc] init];
            update.title = @"Software Version".localized;
            update.hidesBottomBarWhenPushed = true;
            [self.navigationController pushViewController:update animated:true];
        }else if (indexPath.row == 3){
            HelpViewController * help = [[HelpViewController alloc] init];
            help.title = self.dataArray[indexPath.row];
            help.hidesBottomBarWhenPushed = true;
            [self.navigationController pushViewController:help animated:true];
        }else if (indexPath.row == 4){
            WarningViewController * warning = [[WarningViewController alloc] init];
            warning.title = self.dataArray[indexPath.row];
            warning.hidesBottomBarWhenPushed = true;
            [self.navigationController pushViewController:warning animated:true];
        }else if (indexPath.row == 5){
            DebugViewController * debug = [[DebugViewController alloc] init];
            debug.title = self.dataArray[indexPath.row];
            debug.hidesBottomBarWhenPushed = true;
            [self.navigationController pushViewController:debug animated:true];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.model == nil ? 0 : 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section == 0 ? 1 : self.model.userType.intValue == 2 ? 4 : self.dataArray.count;
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
