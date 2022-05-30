//
//  InverterViewController.m
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/5/13.
//

#import "InverterViewController.h"
#import "InputTableViewCell.h"
#import "SelecteTableViewCell.h"
#import "SelectItemAlertView.h"

@interface InverterViewController ()

@property(nonatomic,weak)IBOutlet UITableView * tableView;
@property(nonatomic,weak)IBOutlet UIButton * submit;
@property(nonatomic,strong)NSMutableArray * dataArray;

@end

@implementation InverterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.dataArray = [[NSMutableArray alloc] initWithArray:@[
        @{@"title":@"PV1 voltage".localized,@"placeholder":@"PV1 voltage".localized},
        @{@"title":@"PV2 voltage".localized,@"placeholder":@"PV2 voltage".localized},
        @{@"title":@"PV3 voltage".localized,@"placeholder":@"PV3 voltage".localized},
        @{@"title":@"PV4 voltage".localized,@"placeholder":@"PV4 voltage".localized},
        @{@"title":@"PV inverter/EV status".localized,@"placeholder":@"None".localized},
        @{@"title":@"PV inverter/EV brand".localized,@"placeholder":@"PV inverter/EV brand".localized},
        @{@"title":@"PV inverter/EV model".localized,@"placeholder":@"PV inverter/EV model".localized},
        ]];
    [self.submit setTitle:@"Submit".localized forState:UIControlStateNormal];
    [self.submit showBorderWithRadius:25];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([InputTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([InputTableViewCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SelecteTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([SelecteTableViewCell class])];
    [BleManager.shareInstance readWithCMDString:@"629" count:7 finish:^(NSArray * _Nonnull array) {
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"arr=%@",obj);
            if (idx == 0 && [obj intValue] > 0) {
                [self getCellWithRow:idx].textfield.text = obj;
            }else if (idx == 1 && [obj intValue] > 0) {
                [self getCellWithRow:idx].textfield.text = obj;
            }else if (idx == 2 && [obj intValue] > 0) {
                [self getCellWithRow:idx].textfield.text = obj;
            }else if (idx == 3 && [obj intValue] > 0) {
                [self getCellWithRow:idx].textfield.text = obj;
            }else if (idx == 4) {
                SelecteTableViewCell * cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
                NSInteger index = [array.firstObject intValue];
                cell.content.text = @[@"PV inverter enabled".localized,@"EV charger enabled".localized,@"None".localized][index];
            }else if (idx == 5 && [obj intValue] > 0) {
                [self getCellWithRow:idx].textfield.text = obj;
            }else if (idx == 6 && [obj intValue] > 0) {
                [self getCellWithRow:idx].textfield.text = obj;
            }
        }];
    }];
}

- (NSString *)getInputTextWithRow:(NSInteger)row{
    InputTableViewCell * cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    return cell.textfield.text;
}

- (InputTableViewCell *)getCellWithRow:(NSInteger)row{
    return [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
}

- (IBAction)submitAction:(id)sender{
    [BleManager.shareInstance writeWithCMDString:@"629" array:@[[self getInputTextWithRow:0],[self getInputTextWithRow:1],[self getInputTextWithRow:2],[self getInputTextWithRow:3],self.dataArray[4][@"value"],[self getInputTextWithRow:5],[self getInputTextWithRow:6]] finish:^{
        NSLog(@"成功");
        [RMHelper showToast:@"Write success" toView:self.view];
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 4) {
        SelecteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SelecteTableViewCell class]) forIndexPath:indexPath];
        cell.titleLabel.text = self.dataArray[indexPath.row][@"title"];
        cell.content.text = self.dataArray[indexPath.row][@"placeholder"];
        return cell;
    }else{
        InputTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([InputTableViewCell class]) forIndexPath:indexPath];
        cell.titleLabel.text = self.dataArray[indexPath.row][@"title"];
        cell.textfield.placeholder = self.dataArray[indexPath.row][@"placeholder"];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 4) {
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section]];
        CGRect frame = [cell.superview convertRect:cell.frame toView:UIApplication.sharedApplication.keyWindow];
        [SelectItemAlertView showSelectItemAlertViewWithDataArray:@[@"PV inverter enabled".localized,@"EV charger enabled".localized,@"None".localized] tableviewFrame:CGRectMake(SCREEN_WIDTH-200, frame.origin.y, 200, 50*3) completion:^(NSString * _Nonnull value, NSInteger idx) {
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
