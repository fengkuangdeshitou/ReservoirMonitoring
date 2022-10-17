//
//  GridViewController.m
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/5/13.
//

#import "GridViewController.h"
#import "InputTableViewCell.h"
#import "SelecteTableViewCell.h"
#import "SelectItemAlertView.h"
#import "GlobelDescAlertView.h"

@interface GridViewController ()<UITextFieldDelegate>

@property(nonatomic,weak)IBOutlet UITableView * tableView;
@property(nonatomic,weak)IBOutlet UIButton * submit;
@property(nonatomic,strong)NSMutableArray * dataArray;

@end

@implementation GridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.dataArray = [[NSMutableArray alloc] initWithArray:@[
        @{@"title":@"Backup type".localized,@"placeholder":@"Partial home".localized,@"value":@""},
        @{@"title":@"Grid nominal voltage".localized,@"placeholder":@"Enter (number)".localized},
        @{@"title":@"Grid standard".localized,@"placeholder":@"internal standard".localized,@"value":@""},
        @{@"title":@"Grid frequency".localized,@"placeholder":@"50 Hz",@"value":@""},
        ]];
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
        [BleManager.shareInstance readWithCMDString:@"625" count:1 finish:^(NSArray * array){
            int value = 0;
            if([array.firstObject intValue] < 2){
                value = [array.firstObject intValue];
            };
            [weakSelf exchangeDictFor:0 value:@[@"Whole home".localized,@"Partial home".localized][1-value]];
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithDictionary:self.dataArray[0]];
            dict[@"value"] = [NSString stringWithFormat:@"%d",1-value];
            self.dataArray[0] = dict;
            dispatch_semaphore_signal(semaphore);
        }];
        
//        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//        [BleManager.shareInstance readWithCMDString:@"626" count:1 finish:^(NSArray * array){
//            float value = [array.firstObject floatValue];
//            if (value > 0) {
//                NSString * input = [NSString stringWithFormat:@"%.1f",value/10];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    InputTableViewCell * cell = [weakSelf.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
//                    cell.textfield.text = input;
//                });
//            }else{
//                [weakSelf exchangeDictFor:1 value:@"0"];
//            }
//            dispatch_semaphore_signal(semaphore);
//        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        // 513
        [BleManager.shareInstance readWithCMDString:@"627" count:1 finish:^(NSArray * array){
            NSInteger index = [array.firstObject intValue] == 255 ? 6 : [array.firstObject intValue];
            if (index > 6){
                index = 6;
            }
            [weakSelf exchangeDictFor:2 value:@[
                @"SCE Rule 21",
                @"SDG&E Rule 21",
                @"PG&E Rule 21",
                @"HECO Rule 14H,Oahu,Maui,Hawaii Island",
                @"HECO Rule 14H,Molokai,Lanai",
                @"ISO-EN",
                @"internal standard"
            ][index]];
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithDictionary:self.dataArray[2]];
            dict[@"value"] = [NSString stringWithFormat:@"%ld",index];
            self.dataArray[2] = dict;
            dispatch_semaphore_signal(semaphore);
        }];
        
//        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//        [BleManager.shareInstance readWithCMDString:@"64E" count:1 finish:^(NSArray * array){
//            [weakSelf exchangeDictFor:3 value:[array.firstObject intValue] == 0 ? @"50 Hz" : [NSString stringWithFormat:@"%@ Hz",array.firstObject]];
//            NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithDictionary:self.dataArray[3]];
//            dict[@"value"] = [array.firstObject intValue] == 0 ? @"50" : [NSString stringWithFormat:@"%@",array.firstObject];
//            self.dataArray[3] = dict;
//            dispatch_semaphore_signal(semaphore);
//        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication.sharedApplication.keyWindow hiddenHUD];
            [weakSelf.tableView reloadData];
            dispatch_semaphore_signal(semaphore);
        });
    });
    
}

- (void)exchangeDictFor:(NSInteger)idx value:(NSString *)value{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithDictionary:self.dataArray[idx]];
    dict[@"placeholder"] = value;
    self.dataArray[idx] = dict;
}

- (IBAction)submitAction:(id)sender{
//    InputTableViewCell * cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
//    float input = [cell.textfield.text floatValue]*10;
//    [NSString stringWithFormat:@"%.1f",input],
    if (!BleManager.shareInstance.isConnented) {
        [GlobelDescAlertView showAlertViewWithTitle:@"Tips" desc:@"Please connect the bluetooth device first" btnTitle:nil completion:nil];
        return;
    }
    __weak typeof(self) weakSelf = self;
    if (BleManager.shareInstance.isConnented) {
        [UIApplication.sharedApplication.keyWindow showHUDToast:@"Loading"];
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        [BleManager.shareInstance writeWithCMDString:@"625" array:@[weakSelf.dataArray[0][@"value"]] finish:^{
            dispatch_semaphore_signal(sem);
        }];
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance writeWithCMDString:@"627" array:@[weakSelf.dataArray[2][@"value"]] finish:^{
            dispatch_semaphore_signal(sem);
            [weakSelf uploadDebugConfig:@{
                @"devId":[NSUserDefaults.standardUserDefaults objectForKey:CURRENR_DEVID],
                @"formType":@"1",
                @"backupType":weakSelf.dataArray[0][@"value"],
//                @"gridNominalVoltage":[NSString stringWithFormat:@"%.1f",input],
                @"gridStandard":weakSelf.dataArray[2][@"value"],
//                @"gridFrequency":weakSelf.dataArray[3][@"value"]
            }];
        }];
//        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
//        [BleManager.shareInstance writeWithCMDString:@"64E" array:@[weakSelf.dataArray[3][@"value"]] finish:^{
//
//        }];
    });
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 1) {
        InputTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([InputTableViewCell class]) forIndexPath:indexPath];
        cell.titleLabel.text = self.dataArray[indexPath.row][@"title"];
        cell.textfield.placeholder = self.dataArray[indexPath.row][@"placeholder"];
        cell.textfield.delegate = self;
        cell.textfield.keyboardType = UIKeyboardTypeDecimalPad;
        return cell;
    }else{
        SelecteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SelecteTableViewCell class]) forIndexPath:indexPath];
        cell.titleLabel.text = self.dataArray[indexPath.row][@"title"];
        cell.content.text = self.dataArray[indexPath.row][@"placeholder"];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section]];
        CGRect frame = [cell.superview convertRect:cell.frame toView:UIApplication.sharedApplication.keyWindow];
        [SelectItemAlertView showSelectItemAlertViewWithDataArray:@[@"Whole home".localized,@"Partial home".localized] tableviewFrame:CGRectMake(SCREEN_WIDTH-130, frame.origin.y, 130, 50*2) completion:^(NSString * _Nonnull value, NSInteger idx) {
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithDictionary:self.dataArray[indexPath.row]];
            dict[@"placeholder"] = value;
            dict[@"value"] = [NSString stringWithFormat:@"%ld",1-idx];
            self.dataArray[indexPath.row] = dict;
            [tableView reloadData];
        }];
    }else if (indexPath.row == 2){
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
        CGRect frame = [cell.superview convertRect:cell.frame toView:UIApplication.sharedApplication.keyWindow];
        [SelectItemAlertView showSelectItemAlertViewWithDataArray:@[
            @"SCE Rule 21",
            @"SDG&E Rule 21",
            @"PG&E Rule 21",
            @"HECO Rule 14H,Oahu,Maui,Hawaii Island",
            @"HECO Rule 14H,Molokai,Lanai",
            @"ISO-EN",
            @"internal standard"
        ] tableviewFrame:CGRectMake(50, frame.origin.y+50, SCREEN_WIDTH-50, 50*7) completion:^(NSString * _Nonnull value, NSInteger idx) {
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithDictionary:self.dataArray[indexPath.row]];
            dict[@"placeholder"] = value;
            dict[@"value"] = [NSString stringWithFormat:@"%ld",idx==6?255:idx];
            self.dataArray[indexPath.row] = dict;
            [tableView reloadData];
        }];
    }else if (indexPath.row == 3){
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
        CGRect frame = [cell.superview convertRect:cell.frame toView:UIApplication.sharedApplication.keyWindow];
        [SelectItemAlertView showSelectItemAlertViewWithDataArray:@[
            @"50 Hz",
            @"60 Hz",
        ] tableviewFrame:CGRectMake(SCREEN_WIDTH-100, frame.origin.y+50, 100, 50*2) completion:^(NSString * _Nonnull value, NSInteger idx) {
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithDictionary:self.dataArray[indexPath.row]];
            dict[@"placeholder"] = value;
            dict[@"value"] = [NSString stringWithFormat:@"%@",idx==0?@"50":@"60"];
            self.dataArray[indexPath.row] = dict;
            [tableView reloadData];
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.row == 1 || indexPath.row == 3 ? 0.01 : 50;
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
