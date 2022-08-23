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
@property(nonatomic,strong) NSMutableArray * indexArray;

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
    [self.view endEditing:true];
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
    self.indexArray = [[NSMutableArray alloc] init];
    NSMutableArray * array = [[NSMutableArray alloc] init];
    [array addObject:self.sgSn];
    [array addObjectsFromArray:self.dataArray];
    NSLog(@"arr=%@",array);
    for (int i=0; i<array.count-1; i++) {
        NSString * current = array[i];
        for (int j=i+1; j<array.count; j++) {
            NSString * next = array[j];
            NSLog(@"current=%@,next=%@",current,next);
            if ([current isEqualToString:next]) {
                if (![self.indexArray containsObject:@(i)]) {
                    [self.indexArray addObject:@(i)];
                }
                if (![self.indexArray containsObject:@(j)]) {
                    [self.indexArray addObject:@(j)];
                }
            }
        }
    }
    if (self.indexArray.count > 0) {
        self.indexArray = [[NSMutableArray alloc] initWithArray:[self.indexArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            if ([obj1 integerValue] > [obj2 integerValue]) {
                return NSOrderedDescending;
            }else if ([obj1 integerValue] < [obj2 integerValue]){
                return NSOrderedAscending;
            }else{
                return NSOrderedSame;
            }
        }]];
        [self.tableView reloadData];
        [RMHelper showToast:@"Accessory Hybrid SN repeats, please check again." toView:self.view];
        return;
    }else{
        [self.tableView reloadData];
    }
    [Request.shareInstance postUrl:CheckSn params:@{@"sgSn":self.sgSn,@"snItems":self.dataArray} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        NSDictionary * data = result[@"data"];
        if ([data[@"status"] intValue] == 200) {
            [self nextAction];
        }else{
            if (data[@"snItem"]) {
                id snItem = data[@"snItem"];
                NSArray * items = @[];
                if ([snItem isKindOfClass:[NSString class]]) {
                    items = @[snItem];
                }else if ([snItem isKindOfClass:[NSArray class]]){
                    items = snItem;
                }
                for (int i=0; i<array.count; i++) {
                    NSString * sn = array[i];
                    if ([items containsObject:sn]) {
                        [self.indexArray addObject:@(i)];
                    }
                }
            }else{
                [self.indexArray addObject:@(0)];
            }
            [self.tableView reloadData];
            [RMHelper showToast:data[@"msg"] toView:self.view];
        }
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
}

- (void)nextAction{
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
    address.snItems = [self.dataArray componentsJoinedByString:@","];
    [self.navigationController pushViewController:address animated:true];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField.tag == 1) {
        self.sgSn = textField.text;
    }else if (textField.tag == 2){
        self.name = textField.text;
    }else if (textField.tag == 10) {
        self.inverteSN = textField.text;
        [self.dataArray replaceObjectAtIndex:0 withObject:textField.text];
    }else if (textField.tag == 11){
        self.batterySN = textField.text;
        [self.dataArray replaceObjectAtIndex:1 withObject:textField.text];
    }else{
        [self.dataArray replaceObjectAtIndex:textField.tag-10 withObject:textField.text];
    }
}

- (void)inverteScanFinish{
    ScanViewController * scan = [[ScanViewController alloc] init];
    scan.scanCode = ^(NSString * _Nonnull code) {
        AddDeviceTableViewCell * cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        cell.idtextfield.text = code;
        self.sgSn = code;
    };
    [RMHelper.getCurrentVC.navigationController pushViewController:scan animated:true];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        AddDeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([AddDeviceTableViewCell class]) forIndexPath:indexPath];
        cell.idtextfield.delegate = self;
        cell.idtextfield.tag = 1;
        cell.nametextfield.delegate = self;
        cell.nametextfield.tag = 2;
        cell.idtextfield.text = self.sgSn;
        cell.nametextfield.text = self.name;
        [cell.scanBtn addTarget:self action:@selector(inverteScanFinish) forControlEvents:UIControlEventTouchUpInside];
        if ([self.indexArray containsObject:@(0)]) {
            cell.line.hidden = false;
        }else{
            cell.line.hidden = true;
        }
        return cell;
    }else{
        if (indexPath.row == self.dataArray.count) {
            AddDeviceActionTableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([AddDeviceActionTableViewCell class]) forIndexPath:indexPath];
            [cell.addButton addTarget:self action:@selector(addDeviceAction) forControlEvents:UIControlEventTouchUpInside];
            return cell;
        }else{
            AddDeviceSNTableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([AddDeviceSNTableViewCell class]) forIndexPath:indexPath];
            if (indexPath.row == 0 || indexPath.row == 1) {
                cell.textfield.placeholder = indexPath.row == 0 ? @"Please input inverte SN".localized : @"Please input battery/base SN".localized;
                cell.textfield.tag = indexPath.row + 10;
                cell.textfield.delegate = self;
                cell.label.hidden = false;
                cell.deleteBtnWidth.constant = 0;
                cell.deleteBtnLeft.constant = 0;
            }else{
                cell.textfield.placeholder = @"Please input battery/base SN".localized;
                cell.deleteBtm.tag = indexPath.row+10;
                cell.textfield.tag = indexPath.row + 10;
                cell.textfield.delegate = self;
                cell.label.hidden = true;
                cell.deleteBtnWidth.constant = 22;
                cell.deleteBtnLeft.constant = 30;
            }
            [cell.deleteBtm addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.scanBtn addTarget:self action:@selector(scanAction:) forControlEvents:UIControlEventTouchUpInside];
            cell.textfield.text = self.dataArray[indexPath.row];
            if ([self.indexArray containsObject:@(indexPath.row+1)]) {
                cell.line.hidden = false;
                cell.line.backgroundColor = UIColor.redColor;
            }else{
                cell.line.backgroundColor = [UIColor colorWithHexString:@"#333333"];
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
        if (cell.textfield.tag == 10) {
            self.inverteSN = code;
            [self.dataArray replaceObjectAtIndex:0 withObject:code];
        }else if (cell.textfield.tag == 11){
            self.batterySN = code;
            [self.dataArray replaceObjectAtIndex:1 withObject:code];
        }else{
            [self.dataArray replaceObjectAtIndex:cell.textfield.tag-10 withObject:code];
        }
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
    title.text = section == 0 ? @"Smart Gateway info".localized : @"Hybrid info".localized;
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
