//
//  AddDeviceViewController.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/19.
//

#import "AddDeviceViewController.h"
#import "AddDeviceTableViewCell.h"
#import "AddDeviceSNTableViewCell.h"
#import "AddDeviceActionTableViewCell.h"
#import "AddAddressViewController.h"
#import "ScanViewController.h"

@interface AddDeviceViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property(nonatomic,weak)IBOutlet UITableView * tableView;
@property(nonatomic,weak)IBOutlet UIButton * next;
@property(nonatomic,strong) NSMutableArray * dataArray;
@property(nonatomic,strong) NSString * sgSn;
@property(nonatomic,strong) NSString * name;
@property(nonatomic,strong) NSString * addressIds;
@property(nonatomic,strong) NSString * devId;
@property(nonatomic,strong) NSString * inverteSN;
@property(nonatomic,strong) NSString * batterySN;

@end

@implementation AddDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.dataArray = [[NSMutableArray alloc] init];
    [self.dataArray addObject:@""];
    [self.dataArray addObject:@""];

    [self.next showBorderWithRadius:25];
    [self.next setTitle:@"Next".localized forState:UIControlStateNormal];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([AddDeviceTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([AddDeviceTableViewCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([AddDeviceSNTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([AddDeviceSNTableViewCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([AddDeviceActionTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([AddDeviceActionTableViewCell class])];
    
}

- (IBAction)nextAction:(id)sender{
    if (!self.sgSn) {
        [RMHelper showToast:@"Please input device SN".localized toView:self.view];
        return;
    }
    if (!self.name) {
        [RMHelper showToast:@"Please input name for this device" toView:self.view];
        return;
    }
    if (!self.inverteSN) {
        [RMHelper showToast:@"please input inverter SN" toView:self.view];
        return;
    }
    if (!self.batterySN) {
        [RMHelper showToast:@"please input battery SN" toView:self.view];
        return;
    }
    [Request.shareInstance getUrl:ScanSgsn params:@{@"sgSn":self.sgSn} progress:^(float progress) {

    } success:^(NSDictionary * _Nonnull result) {
        self.sgSn = result[@"data"][@"sgSn"];
        self.addressIds = result[@"data"][@"addressIds"];
        self.devId = result[@"data"][@"id"];
        [self pushViewControler];
    } failure:^(NSString * _Nonnull errorMsg) {

    }];
}

- (void)pushViewControler{
    AddAddressViewController * address = [[AddAddressViewController alloc] init];
    address.title = @"Device location".localized;
//    address.addressIds = @"140,356";
//    address.devId = @"39";

    address.sgSn = self.sgSn;
    address.addressIds = self.addressIds;
    address.devId = self.devId;
    address.name = self.name;
    address.inverteSN = self.inverteSN;
    address.batterySN = self.batterySN;
    NSMutableArray * array = [[NSMutableArray alloc] init];
    for (int i=0; i<self.dataArray.count; i++) {
        AddDeviceSNTableViewCell * cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]];
        [array addObject:cell.textfield.text];
    }
    address.snItems = [array componentsJoinedByString:@","];
    [self.navigationController pushViewController:address animated:true];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField.tag == 1) {
        self.sgSn = textField.text;
    }else if (textField.tag == 2){
        self.name = textField.text;
    }else if (textField.tag == 10) {
        self.inverteSN = textField.text;
    }else if (textField.tag == 11){
        self.batterySN = textField.text;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        AddDeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([AddDeviceTableViewCell class]) forIndexPath:indexPath];
        cell.idtextfield.delegate = self;
        cell.idtextfield.tag = 1;
        cell.nametextfield.delegate = self;
        cell.nametextfield.tag = 2;
        cell.nametextfield.text = @"";
        return cell;
    }else{
        if (indexPath.row == self.dataArray.count) {
            AddDeviceActionTableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([AddDeviceActionTableViewCell class]) forIndexPath:indexPath];
            [cell.addButton addTarget:self action:@selector(addDeviceAction) forControlEvents:UIControlEventTouchUpInside];
            return cell;
        }else{
            AddDeviceSNTableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([AddDeviceSNTableViewCell class]) forIndexPath:indexPath];
            if (indexPath.row == 0) {
                cell.scanBtn.hidden = true;
                [cell.deleteBtm setImage:[UIImage imageNamed:@"ic_set_scan"] forState:UIControlStateNormal];
                cell.textfield.placeholder = @"Please input inverte SN".localized;
                [cell.deleteBtm addTarget:self action:@selector(scanAction:) forControlEvents:UIControlEventTouchUpInside];
                cell.textfield.tag = indexPath.row + 10;
                cell.textfield.delegate = self;
            }else{
                cell.scanBtn.hidden = false;
                cell.textfield.placeholder = @"Please inpute battery SN".localized;
                [cell.scanBtn setImage:[UIImage imageNamed:@"ic_set_scan"] forState:UIControlStateNormal];
                [cell.deleteBtm setImage:[UIImage imageNamed:@"ic_delete"] forState:UIControlStateNormal];
                cell.deleteBtm.tag = indexPath.row+10;
                [cell.deleteBtm addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
                [cell.scanBtn addTarget:self action:@selector(scanAction:) forControlEvents:UIControlEventTouchUpInside];
                cell.textfield.tag = indexPath.row + 10;
                cell.textfield.delegate = self;
            }
            return cell;
        }
    }
}

- (void)deleteAction:(UIButton *)btn{
    [self.dataArray removeObjectAtIndex:btn.tag-10];
    [self.tableView reloadData];
}

- (void)addDeviceAction{
    [self.dataArray addObject:@""];
    [self.tableView reloadData];
}

- (void)scanAction:(UIButton *)btn{
    AddDeviceSNTableViewCell * cell = (AddDeviceSNTableViewCell *)[[[btn superview] superview] superview];
    ScanViewController * scan = [[ScanViewController alloc] init];
    scan.scanCode = ^(NSString * _Nonnull code) {
        cell.textfield.text = code;
    };
    [self.navigationController pushViewController:scan animated:true];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section == 0 ? 1 : self.dataArray.count+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return UITableViewAutomaticDimension;
    }else{
        return self.dataArray.count == indexPath.row ? 58 : 50;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section == 1 ? 50 : 0.001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView * header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    header.backgroundColor = UIColor.clearColor;
    UILabel * title = [[UILabel alloc] init];
    [header addSubview:title];
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(section == 0 ? 15 : 30);
            make.top.bottom.mas_equalTo(0);
    }];
    title.text = section == 0 ? @"Smart Gateway info".localized : @"Accessory Hybrid info".localized;
    title.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
    title.textColor = UIColor.whiteColor;
    return header;
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
