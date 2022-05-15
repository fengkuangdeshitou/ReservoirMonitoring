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

@interface AddDeviceViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,weak)IBOutlet UITableView * tableView;
@property(nonatomic,weak)IBOutlet UIButton * next;
@property(nonatomic,strong) NSMutableArray * dataArray;

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
    AddAddressViewController * address = [[AddAddressViewController alloc] init];
    address.title = @"Device location".localized;
    [self.navigationController pushViewController:address animated:true];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        AddDeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([AddDeviceTableViewCell class]) forIndexPath:indexPath];
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
            }else{
                cell.scanBtn.hidden = false;
                cell.textfield.placeholder = @"Please inpute battery module SN".localized;
                [cell.scanBtn setImage:[UIImage imageNamed:@"ic_set_scan"] forState:UIControlStateNormal];
                [cell.deleteBtm setImage:[UIImage imageNamed:@"ic_delete"] forState:UIControlStateNormal];
                cell.deleteBtm.tag = indexPath.row+10;
                [cell.deleteBtm addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
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
    title.text = @"Accessory Hybrid info".localized;
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
