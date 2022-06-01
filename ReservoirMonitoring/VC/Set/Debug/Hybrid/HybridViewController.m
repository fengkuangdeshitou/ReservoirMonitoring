//
//  HybridViewController.m
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/5/13.
//

#import "HybridViewController.h"
#import "InputTableViewCell.h"
#import "SelecteTableViewCell.h"
#import "SelectItemAlertView.h"

@interface HybridViewController ()<UITableViewDataSource>

@property(nonatomic,weak)IBOutlet UITableView * tableView;
@property(nonatomic,weak)IBOutlet UIButton * submit;
@property(nonatomic,strong)NSMutableArray * dataArray;
@property(nonatomic,assign)NSInteger count;
@property(nonatomic,assign)BOOL leftOpen;
@property(nonatomic,assign)BOOL rightOpen;
@property(nonatomic,strong)NSString * leftValue;
@property(nonatomic,strong)NSString * rightValue;
@property(nonatomic,strong)NSString * modelValue;


@end

@implementation HybridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.count = 1;
    self.leftValue = @"None".localized;
    self.rightValue = @"None".localized;
    self.modelValue = @"Quiet mode".localized;
    [self resetNumberData];
    [self.submit setTitle:@"Submit".localized forState:UIControlStateNormal];
    [self.submit showBorderWithRadius:25];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([InputTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([InputTableViewCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SelecteTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([SelecteTableViewCell class])];
}

- (void)resetNumberData{
    self.dataArray = [[NSMutableArray alloc] init];
    for (int i=0; i<self.count; i++) {
        NSDictionary * dic = @{@"title":[NSString stringWithFormat:@"Qty of Hybrid %d battery",i+1],@"placeholder":@"1"};
        [self.dataArray addObject:dic];
    }
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section <= 1) {
        if (indexPath.row == 0) {
            SelecteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SelecteTableViewCell class]) forIndexPath:indexPath];
            cell.titleLabel.text = indexPath.section == 0 ? @"Control circuit left".localized : @"Control circuit right".localized;
            cell.content.text = indexPath.section == 0 ? self.leftValue : self.rightValue;
            return cell;
        }else{
            InputTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([InputTableViewCell class]) forIndexPath:indexPath];
            cell.titleLabel.text = indexPath.row == 1 ? @"Brand".localized : @"Model".localized;
            cell.textfield.placeholder = indexPath.row == 1 ? @"Brand".localized : @"Model".localized;
            return cell;
        }
    }else if (indexPath.section == 2 || indexPath.section == 3){
        SelecteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SelecteTableViewCell class]) forIndexPath:indexPath];
        cell.titleLabel.text = indexPath.section == 2 ? @"Generator operation mode".localized : @"Qty of Hybrid".localized;
        cell.content.text = indexPath.section == 2 ? self.modelValue : [NSString stringWithFormat:@"%ld",self.count];
        return cell;
    }
    else{
        SelecteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SelecteTableViewCell class]) forIndexPath:indexPath];
        cell.titleLabel.text = self.dataArray[indexPath.row][@"title"];
        cell.content.text = self.dataArray[indexPath.row][@"placeholder"];
        return cell;
//        InputTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([InputTableViewCell class]) forIndexPath:indexPath];
//        cell.titleLabel.text = self.dataArray[indexPath.row][@"title"];
//        cell.textfield.placeholder = self.dataArray[indexPath.row][@"placeholder"];
//        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
        CGRect frame = [cell.superview convertRect:cell.frame toView:UIApplication.sharedApplication.keyWindow];
        [SelectItemAlertView showSelectItemAlertViewWithDataArray:@[@"PV inverter enabled".localized,@"EV charger enabled".localized,@"None".localized] tableviewFrame:CGRectMake(SCREEN_WIDTH-200, frame.origin.y+50, 185, 50*3) completion:^(NSString * _Nonnull value, NSInteger idx) {
            self.leftOpen = idx != 2;
            self.leftValue = value;
            [tableView reloadData];
        }];
    }else if (indexPath.section == 1){
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
        CGRect frame = [cell.superview convertRect:cell.frame toView:UIApplication.sharedApplication.keyWindow];
        [SelectItemAlertView showSelectItemAlertViewWithDataArray:@[@"Generator enabled".localized,@"None".localized] tableviewFrame:CGRectMake(SCREEN_WIDTH-200, frame.origin.y+50, 185, 50*2) completion:^(NSString * _Nonnull value, NSInteger idx) {
            self.rightOpen = idx != 1;
            self.rightValue = value;
            [tableView reloadData];
        }];
    }else if (indexPath.section == 2) {
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
        CGRect frame = [cell.superview convertRect:cell.frame toView:UIApplication.sharedApplication.keyWindow];
        [SelectItemAlertView showSelectItemAlertViewWithDataArray:@[@"Efficient mode".localized,@"Quiet mode".localized] tableviewFrame:CGRectMake(SCREEN_WIDTH-150, frame.origin.y+50, 135, 50*2) completion:^(NSString * _Nonnull value, NSInteger idx) {
            self.modelValue = value;
            [tableView reloadData];
        }];
    }
    else if (indexPath.section == 3) {
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
        CGRect frame = [cell.superview convertRect:cell.frame toView:UIApplication.sharedApplication.keyWindow];
        [SelectItemAlertView showSelectItemAlertViewWithDataArray:@[@"1",@"2",@"3",@"4",@"5",@"6"] tableviewFrame:CGRectMake(SCREEN_WIDTH-50, frame.origin.y+50, 50, 50*6) completion:^(NSString * _Nonnull value, NSInteger idx) {
            self.count = value.integerValue;
            [self resetNumberData];
        }];
    }else if (indexPath.section == 4) {
        SelecteTableViewCell * cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
        CGRect frame = [cell.superview convertRect:cell.frame toView:UIApplication.sharedApplication.keyWindow];
        [SelectItemAlertView showSelectItemAlertViewWithDataArray:@[@"1",@"2",@"3",@"4",@"5",@"6"] tableviewFrame:CGRectMake(SCREEN_WIDTH-50, frame.origin.y+50, 50, 50*6) completion:^(NSString * _Nonnull value, NSInteger idx) {
            cell.content.text = value;
        }];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return self.leftOpen ? 3 : 1;
    }else if (section == 1){
        return self.rightOpen ? 3 : 1;
    }else if (section == 2 || section == 3){
        return 1;
    }else{
        return self.dataArray.count;
    }
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
