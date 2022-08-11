//
//  OtherViewController.m
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/5/13.
//

#import "OtherViewController.h"
#import "InputTableViewCell.h"
#import "SelecteTableViewCell.h"
#import "SelectItemAlertView.h"
#import "SwitchTableViewCell.h"
#import "GlobelDescAlertView.h"

@interface OtherViewController ()

@property(nonatomic,weak)IBOutlet UITableView * tableView;
@property(nonatomic,weak)IBOutlet UIButton * submit;
@property(nonatomic,strong)NSMutableArray * dataArray;

@end

@implementation OtherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.dataArray = [[NSMutableArray alloc] initWithArray:@[
        @{@"title":@"Control mode".localized,@"placeholder":@"Remote".localized},
        @{@"title":@"Load config via Bluetooth".localized,@"placeholder":@"".localized},
        @{@"title":@"Regis".localized,@"placeholder":@"Enter (number)".localized},
        @{@"title":@"Value".localized,@"placeholder":@"Enter (number)".localized},
        ]];
    [self.submit setTitle:@"Submit".localized forState:UIControlStateNormal];
    [self.submit showBorderWithRadius:25];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([InputTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([InputTableViewCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SelecteTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([SelecteTableViewCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SwitchTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([SwitchTableViewCell class])];
    if (!BleManager.shareInstance.isConnented) {
        [GlobelDescAlertView showAlertViewWithTitle:@"Tips" desc:@"Please connect the bluetooth device first" btnTitle:nil completion:nil];
        return;
    }
    if (BleManager.shareInstance.isConnented) {
        [self.view showHUDToast:@"Loading"];
    }
    __weak typeof(self) weakSelf = self;
    [BleManager.shareInstance readWithCMDString:@"512" count:1 finish:^(NSArray * _Nonnull array) {
        NSInteger idx = [array.firstObject integerValue];
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithDictionary:weakSelf.dataArray[0]];
        dict[@"placeholder"] = @[@"Local".localized,@"Remote".localized][idx];
        dict[@"value"] = [NSString stringWithFormat:@"%ld",idx];
        weakSelf.dataArray[0] = dict;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
            [weakSelf.view hiddenHUD];
        });
    }];
}

- (IBAction)submitAction:(id)sender{
    NSString * value = @"0";
    if (self.dataArray[0][@"value"]) {
        value = self.dataArray[0][@"value"];
    }
    InputTableViewCell * registerCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    InputTableViewCell * valueCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    if (!BleManager.shareInstance.isConnented) {
        [GlobelDescAlertView showAlertViewWithTitle:@"Tips" desc:@"Please connect the bluetooth device first" btnTitle:nil completion:nil];
        return;
    }
    [BleManager.shareInstance writeWithCMDString:@"600" array:@[value] finish:^{
        [RMHelper showToast:@"Write success" toView:self.view];
        [self uploadDebugConfig:@{
            @"devId":[NSUserDefaults.standardUserDefaults objectForKey:CURRENR_DEVID],
            @"formType":@"5",
            @"controlMode":value,
            @"loadConfigViaBlue":RMHelper.getLoadDataForBluetooth?@"1":@"0",
            @"register":registerCell.textfield.text,
            @"value":valueCell.textfield.text
        }];
    }];
}

- (void)uploadDebugConfig:(NSDictionary *)params{
    [Request.shareInstance postUrl:SaveDebugConfig params:params progress:^(float progress) {

    } success:^(NSDictionary * _Nonnull result) {
        BOOL value = [result[@"data"] boolValue];
        if (!value) {
            [RMHelper showToast:result[@"message"] toView:self.view];
        }
    } failure:^(NSString * _Nonnull errorMsg) {

    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        SelecteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SelecteTableViewCell class]) forIndexPath:indexPath];
        cell.titleLabel.text = self.dataArray[indexPath.row][@"title"];
        cell.content.text = self.dataArray[indexPath.row][@"placeholder"];
        cell.content.textColor = UIColor.whiteColor;
        return cell;
    }else if (indexPath.row == 1){
        SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchTableViewCell class]) forIndexPath:indexPath];
        cell.titleLabel.text = self.dataArray[indexPath.row][@"title"];
        return cell;
    }else{
        InputTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([InputTableViewCell class]) forIndexPath:indexPath];
        cell.titleLabel.text = self.dataArray[indexPath.row][@"title"];
        cell.textfield.placeholder = self.dataArray[indexPath.row][@"placeholder"];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section]];
        CGRect frame = [cell.superview convertRect:cell.frame toView:UIApplication.sharedApplication.keyWindow];
        [SelectItemAlertView showSelectItemAlertViewWithDataArray:@[@"Local".localized,@"Remote".localized] tableviewFrame:CGRectMake(SCREEN_WIDTH-100, frame.origin.y, 100, 50*2) completion:^(NSString * _Nonnull value, NSInteger idx) {
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithDictionary:self.dataArray[indexPath.row]];
            dict[@"placeholder"] = value;
            dict[@"value"] = [NSString stringWithFormat:@"%ld",idx];
            self.dataArray[indexPath.row] = dict;
            [tableView reloadData];
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
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
