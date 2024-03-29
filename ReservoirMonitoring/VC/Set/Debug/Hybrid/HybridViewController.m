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
@import BRPickerView;
#import "GlobelDescAlertView.h"

@interface HybridViewController ()<UITableViewDataSource,UITextFieldDelegate>

@property(nonatomic,weak)IBOutlet UITableView * tableView;
@property(nonatomic,weak)IBOutlet UIButton * submit;
@property(nonatomic,strong)NSMutableArray * dataArray;
@property(nonatomic,strong)NSString * systemTime;
@property(nonatomic,strong)NSString * stop;
@property(nonatomic,assign)int count;
@property(nonatomic,assign)BOOL leftOpen;
@property(nonatomic,assign)BOOL rightOpen;
@property(nonatomic,strong)NSString * leftValue;
@property(nonatomic,strong)NSString * rightValue;
@property(nonatomic,strong)NSString * leftController;
@property(nonatomic,strong)NSString * rightController;
@property(nonatomic,strong)NSString * modelValue;
@property(nonatomic,strong)NSArray<NSString*> * leftValueArray;
@property(nonatomic,strong)NSArray<NSString*> * rightValueArray;
@property(nonatomic,strong)BRPickerStyle * style;

@end

@implementation HybridViewController

- (BRPickerStyle *)style{
    if (!_style) {
        _style = [[BRPickerStyle alloc] init];
        _style.alertViewColor = [UIColor.blackColor colorWithAlphaComponent:0.7];
        _style.maskColor = [UIColor.blackColor colorWithAlphaComponent:0.7];
        _style.pickerColor = [UIColor colorWithHexString:COLOR_BACK_COLOR];
        _style.doneTextColor = [UIColor colorWithHexString:COLOR_MAIN_COLOR];
        _style.cancelTextColor = [UIColor colorWithHexString:@"#999999"];
        _style.titleBarColor = [UIColor colorWithHexString:COLOR_BACK_COLOR];
        _style.selectRowColor = UIColor.clearColor;
        _style.pickerTextColor = [UIColor colorWithHexString:@"#F6F6F6"];
        _style.titleLineColor = [UIColor colorWithHexString:@"#333333"];
        _style.doneBtnTitle = @"OK".localized;
        _style.cancelBtnTitle = @"Cancel".localized;
    }
    return _style;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self resetNumberData];
    self.leftValue = @"None";
    self.rightValue = @"None";
    self.leftValueArray = @[@"",@""];
    self.rightValueArray = @[@"",@""];
    self.modelValue = @"Efficient mode";
    self.count = 1;
    [self.submit setTitle:@"Submit".localized forState:UIControlStateNormal];
    [self.submit showBorderWithRadius:25];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([InputTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([InputTableViewCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SelecteTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([SelecteTableViewCell class])];
    if (!BleManager.shareInstance.isConnented) {
        [GlobelDescAlertView showAlertViewWithTitle:@"Tips" desc:@"Please connect the bluetooth device first" btnTitle:nil completion:nil];
        return;
    }
    if (BleManager.shareInstance.isConnented) {
        [UIApplication.sharedApplication.keyWindow showHUDToast:@"Loading"];
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [BleManager.shareInstance readWithCMDString:@"611" count:6 finish:^(NSArray * _Nonnull array) {
            if (array.count == 6) {
                weakSelf.systemTime = [NSString stringWithFormat:@"%@-%02d-%02d %02d:%02d:%02d",array[0],[array[1] intValue],[array[2] intValue],[array[3] intValue],[array[4] intValue],[array[5] intValue]];
            }
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"64F" count:1 finish:^(NSArray * _Nonnull array) {
            weakSelf.stop = array.firstObject;
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"62D" count:3 finish:^(NSArray * _Nonnull array) {
            NSLog(@"62d=%@",array);
            weakSelf.leftOpen = [array.firstObject intValue] != 0;
            weakSelf.leftController = [NSString stringWithFormat:@"%@",array.firstObject];
            int index = 0;
            if ([array.firstObject intValue]<3){
                index = [array.firstObject intValue]-1;
            }
            weakSelf.leftValue = !weakSelf.leftOpen ? @"None".localized : @[@"PV inverter enabled".localized,@"EV charger enabled".localized][index];
            if (weakSelf.leftOpen) {
                weakSelf.leftValueArray = @[array[1],array[2]];
            }
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"630" count:3 finish:^(NSArray * _Nonnull array) {
            weakSelf.rightOpen = [array.firstObject intValue] != 0;
            weakSelf.rightController = [NSString stringWithFormat:@"%@",array.firstObject];
            if (weakSelf.rightOpen) {
                weakSelf.rightValueArray = @[array[1],array[2]];
            }
            if ([array.firstObject intValue] == 0) {
                weakSelf.rightValue = @"None".localized;
            }else{
                int index = 0;
                if ([array.firstObject intValue]<4){
                    index = [array.firstObject intValue]-1;
                }
                weakSelf.rightValue = @[@"Generator enabled".localized,@"EV charger enabled",@"PV inverter enabled",@"None".localized][index];
            }
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"633" count:1 finish:^(NSArray * _Nonnull array) {
            NSInteger inx = [array.firstObject intValue] < 3 ? [array.firstObject intValue] : 1;
            if (inx == 0) {
                weakSelf.modelValue = @"Efficient mode".localized;
            }else{
                weakSelf.modelValue = @[@"Efficient mode".localized,@"Quiet mode".localized][inx-1];
            }
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"620" count:1 finish:^(NSArray * _Nonnull array) {
            int inx = [array.firstObject intValue];
            weakSelf.count = inx;
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"634" count:weakSelf.count finish:^(NSArray * _Nonnull array) {
            weakSelf.dataArray = [[NSMutableArray alloc] init];
            for (int i=0; i<array.count; i++) {
                int value = [array[i] intValue];
                NSDictionary * dic = @{@"title":[NSString stringWithFormat:@"Qty of Hybrid %d battery",i+1],@"placeholder":[NSString stringWithFormat:@"%d",value]};
                [weakSelf.dataArray addObject:dic];
            }
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
            [UIApplication.sharedApplication.keyWindow hiddenHUD];
            dispatch_semaphore_signal(semaphore);
        });
    });
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    InputTableViewCell * cell = (InputTableViewCell *)[[[textField superview] superview] superview];
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath.section == 1){
        NSArray * left = self.leftValueArray ?:@[@"",@""];
        if ( indexPath.row == 1) {
            self.leftValueArray = @[textField.text,left[1]];
        }else{
            self.leftValueArray = @[left[0],textField.text];
        }
    }else if(indexPath.section == 2){
        NSArray * right = self.rightValueArray ?: @[@"",@""];
        if (indexPath.row == 1) {
            self.rightValueArray = @[textField.text,right[1]];
        }else{
            self.rightValueArray = @[right[0],textField.text];
        }
    }
}

- (IBAction)submitAction:(id)sender{
    if (!BleManager.shareInstance.isConnented) {
        [GlobelDescAlertView showAlertViewWithTitle:@"Tips" desc:@"Please connect the bluetooth device first" btnTitle:nil completion:nil];
        return;
    }
    if (!self.systemTime) {
        [RMHelper showToast:@"Please select a time" toView:self.view];
        return;
    }
    if (self.systemTime.length != 19){
        [RMHelper showToast:@"Please select the time in the correct format" toView:self.view];
        return;
    }
    NSArray * leftArray = @[];
    if (self.leftOpen) {
        if (self.leftValueArray[0].length == 0 || self.leftValueArray[1].length == 0) {
            [RMHelper showToast:@"Enter(number)" toView:self.view];
            return;
        }
        leftArray = @[self.leftController,self.leftValueArray[0],self.leftValueArray[1]];
    }

    NSArray * rightArray = @[];
    if (self.rightOpen) {
        if (self.rightValueArray[0].length == 0 || self.rightValueArray[1].length == 0) {
            [RMHelper showToast:@"Enter(number)" toView:self.view];
            return;
        }
        rightArray = @[self.rightController,self.rightValueArray[0],self.rightValueArray[1]];
    }
    
    SelecteTableViewCell * hybrid = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:4]];
    if (hybrid.content.text.intValue == 0) {
        [RMHelper showToast:@"Please select Qry number" toView:self.view];
        return;
    }
    
    NSArray * countArray = @[hybrid.content.text];
//    NSMutableArray * array = [[NSMutableArray alloc] init];
//    for (int i=0; i<hybrid.content.text.intValue; i++) {
//        SelecteTableViewCell * cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:5]];
//        [array addObject:cell.content.text];
//    }
    __weak typeof(self) weakSelf = self;
    if (BleManager.shareInstance.isConnented) {
        [UIApplication.sharedApplication.keyWindow showHUDToast:@"Loading"];
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        NSString * time = weakSelf.systemTime;
        NSString * ymdTime = [time componentsSeparatedByString:@" "].firstObject;
        NSString * hmsTime = [time componentsSeparatedByString:@" "].lastObject;
        NSArray * ymdArray = [ymdTime componentsSeparatedByString:@"-"];
        NSArray * hmsArray = [hmsTime componentsSeparatedByString:@":"];
        NSArray * timeArray = @[ymdArray[0],ymdArray[1],ymdArray[2],hmsArray[0],hmsArray[1],hmsArray[2]];
        [BleManager.shareInstance writeWithCMDString:@"611" array:timeArray finish:^{
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance writeWithCMDString:@"64F" array:weakSelf.stop?@[weakSelf.stop]:@[@"0"] finish:^{
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance writeWithCMDString:@"62D" array:weakSelf.leftOpen ? leftArray : @[@"0"] finish:^{
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance writeWithCMDString:@"630" array:weakSelf.rightOpen ? rightArray : @[@"0"] finish:^{
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSString * modelValue = [weakSelf.modelValue isEqualToString:@"Efficient mode".localized] ? @"1" : @"2";
        [BleManager.shareInstance writeWithCMDString:@"633" array:@[modelValue] finish:^{
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance writeWithCMDString:@"620" array:countArray finish:^{

//        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//        [BleManager.shareInstance writeWithCMDString:@"634" array:array finish:^{
            dispatch_semaphore_signal(semaphore);
            dispatch_async(dispatch_get_main_queue(), ^{
                NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
                NSDictionary * item = @{
                    @"devId":[NSUserDefaults.standardUserDefaults objectForKey:CURRENR_DEVID],
                    @"formType":@"2",
                    @"systemTime":weakSelf.systemTime,
                    @"estop":weakSelf.stop?:@"0",
                    @"controlCircuitLeft":weakSelf.leftController,
                    @"lbrand":weakSelf.leftOpen?weakSelf.leftValueArray[0]:@"0",
                    @"lmodel":weakSelf.leftOpen?weakSelf.leftValueArray[1]:@"0",
                    @"controlCircuitRight":weakSelf.rightController,
                    @"rbrand":weakSelf.rightOpen?weakSelf.rightValueArray[0]:@"0",
                    @"rmodel":weakSelf.rightOpen?weakSelf.rightValueArray[1]:@"0",
                    @"generatorOperationMode":@"1",
                    @"qtyOfHybrid":countArray.firstObject
                };
                for (NSString * key in item) {
                    [params setValue:item[key] forKey:key];
                }
//                for (int i=0; i<array.count; i++) {
//                    NSString * key = [NSString stringWithFormat:@"qtyOfHybrid%dBattery",i+1];
//                    NSString * value = array[i];
//                    [params setValue:value forKey:key];
//                }
                [self uploadDebugConfig:params];
            });
        }];
    });
}

- (void)uploadDebugConfig:(NSDictionary *)params{
    [Request.shareInstance postUrl:SaveDebugConfig params:params progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        [UIApplication.sharedApplication.keyWindow hiddenHUD];
        BOOL value = [result[@"data"] boolValue];
        if (!value) {
            [RMHelper showToast:result[@"message"] toView:self.view];
        }else{
            [RMHelper showToast:@"Success" toView:self.view];
        }
    } failure:^(NSString * _Nonnull errorMsg) {
        [UIApplication.sharedApplication.keyWindow hiddenHUD];
    }];
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
    if (indexPath.section == 0) {
        SelecteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SelecteTableViewCell class]) forIndexPath:indexPath];
        cell.titleLabel.text = indexPath.row == 0 ? @"System time".localized : @"E-stop".localized;
        if (indexPath.row == 0){
            if (self.systemTime){
                cell.content.text = self.systemTime;
                cell.content.textColor = UIColor.whiteColor;
            }else{
                cell.content.text = @"Please select";
                cell.content.textColor = [UIColor colorWithHexString:@"#999999"];
            }
        }else{
            cell.content.text = (self.stop.intValue == 1 ? @"E-Stop Enabled".localized : @"None".localized);
            cell.content.textColor = UIColor.whiteColor;
        }
        return cell;
    }else if (indexPath.section == 1 || indexPath.section == 2) {
        if (indexPath.row == 0) {
            SelecteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SelecteTableViewCell class]) forIndexPath:indexPath];
            cell.titleLabel.text = indexPath.section == 1 ? @"Expand port 2".localized : @"Expand port 1".localized;
            cell.content.text = indexPath.section == 1 ? self.leftValue : self.rightValue;
            return cell;
        }else{
            InputTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([InputTableViewCell class]) forIndexPath:indexPath];
            cell.titleLabel.text = indexPath.row == 1 ? @"Brand".localized : @"Model".localized;
            cell.textfield.placeholder = indexPath.row == 1 ? @"Brand".localized : @"Model".localized;
            cell.textfield.text = indexPath.section == 1 ? self.leftValueArray[indexPath.row-1] : self.rightValueArray[indexPath.row-1];
            cell.textfield.delegate = self;
            return cell;
        }
    }else if (indexPath.section == 3 || indexPath.section == 4){
        SelecteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SelecteTableViewCell class]) forIndexPath:indexPath];
        cell.titleLabel.text = indexPath.section == 3 ? @"Generator operation mode".localized : @"Qty of Hybrid".localized;
        cell.content.text = indexPath.section == 3 ? self.modelValue : [NSString stringWithFormat:@"%d",self.count];
        cell.content.textColor = UIColor.whiteColor;
        return cell;
    }
    else{
        SelecteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SelecteTableViewCell class]) forIndexPath:indexPath];
        cell.titleLabel.text = self.dataArray[indexPath.row][@"title"];
        cell.content.text = self.dataArray[indexPath.row][@"placeholder"];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            BRDatePickerView * picker = [[BRDatePickerView alloc] initWithPickerMode:BRDatePickerModeYMDHMS];
            picker.showUnitType = BRShowUnitTypeNone;
            picker.pickerStyle = self.style;
            picker.numberFullName = true;
            picker.resultBlock = ^(NSDate * _Nullable selectDate, NSString * _Nullable selectValue) {
                self.systemTime = selectValue;
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            };
            [picker show];
        }else if (indexPath.row == 1){
            UITableViewCell * cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
            CGRect frame = [cell.superview convertRect:cell.frame toView:UIApplication.sharedApplication.keyWindow];
            [SelectItemAlertView showSelectItemAlertViewWithDataArray:@[@"E-Stop Enabled".localized,@"None".localized] tableviewFrame:CGRectMake(SCREEN_WIDTH-170, frame.origin.y+50, 155, 50*2) completion:^(NSString * _Nonnull value, NSInteger idx) {
                self.stop = [NSString stringWithFormat:@"%ld",1-idx];
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }];
        }
    }else if (indexPath.section == 1) {
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
        CGRect frame = [cell.superview convertRect:cell.frame toView:UIApplication.sharedApplication.keyWindow];
        [SelectItemAlertView showSelectItemAlertViewWithDataArray:@[@"PV inverter enabled".localized,@"EV charger enabled".localized,@"None".localized] tableviewFrame:CGRectMake(SCREEN_WIDTH-200, frame.origin.y+50, 185, 50*3) completion:^(NSString * _Nonnull value, NSInteger idx) {
            self.leftOpen = idx != 2;
            self.leftValue = value;
            self.leftController = [NSString stringWithFormat:@"%ld",idx == 2 ? 0 : idx+1];
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        }];
    }else if (indexPath.section == 2){
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
        CGRect frame = [cell.superview convertRect:cell.frame toView:UIApplication.sharedApplication.keyWindow];
        [SelectItemAlertView showSelectItemAlertViewWithDataArray:@[@"Generator enabled".localized,@"EV charger enabled",@"PV inverter enabled",@"None".localized] tableviewFrame:CGRectMake(SCREEN_WIDTH-200, frame.origin.y+50, 185, 50*4) completion:^(NSString * _Nonnull value, NSInteger idx) {
            self.rightOpen = idx != 3;
            self.rightValue = value;
            self.rightController = [NSString stringWithFormat:@"%ld",idx == 3 ? 0 : idx+1];
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        }];
    }else if (indexPath.section == 3) {
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
        CGRect frame = [cell.superview convertRect:cell.frame toView:UIApplication.sharedApplication.keyWindow];
        [SelectItemAlertView showSelectItemAlertViewWithDataArray:@[@"Efficient mode".localized,@"Quiet mode".localized] tableviewFrame:CGRectMake(SCREEN_WIDTH-150, frame.origin.y+50, 135, 50*2) completion:^(NSString * _Nonnull value, NSInteger idx) {
            self.modelValue = value;
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
    }
    else if (indexPath.section == 4) {
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
        CGRect frame = [cell.superview convertRect:cell.frame toView:UIApplication.sharedApplication.keyWindow];
        [SelectItemAlertView showSelectItemAlertViewWithDataArray:@[@"1",@"2",@"3",@"4",@"5",@"6"] tableviewFrame:CGRectMake(SCREEN_WIDTH-50, frame.origin.y+50, 50, 50*6) completion:^(NSString * _Nonnull value, NSInteger idx) {
            self.count = value.intValue;
            [self resetNumberData];
        }];
    }else if (indexPath.section == 5) {
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
        return 2;
    }else if (section == 1) {
        return self.leftOpen ? 3 : 1;
    }else if (section == 2){
        return self.rightOpen ? 3 : 1;
    }else if (section == 3 || section == 4){
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
