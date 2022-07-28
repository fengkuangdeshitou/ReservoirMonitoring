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

@end

@implementation WarningListView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.page = 1;
        [self getListData];
//        self.tableView setpull
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

- (void)getListData{
    if (RMHelper.getUserType && RMHelper.getLoadDataForBluetooth) {
        [BleManager.shareInstance readWithCMDString:self.tag == 10 ? @"550" : @"553" count:3 finish:^(NSArray * _Nonnull array) {
            NSLog(@"array=%@",array);
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

- (void)getListWithDevId:(NSString *)devId{
    [Request.shareInstance getUrl:[NSString stringWithFormat:@"%@/%@/%@",AlertFaultList,devId,self.tag==10?@"1":@"2"] params:@{@"pageNo":[NSString stringWithFormat:@"%ld",self.page],@"pageSize":@"10"} progress:^(float progress) {
                
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
    cell.time.text = self.tag == 10 ? @"Warning time：".localized : @"Fault Time".localized;
    cell.line.hidden = indexPath.row == 4;
    NSDictionary * item = self.dataArray[indexPath.row];
    cell.titleLabel.text = item[@"enContent"];
    cell.sn.text = item[@"sgSn"];
    cell.timeLabel.text = item[@"createTime"];
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
