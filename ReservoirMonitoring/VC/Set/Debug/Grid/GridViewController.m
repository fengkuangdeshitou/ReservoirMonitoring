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

@interface GridViewController ()

@property(nonatomic,weak)IBOutlet UITableView * tableView;
@property(nonatomic,weak)IBOutlet UIButton * submit;
@property(nonatomic,strong)NSMutableArray * dataArray;

@end

@implementation GridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.dataArray = [[NSMutableArray alloc] initWithArray:@[
        @{@"title":@"Backup type".localized,@"placeholder":@"Partical home".localized,@"value":@""},
        @{@"title":@"Grid nominal voltage".localized,@"placeholder":@"Please enter a rating".localized},
        @{@"title":@"Grid standard".localized,@"placeholder":@"internal standard".localized,@"value":@""},
        ]];
    [self.submit setTitle:@"Submit".localized forState:UIControlStateNormal];
    [self.submit showBorderWithRadius:25];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([InputTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([InputTableViewCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SelecteTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([SelecteTableViewCell class])];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [BleManager.shareInstance readWithCMDString:@"625" count:1 finish:^(NSArray * array){
            [self exchangeDictFor:0 value:@[@"Whole home".localized,@"Partical home".localized][[array.firstObject intValue]]];
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"626" count:1 finish:^(NSArray * array){
            NSString * value = [NSString stringWithFormat:@"%@",array.firstObject];
            if (value.intValue > 0) {
                InputTableViewCell * cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                cell.textfield.text = value;
            }
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"513" count:1 finish:^(NSArray * array){
            NSInteger index = [array.firstObject intValue] == 255 ? 6 : [array.firstObject intValue];
            [self exchangeDictFor:2 value:@[
                @"SCE Rule 21".localized,
                @"SDG&E Rule 21".localized,
                @"PG&E Rule 21".localized,
                @"HECO Rule 14H,Oahu,Maui,Hawaii Island".localized,
                @"HECO Rule 14H,Molokai,Lanai".localized,
                @"ISO-EN".localized,
                @"internal standard".localized
            ][index]];
        }];
    });
    
}

- (void)exchangeDictFor:(NSInteger)idx value:(NSString *)value{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithDictionary:self.dataArray[idx]];
    dict[@"placeholder"] = value;
    self.dataArray[idx] = dict;
    [self.tableView reloadData];
}

- (IBAction)submitAction:(id)sender{
    InputTableViewCell * cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    [BleManager.shareInstance writeWithCMDString:@"625" array:@[self.dataArray[0][@"value"],cell.textfield.text,self.dataArray[2][@"value"]] finish:^{
        NSLog(@"成功");
        [RMHelper showToast:@"Write success" toView:self.view];
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 1) {
        InputTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([InputTableViewCell class]) forIndexPath:indexPath];
        cell.titleLabel.text = self.dataArray[indexPath.row][@"title"];
        cell.textfield.placeholder = self.dataArray[indexPath.row][@"placeholder"];
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
        [SelectItemAlertView showSelectItemAlertViewWithDataArray:@[@"Whole home".localized,@"Partical home".localized] tableviewFrame:CGRectMake(SCREEN_WIDTH-130, frame.origin.y, 130, 50*2) completion:^(NSString * _Nonnull value, NSInteger idx) {
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithDictionary:self.dataArray[indexPath.row]];
            dict[@"placeholder"] = value;
            dict[@"value"] = [NSString stringWithFormat:@"%ld",idx];
            self.dataArray[indexPath.row] = dict;
            [tableView reloadData];
        }];
    }else if (indexPath.row == 2){
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
        CGRect frame = [cell.superview convertRect:cell.frame toView:UIApplication.sharedApplication.keyWindow];
        [SelectItemAlertView showSelectItemAlertViewWithDataArray:@[
            @"SCE Rule 21".localized,
            @"SDG&E Rule 21".localized,
            @"PG&E Rule 21".localized,
            @"HECO Rule 14H,Oahu,Maui,Hawaii Island".localized,
            @"HECO Rule 14H,Molokai,Lanai".localized,
            @"ISO-EN".localized,
            @"internal standard".localized
        ] tableviewFrame:CGRectMake(50, frame.origin.y+50, SCREEN_WIDTH-50, 50*7) completion:^(NSString * _Nonnull value, NSInteger idx) {
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithDictionary:self.dataArray[indexPath.row]];
            dict[@"placeholder"] = value;
            dict[@"value"] = [NSString stringWithFormat:@"%ld",idx==6?255:idx];
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
