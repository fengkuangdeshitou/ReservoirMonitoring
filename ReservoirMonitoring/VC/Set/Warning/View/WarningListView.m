//
//  WarningListView.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/19.
//

#import "WarningListView.h"
#import "WarningTableViewCell.h"
#import "GlobelDescAlertView.h"
#import "DevideModel.h"

@interface WarningListView ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UITableView * tableView;
@property(nonatomic,assign) NSInteger page;
@property(nonatomic,strong) NSMutableArray * dataArray;
@property(nonatomic,strong) NSArray * warning_550;
@property(nonatomic,strong) NSArray * warning_551;
@property(nonatomic,strong) NSArray * warning_552;
@property(nonatomic,strong) NSArray * fault_553;
@property(nonatomic,strong) NSArray * fault_554;
@property(nonatomic,strong) NSArray * fault_555;
@property(nonatomic,strong) NSArray * fault_556;

@end

@implementation WarningListView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.warning_550 = @[@"SW0_reserved",@"SW1_reserved",@"SW2_reserved",@"SW3_reserved",@"SW4_reserved",@"SW5_reserved",@"SW6_reserved",@"SW7_reserved",@"SW8_reserved",@"SW9_reserved",@"SW10_reserved",@"SW11_reserved",@"SW12_reserved",@"SW13_reserved",@"SW14_reserved",@"SW15_reserved"];
        self.warning_551 = @[@"Temperature sensor failure",@"Reserved1",@"Reserved2",@"Reserved3",@"Reserved4",@"Reserved5",@"Reserved6",@"Reserved7",@"Reserved8",@"Reserved9",@"Reserved10",@"Reserved11",@"SD card failure",@"Reserved13",@"Reserved14",@"Reserved15"];
        self.warning_552 = @[@"Reserved",@"Reserved",@"Reserved",@"Reserved",@"Reserved",@"Reserved",@"Reserved",@"Reserved",@"Reserved",@"Reserved",@"Reserved",@"Reserved",@"Reserved",@"Reserved",@"Reserved",@"Reserved"];
        self.fault_553 = @[@"Meter communication error",@"Remote communication error",@"Reserved 2",@"Reserved 3",@"Reserved 4",@"Reserved 5",@"Reserved 6",@"Reserved 7",@"Reserved 8",@"Reserved 9",@"Reserved 10",@"Reserved 11",@"Reserved 12",@"Reserved 13",@"Reserved 14",@"Reserved 15"];
        self.fault_554 = @[@"T1_Severe overheat",@"Reserved 1",@"Reserved 2",@"Reserved 3",@"Reserved 4",@"Reserved 5",@"Reserved 6",@"Reserved 7",@"Reserved 8",@"Reserved 9",@"Reserved 10",@"Reserved 11",@"Reserved 12",@"Reserved 13",@"Reserved 14",@"Reserved 15"];
        self.fault_555 = @[@"DCAC module 1 comms lost",@"DCAC module 1 comms lost",@"DCAC module 3 comms lost",@"DCAC module 4 comms lost",@"DCAC module 5 comms lost",@"DCAC module 6 comms lost",@"DCAC module 7 comms lost",@"DCAC module 8 comms lost",@"DCAC module 9 comms lost",@"DCAC module 10 comms lost",@"Reserved 10",@"Reserved 11",@"Reserved 12",@"Reserved 13",@"Reserved 14",@"Reserved 15"];
        self.fault_556 = @[@"DCDC module 1 comms lost",@"DCDC module 1 comms lost",@"DCDC module 3 comms lost",@"DCDC module 4 comms lost",@"DCDC module 5 comms lost",@"DCDC module 6 comms lost",@"DCDC module 7 comms lost",@"DCDC module 8 comms lost",@"DCDC module 9 comms lost",@"DCDC module 10 comms lost",@"Reserved 10",@"Reserved 11",@"Reserved 12",@"Reserved 13",@"Reserved 14",@"Reserved 15"];

        self.page = 1;
        self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStyleGrouped];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundColor = [UIColor colorWithHexString:@"#0C0C0C"];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:self.tableView];
        [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([WarningTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([WarningTableViewCell class])];
    }
    return self;
}

- (void)setIsLoad:(BOOL)isLoad{
    _isLoad = isLoad;
    [self getListData];
}

- (void)getListData{
    if (RMHelper.getUserType && RMHelper.getLoadDataForBluetooth) {
        [BleManager.shareInstance readWithCMDString:self.tag == 10 ? @"550" : @"553" count:self.tag == 10 ? 3 : 4 finish:^(NSArray * _Nonnull array) {
            self.dataArray = [[NSMutableArray alloc] init];
            for (int i=0; i<array.count; i++) {
                int value = [array[i] intValue];
                NSMutableArray * warringArray = [[NSMutableArray alloc] init];
                NSString * binaryString = [self toBinarySystemWithDecimalSystem:value length:16];
                for (int j=0; j<binaryString.length; j++) {
                    [warringArray addObject:[binaryString substringWithRange:NSMakeRange(j, 1)]];
                }
                [warringArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj intValue] == 1) {
                        if (i == 0) {
                            [self.dataArray addObject:self.warning_550[idx]];
                        }else if (i == 1){
                            [self.dataArray addObject:self.warning_551[idx]];
                        }else{
                            [self.dataArray addObject:self.warning_552[idx]];
                        }
                    }
                }];
            }
            [self.tableView reloadData];
        }];
    }else{
        [Request.shareInstance getUrl:DeviceList params:@{} progress:^(float progress) {
                
        } success:^(NSDictionary * _Nonnull result) {
            NSArray * modelArray = [DevideModel mj_objectArrayWithKeyValuesArray:result[@"data"]];
            NSArray<DevideModel*> * array = [modelArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"lastConnect = %@",@"1"]];
            if (array.count > 0) {
                NSString * devId = array.firstObject.deviceId;
                [self getListWithDevId:devId];
            }
        } failure:^(NSString * _Nonnull errorMsg) {

        }];
        
    }
}

//  十进制转二进制
- (NSString *)toBinarySystemWithDecimalSystem:(int)num length:(int)length
{
    int remainder = 0;      //余数
    int divisor = 0;        //除数
    NSString * prepare = @"";
    while (true)
    {
        remainder = num%2;
        divisor = num/2;
        num = divisor;
        prepare = [prepare stringByAppendingFormat:@"%d",remainder];

        if (divisor == 0)
        {
            break;
        }
    }
    //倒序输出
    NSString * result = @"";
    for (int i = length -1; i >= 0; i --)
    {
        if (i <= prepare.length - 1) {
            result = [result stringByAppendingFormat:@"%@",
                      [prepare substringWithRange:NSMakeRange(i , 1)]];

        }else{
            result = [result stringByAppendingString:@"0"];

        }
    }
    return result;
}

- (void)getListWithDevId:(NSString *)devId{
    [Request.shareInstance getUrl:[NSString stringWithFormat:@"%@/%@/%@",AlertFaultList,devId,self.tag==10?@"1":@"2"] params:@{@"pageNo":[NSString stringWithFormat:@"%ld",self.page],@"pageSize":@"10000"} progress:^(float progress) {
                
    } success:^(NSDictionary * _Nonnull result) {
        NSArray * array = result[@"data"];
        if (self.page == 1) {
            self.dataArray = [[NSMutableArray alloc] initWithArray:array];
        }else{
            [self.dataArray addObject:array];
        }
        [self.tableView reloadData];
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WarningTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WarningTableViewCell class]) forIndexPath:indexPath];
    cell.typeLabel.textColor = [UIColor colorWithHexString:self.tag == 10 ? @"#EE8805" : @"#AE0000"];
    cell.typeLabel.text = self.tag == 10 ? @"Warning".localized : @"Fault".localized;
    cell.typeLabel.hidden = YES;
    
    if (RMHelper.getUserType && RMHelper.getLoadDataForBluetooth) {
        cell.titleLabel.text = self.dataArray[indexPath.row];
        cell.sn.text = [NSString stringWithFormat:@"SN:%@",BleManager.shareInstance.deviceSN];
        NSDate * date = [NSDate date];
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        cell.timeLabel.text = [formatter stringFromDate:date];
    }else{
        NSDictionary * item = self.dataArray[indexPath.row];
        cell.titleLabel.text = item[@"enContent"];
        cell.sn.text = item[@"sgSn"];
        if (![item[@"fromCreateTime"] isEqual:[NSNull null]]) {
            NSString * fromCreateTime = item[@"fromCreateTime"];
            if (fromCreateTime.length > 0) {
                cell.timeLabel.text = item[@"fromCreateTime"];
            }else{
                cell.timeLabel.text = item[@"defCreateTime"];
            }
        }else{
            cell.timeLabel.text = item[@"defCreateTime"];
        }
    }
    cell.time.text = self.tag == 10 ? @"Warning time：".localized : @"Fault Time".localized;
    cell.line.hidden = indexPath.row == 4;
    cell.icon.image = [UIImage imageNamed:self.tag == 10 ? @"icon_warn_red" : @"icon_warn_yellow"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [GlobelDescAlertView showAlertViewWithTitle:@"Tips".localized desc:@"TBD." btnTitle:nil completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
