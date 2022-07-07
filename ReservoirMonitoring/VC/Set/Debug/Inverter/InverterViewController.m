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

@interface InverterViewController ()<UITableViewDataSource,UITextFieldDelegate>

@property(nonatomic,weak)IBOutlet UITableView * tableView;
@property(nonatomic,weak)IBOutlet UIButton * submit;
@property(nonatomic,strong)NSMutableArray * dataArray;
@property(nonatomic,assign)int resNum;

@end

@implementation InverterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.resNum = 1;
    [self loadRessNumber];
    [self.submit setTitle:@"Submit".localized forState:UIControlStateNormal];
    [self.submit showBorderWithRadius:25];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([InputTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([InputTableViewCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SelecteTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([SelecteTableViewCell class])];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        [BleManager.shareInstance readWithCMDString:@"620" count:1 finish:^(NSArray * _Nonnull array) {
            self.resNum = [array.firstObject intValue] == 0 ? 1 : [array.firstObject intValue];
            [self loadRessNumber];
            dispatch_semaphore_signal(sem);
        }];
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"629" count:4 finish:^(NSArray * _Nonnull array) {
            NSMutableArray * fristArray = [[NSMutableArray alloc] initWithArray:self.dataArray.firstObject];
            [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSMutableDictionary * item = [[NSMutableDictionary alloc] initWithDictionary:fristArray[idx]];
                if (idx == 0) {
                    item[@"value"] = [NSString stringWithFormat:@"%d",[obj intValue]/10];
                    [fristArray replaceObjectAtIndex:0 withObject:item];
                }else if (idx == 1) {
                    item[@"value"] = [NSString stringWithFormat:@"%d",[obj intValue]/10];;
                    [fristArray replaceObjectAtIndex:1 withObject:item];
                }else if (idx == 2) {
                    item[@"value"] = [NSString stringWithFormat:@"%d",[obj intValue]/10];;
                    [fristArray replaceObjectAtIndex:2 withObject:item];
                }else if (idx == 3) {
                    item[@"value"] = [NSString stringWithFormat:@"%d",[obj intValue]/10];;
                    [fristArray replaceObjectAtIndex:3 withObject:item];
                }
                [self.dataArray replaceObjectAtIndex:0 withObject:fristArray];
            }];
            dispatch_semaphore_signal(sem);
        }];
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"63A" count:4*(self.resNum-1) finish:^(NSArray * _Nonnull array) {
            for (int idx=0; idx<array.count; idx++) {
                NSMutableArray * sectionArray = [[NSMutableArray alloc] initWithArray:self.dataArray[idx/4+1]];
                NSString *obj = array[idx];
                if (idx%4 == 0) {
                    NSMutableDictionary * item = [[NSMutableDictionary alloc] initWithDictionary:sectionArray[0]];
                    item[@"value"] = [NSString stringWithFormat:@"%d",[obj intValue]/10];;
                    [sectionArray replaceObjectAtIndex:0 withObject:item];
                }else if (idx%4 == 1) {
                    NSMutableDictionary * item = [[NSMutableDictionary alloc] initWithDictionary:sectionArray[1]];
                    item[@"value"] = [NSString stringWithFormat:@"%d",[obj intValue]/10];;
                    [sectionArray replaceObjectAtIndex:1 withObject:item];
                }else if (idx%4 == 2) {
                    NSMutableDictionary * item = [[NSMutableDictionary alloc] initWithDictionary:sectionArray[2]];
                    item[@"value"] = [NSString stringWithFormat:@"%d",[obj intValue]/10];;
                    [sectionArray replaceObjectAtIndex:2 withObject:item];
                }else if (idx%4 == 3) {
                    NSMutableDictionary * item = [[NSMutableDictionary alloc] initWithDictionary:sectionArray[3]];
                    item[@"value"] = [NSString stringWithFormat:@"%d",[obj intValue]/10];;
                    [sectionArray replaceObjectAtIndex:3 withObject:item];
                }
                [self.dataArray replaceObjectAtIndex:(idx/4+1) withObject:sectionArray];
            }
            dispatch_semaphore_signal(sem);
        }];
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.submit.hidden = false;
            [self.tableView reloadData];
        });
    });
}

- (void)loadRessNumber{
    self.dataArray = [[NSMutableArray alloc] init];
    for (int i=0; i<self.resNum; i++) {
        NSArray * array = @[
            @{@"title":[NSString stringWithFormat:@"Hybrid%d PV1 voltage",i+1],@"placeholder":@"PV1 voltage".localized,@"value":@"0"},
            @{@"title":[NSString stringWithFormat:@"Hybrid%d PV2 voltage",i+1],@"placeholder":@"PV2 voltage".localized,@"value":@"0"},
            @{@"title":[NSString stringWithFormat:@"Hybrid%d PV3 voltage",i+1],@"placeholder":@"PV3 voltage".localized,@"value":@"0"},
            @{@"title":[NSString stringWithFormat:@"Hybrid%d PV4 voltage",i+1],@"placeholder":@"PV4 voltage".localized,@"value":@"0"}
        ];
        [self.dataArray addObject:array];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    InputTableViewCell * cell = (InputTableViewCell *)[[[textField superview] superview] superview];
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    NSMutableArray * sectionArray = [[NSMutableArray alloc] initWithArray:self.dataArray[indexPath.section]];
    NSMutableDictionary * item = [[NSMutableDictionary alloc] initWithDictionary:sectionArray[indexPath.row]];
    item[@"value"] = textField.text;
    [sectionArray replaceObjectAtIndex:indexPath.row withObject:item];
    [self.dataArray replaceObjectAtIndex:indexPath.section withObject:sectionArray];
}

- (NSString *)getInputTextWithRow:(NSInteger)row{
    InputTableViewCell * cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    return cell.textfield.text;
}

- (InputTableViewCell *)getCellWithRow:(NSInteger)row section:(NSInteger)section{
    return [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
}

- (IBAction)submitAction:(id)sender{
    [self.view endEditing:true];
    NSMutableArray * valueArray = [[NSMutableArray alloc] init];
    for (int i=0; i<self.dataArray.count; i++) {
        NSArray * sectionArray = self.dataArray[i];
        for (int j=0; j<4; j++) {
            [valueArray addObject:sectionArray[j][@"value"]];
        }
    }
    NSMutableArray * fristArray = [[NSMutableArray alloc] init];
    NSMutableArray * otherArray = [[NSMutableArray alloc] init];

    for (int i=0; i<valueArray.count; i++) {
        if (i<4) {
            [fristArray addObject:[NSString stringWithFormat:@"%d",[valueArray[i] intValue]*10]];
        }else{
            [otherArray addObject:[NSString stringWithFormat:@"%d",[valueArray[i] intValue]*10]];
        }
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        [BleManager.shareInstance writeWithCMDString:@"629" array:fristArray finish:^{
            dispatch_semaphore_signal(sem);
        }];
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance writeWithCMDString:@"63A" array:otherArray finish:^{
            [RMHelper showToast:@"Write success" toView:self.view];
            dispatch_semaphore_signal(sem);
        }];
    });
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 4) {
        SelecteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SelecteTableViewCell class]) forIndexPath:indexPath];
        cell.titleLabel.text = self.dataArray[indexPath.row][@"title"];
        cell.content.text = self.dataArray[indexPath.row][@"placeholder"];
        return cell;
    }else{
        InputTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([InputTableViewCell class]) forIndexPath:indexPath];
        cell.titleLabel.text = self.dataArray[indexPath.section][indexPath.row][@"title"];
        cell.textfield.placeholder = self.dataArray[indexPath.section][indexPath.row][@"placeholder"];
        cell.textfield.text = self.dataArray[indexPath.section][indexPath.row][@"value"];
        cell.textfield.delegate = self;
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.resNum;
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
