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
@property(nonatomic,strong)NSArray * leftValueArray;
@property(nonatomic,strong)NSArray * rightValueArray;
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
    [self.submit setTitle:@"Submit".localized forState:UIControlStateNormal];
    [self.submit showBorderWithRadius:25];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([InputTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([InputTableViewCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SelecteTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([SelecteTableViewCell class])];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [BleManager.shareInstance readWithCMDString:@"611" count:6 finish:^(NSArray * _Nonnull array) {
            if (array.count == 6) {
                self.systemTime = [NSString stringWithFormat:@"%@-%@-%@ %@:%@:%@",array[0],array[1],array[2],array[3],array[4],array[5]];
            }
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"64F" count:1 finish:^(NSArray * _Nonnull array) {
            self.stop = array.firstObject;
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"62D" count:3 finish:^(NSArray * _Nonnull array) {
            NSLog(@"62d=%@",array);
            self.leftOpen = [array.firstObject intValue] != 0;
            self.leftController = [NSString stringWithFormat:@"%@",array.firstObject];
            self.leftValue = !self.leftOpen ? @"None".localized : @[@"PV inverter enabled".localized,@"EV charger enabled".localized][([array.firstObject intValue]-1)];
            if (self.leftOpen) {
                self.leftValueArray = @[array[1],array[2]];
            }
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"630" count:3 finish:^(NSArray * _Nonnull array) {
            self.rightOpen = [array.firstObject intValue] != 0;
            self.rightController = [NSString stringWithFormat:@"%@",array.firstObject];
            if (self.rightOpen) {
                self.rightValueArray = @[array[1],array[2]];
            }
            self.rightValue = self.rightOpen ? @"Generator enabled".localized :  @"None".localized;
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"633" count:1 finish:^(NSArray * _Nonnull array) {
            NSInteger inx = [array.firstObject intValue];
            if (inx == 0) {
                self.modelValue = @"Efficient mode".localized;
            }else{
                self.modelValue = @[@"Efficient mode".localized,@"Quiet mode".localized][inx-1];
            }
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"620" count:1 finish:^(NSArray * _Nonnull array) {
            int inx = [array.firstObject intValue];
            self.count = inx;
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"634" count:self.count finish:^(NSArray * _Nonnull array) {
            self.dataArray = [[NSMutableArray alloc] init];
            for (int i=0; i<array.count; i++) {
                int value = [array[i] intValue];
                NSDictionary * dic = @{@"title":[NSString stringWithFormat:@"Qty of Hybrid %d battery",i+1],@"placeholder":[NSString stringWithFormat:@"%d",value]};
                [self.dataArray addObject:dic];
            }
            [self.tableView reloadData];
            dispatch_semaphore_signal(semaphore);
        }];
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
    NSArray * leftArray = @[];
    if (self.leftOpen) {
        leftArray = @[self.leftController,self.leftValueArray[0],self.leftValueArray[1]];
    }

    NSArray * rightArray = @[];
    if (self.rightOpen) {
        rightArray = @[self.rightController,self.rightValueArray[0],self.rightValueArray[1]];
    }
    if (!self.systemTime) {
        [RMHelper showToast:@"Please select time" toView:self.view];
        return;
    }
    
    SelecteTableViewCell * hybrid = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:4]];
    if (hybrid.content.text.intValue == 0) {
        [RMHelper showToast:@"Please select Qry number" toView:self.view];
        return;
    }
    
    NSArray * countArray = @[hybrid.content.text];
    NSMutableArray * array = [[NSMutableArray alloc] init];
    for (int i=0; i<hybrid.content.text.intValue; i++) {
        SelecteTableViewCell * cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:5]];
        [array addObject:cell.content.text];
    }

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        NSString * time = self.systemTime;
        NSString * ymdTime = [time componentsSeparatedByString:@" "].firstObject;
        NSString * hmsTime = [time componentsSeparatedByString:@" "].lastObject;
        NSArray * ymdArray = [ymdTime componentsSeparatedByString:@"-"];
        NSArray * hmsArray = [hmsTime componentsSeparatedByString:@":"];
        NSArray * timeArray = @[ymdArray[0],ymdArray[1],ymdArray[2],hmsArray[0],hmsArray[1],hmsArray[2]];
        [BleManager.shareInstance writeWithCMDString:@"611" array:timeArray finish:^{
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance writeWithCMDString:@"64F" array:self.stop?@[self.stop]:@[@"0"] finish:^{
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance writeWithCMDString:@"62D" array:self.leftOpen ? leftArray : @[@"0"] finish:^{
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance writeWithCMDString:@"630" array:self.rightOpen ? rightArray : @[@"0"] finish:^{
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSString * modelValue = [self.modelValue isEqualToString:@"Efficient mode".localized] ? @"1" : @"2";
        [BleManager.shareInstance writeWithCMDString:@"633" array:@[modelValue] finish:^{
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance writeWithCMDString:@"620" array:countArray finish:^{
            dispatch_semaphore_signal(semaphore);
        }];

        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance writeWithCMDString:@"634" array:array finish:^{
            dispatch_semaphore_signal(semaphore);
            [RMHelper showToast:@"Write success" toView:self.view];
        }];
    });
    
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
        cell.content.text = indexPath.row == 0 ? self.systemTime : (self.stop.intValue == 1 ? @"E-Stop Enabled".localized : @"None".localized);
        return cell;
    }else if (indexPath.section == 1 || indexPath.section == 2) {
        if (indexPath.row == 0) {
            SelecteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SelecteTableViewCell class]) forIndexPath:indexPath];
            cell.titleLabel.text = indexPath.section == 1 ? @"Control circuit left".localized : @"Control circuit right".localized;
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
        [SelectItemAlertView showSelectItemAlertViewWithDataArray:@[@"Generator enabled".localized,@"None".localized] tableviewFrame:CGRectMake(SCREEN_WIDTH-200, frame.origin.y+50, 185, 50*2) completion:^(NSString * _Nonnull value, NSInteger idx) {
            self.rightOpen = idx != 1;
            self.rightValue = value;
            self.rightController = [NSString stringWithFormat:@"%ld",idx == 2 ? 0 : idx+1];
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
    return 6;
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
