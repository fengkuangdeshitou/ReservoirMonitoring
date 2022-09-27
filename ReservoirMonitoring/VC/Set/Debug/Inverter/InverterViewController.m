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
#import "GlobelDescAlertView.h"

@interface InverterViewController ()<UITableViewDataSource,UITextFieldDelegate,UITableViewDelegate,UINavigationBarDelegate>

@property(nonatomic,weak)IBOutlet UITableView * tableView;
@property(nonatomic,weak)IBOutlet UIButton * submit;
@property(nonatomic,weak)IBOutlet UIButton * previous;
@property(nonatomic,weak)IBOutlet UIButton * next;
@property(nonatomic,strong)NSMutableArray * dataArray;
@property(nonatomic,assign)NSInteger count;
@property(nonatomic,assign)int resNum;

@end

@implementation InverterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.count = 1;
    self.title = [NSString stringWithFormat:@"Hybrd%ld Config",self.currentIndex+1];
    [self loadRessNumber];
    [self.submit setTitle:@"Submit".localized forState:UIControlStateNormal];
    [self.previous setTitle:@"Previous".localized forState:UIControlStateNormal];
    [self.next setTitle:@"Next".localized forState:UIControlStateNormal];
    [self.submit showBorderWithRadius:25];
    [self.previous showBorderWithRadius:25];
    [self.next showBorderWithRadius:25];

    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([InputTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([InputTableViewCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SelecteTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([SelecteTableViewCell class])];
    if (!BleManager.shareInstance.isConnented) {
        [GlobelDescAlertView showAlertViewWithTitle:@"Tips" desc:@"Please connect the bluetooth device first" btnTitle:nil completion:nil];
        return;
    }
    if (BleManager.shareInstance.isConnented) {
        [self.view showHUDToast:@"Loading"];
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        [BleManager.shareInstance readWithCMDString:@"620" count:1 finish:^(NSArray * _Nonnull array) {
            weakSelf.resNum = [array.firstObject intValue] == 0 ? 1 : [array.firstObject intValue];
            dispatch_semaphore_signal(sem);
        }];
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:[weakSelf getCurrentCMDString] count:4 finish:^(NSArray * _Nonnull array) {
            [weakSelf formatArray:array];
            dispatch_semaphore_signal(sem);
        }];
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:[NSString stringWithFormat:@"%ld",634+weakSelf.currentIndex] count:1 finish:^(NSArray * _Nonnull array) {
            weakSelf.count = [array.firstObject integerValue] == 0 ? 1 : [array.firstObject integerValue];
            dispatch_semaphore_signal(sem);
        }];

        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.submit.hidden = false;
            [weakSelf.next setTitle:weakSelf.currentIndex==weakSelf.resNum-1?@"Finishi".localized:@"Next".localized forState:UIControlStateNormal];
            [weakSelf.view hiddenHUD];
            [weakSelf.tableView reloadData];
        });
    });
}

- (void)backView{
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_RESS_NOTIFICATION object:nil];
}

- (NSString *)getCurrentCMDString{
    NSString * string = @"";
    if (self.currentIndex == 0) {
        string = @"629";
    }else if (self.currentIndex == 1){
        string = @"63A";
    }else if (self.currentIndex == 2){
        string = @"63B";
    }else if (self.currentIndex == 3){
        string = @"63C";
    }else if (self.currentIndex == 4){
        string = @"63D";
    }else if (self.currentIndex == 5){
        string = @"63E";
    }
    return string;
}

- (void)formatArray:(NSArray *)array{
    if (array) {
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableDictionary * item = [[NSMutableDictionary alloc] initWithDictionary:self.dataArray[idx]];
            if (idx == 0) {
                item[@"value"] = [NSString stringWithFormat:@"%.1f",[obj floatValue]/10];
                [self.dataArray replaceObjectAtIndex:0 withObject:item];
            }else if (idx == 1) {
                item[@"value"] = [NSString stringWithFormat:@"%.1f",[obj floatValue]/10];;
                [self.dataArray replaceObjectAtIndex:1 withObject:item];
            }else if (idx == 2) {
                item[@"value"] = [NSString stringWithFormat:@"%.1f",[obj floatValue]/10];;
                [self.dataArray replaceObjectAtIndex:2 withObject:item];
            }else if (idx == 3) {
                item[@"value"] = [NSString stringWithFormat:@"%.1f",[obj floatValue]/10];;
                [self.dataArray replaceObjectAtIndex:3 withObject:item];
            }
        }];
    }
}

- (void)loadRessNumber{
    NSArray * array = @[
        @{@"title":[NSString stringWithFormat:@"Hybrid%ld PV1 voltage",self.currentIndex+1],@"placeholder":@"Enter (number)".localized,@"value":@"0"},
        @{@"title":[NSString stringWithFormat:@"Hybrid%ld PV2 voltage",self.currentIndex+1],@"placeholder":@"Enter (number)".localized,@"value":@"0"},
        @{@"title":[NSString stringWithFormat:@"Hybrid%ld PV3 voltage",self.currentIndex+1],@"placeholder":@"Enter (number)".localized,@"value":@"0"},
        @{@"title":[NSString stringWithFormat:@"Hybrid%ld PV4 voltage",self.currentIndex+1],@"placeholder":@"Enter (number)".localized,@"value":@"0"}
    ];
    self.dataArray = [[NSMutableArray alloc] initWithArray:array];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    InputTableViewCell * cell = (InputTableViewCell *)[[[textField superview] superview] superview];
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    NSMutableDictionary * item = [[NSMutableDictionary alloc] initWithDictionary:self.dataArray[indexPath.row]];
    item[@"value"] = textField.text;
    [self.dataArray replaceObjectAtIndex:indexPath.row withObject:item];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField.text containsString:@"."] && [string isEqualToString:@"."]) {
        return NO;
    }
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];

    NSArray *sep = [newString componentsSeparatedByString:@"."];
    if([sep count] >= 2)
    {
        NSString *sepStr=[NSString stringWithFormat:@"%@",[sep objectAtIndex:1]];
        return !([sepStr length]>1);
    }
    return YES;
}

- (NSString *)getInputTextWithRow:(NSInteger)row{
    InputTableViewCell * cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    return cell.textfield.text;
}

- (InputTableViewCell *)getCellWithRow:(NSInteger)row section:(NSInteger)section{
    return [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
}

- (IBAction)previousAction:(id)sender{
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)nextAction:(id)sender{
    if (self.resNum == 0){
        [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_RESS_NOTIFICATION object:nil];
        return;
    }
    if (self.currentIndex == self.resNum-1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_RESS_NOTIFICATION object:nil];
    }else{
        InverterViewController * inverter = [[InverterViewController alloc] init];
        inverter.currentIndex = self.currentIndex+1;
        inverter.title = self.title;
        [self.navigationController pushViewController:inverter animated:true];
    }
}

- (IBAction)submitAction:(id)sender{
    [self.view endEditing:true];
    if (!BleManager.shareInstance.isConnented) {
        [GlobelDescAlertView showAlertViewWithTitle:@"Tips" desc:@"Please connect the bluetooth device first" btnTitle:nil completion:nil];
        return;
    }
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
    [params setValue:[NSUserDefaults.standardUserDefaults objectForKey:CURRENR_DEVID] forKey:@"devId"];
    [params setValue:@"3" forKey:@"formType"];
    NSMutableArray * valueArray = [[NSMutableArray alloc] init];
    for (int i=0; i<self.dataArray.count; i++) {
        NSString * key = [NSString stringWithFormat:@"hybrid%ldPV%dVoltage",self.currentIndex+1,i+1];
        NSString * value = [NSString stringWithFormat:@"%.1f",[self.dataArray[i][@"value"] floatValue]*10];
        NSLog(@"value=%@,key=%@",value,key);
        [params setValue:value forKey:key];
        [valueArray addObject:value];
    }
    NSLog(@"valueArray=%@",valueArray);
    __weak typeof(self) weakSelf = self;
    if (BleManager.shareInstance.isConnented) {
        [UIApplication.sharedApplication.keyWindow showHUDToast:@"Loading"];
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        [BleManager.shareInstance writeWithCMDString:@"651" array:@[[NSString stringWithFormat:@"%ld",weakSelf.currentIndex]] finish:^{
            dispatch_semaphore_signal(sem);
        }];
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"652" count:1 finish:^(NSArray * _Nonnull array) {
            NSInteger index = [array.firstObject integerValue];
            NSString * string = @"";
            if (index == 0) {
                string = @"未开始";
            }else if (index == 1){
                string = @"正在设置";
            }else if (index == 2){
                string = @"设置成功";
                dispatch_semaphore_signal(sem);
            }else if (index == 3){
                string = @"设置失败";
                [RMHelper showToast:@"Failure" toView:weakSelf.view];
            }
        }];
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance writeWithCMDString:[NSString stringWithFormat:@"%ld",634+weakSelf.currentIndex] array:@[[NSString stringWithFormat:@"%ld",weakSelf.count]] finish:^{
            dispatch_semaphore_signal(sem);
        }];
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance writeWithCMDString:[weakSelf getCurrentCMDString] array:valueArray finish:^{
            dispatch_async(dispatch_get_main_queue(), ^{
//                [weakSelf uploadDebugConfig:params];
                [RMHelper showToast:@"Success" toView:weakSelf.view];
            });
            dispatch_semaphore_signal(sem);
        }];
    });
}

- (void)uploadDebugConfig:(NSDictionary *)params{
    [Request.shareInstance postUrl:SaveDebugConfig params:params progress:^(float progress) {

    } success:^(NSDictionary * _Nonnull result) {
        BOOL value = [result[@"data"] boolValue];
        if (!value) {
            [RMHelper showToast:result[@"message"] toView:self.view];
        }else{
            [RMHelper showToast:@"Success" toView:self.view];
        }
    } failure:^(NSString * _Nonnull errorMsg) {

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
        UIView * view = [cell.contentView viewWithTag:10];
        view.backgroundColor = [UIColor colorWithHexString:@"#1B1B1B"];
        cell.titleLabel.text = self.dataArray[indexPath.row][@"title"];
        cell.textfield.placeholder = self.dataArray[indexPath.row][@"placeholder"];
        cell.textfield.text = self.dataArray[indexPath.row][@"value"];
        cell.textfield.delegate = self;
        cell.textfield.keyboardType = UIKeyboardTypeDecimalPad;
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
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView * header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    header.backgroundColor = UIColor.clearColor;
    UILabel * titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, SCREEN_WIDTH-100, header.height)];
    titlelabel.text = [NSString stringWithFormat:@"Qty of Hybrid%ld battery",self.currentIndex+1];
    titlelabel.font = [UIFont systemFontOfSize:14];
    titlelabel.textColor = UIColor.whiteColor;
    [header addSubview:titlelabel];
    
    UILabel * index = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-20-10-15, 0, 20, header.height)];
    index.text = [NSString stringWithFormat:@"%ld",self.count];
    index.font = [UIFont systemFontOfSize:14];
    index.textColor = [UIColor colorWithHexString:@"#999999"];
    [header addSubview:index];
    
    UIImageView * icon = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-10-15, (50-7)/2, 10, 7)];
    icon.image = [UIImage imageNamed:@"ic_down"];
    [header addSubview:icon];
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = header.bounds;
    [btn addTarget:self action:@selector(selectCount) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:btn];
    
    return header;
}

- (void)selectCount{
    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    CGRect frame = [cell.superview convertRect:cell.frame toView:UIApplication.sharedApplication.keyWindow];
    [SelectItemAlertView showSelectItemAlertViewWithDataArray:@[@"1",@"2",@"3",@"4",@"5",@"6"] tableviewFrame:CGRectMake(SCREEN_WIDTH-50, frame.origin.y, 50, 50*6) completion:^(NSString * _Nonnull value, NSInteger idx) {
        self.count = [value integerValue];
        [self.tableView reloadData];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 15;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 15)];
    view.backgroundColor = [UIColor colorWithHexString:@"#0c0c0c"];
    return view;
}

- (void)dealloc{
    
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
