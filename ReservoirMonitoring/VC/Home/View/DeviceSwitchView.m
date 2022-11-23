//
//  DeviceSwitchView.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/16.
//

#import "DeviceSwitchView.h"
#import "DeviceSwitchTableViewCell.h"
@import MJExtension;
#import "AddDeviceViewController.h"
#import "GlobelDescAlertView.h"

@interface DeviceSwitchView ()<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>

@property(nonatomic,strong)UIView * contentView;
@property(nonatomic,strong)UITableView * tableView;
@property(nonatomic,strong)UITableView * otherTableView;
@property(nonatomic,strong)DevideModel * currentDevice;
@property(nonatomic,strong)NSArray<DevideModel*> * dataArray;
@property(nonatomic,strong)NSArray<DevideModel*> * searchArray;
@property(nonatomic,weak)id<DeviceSwitchViewDelegate>delegate;
@property(nonatomic,strong)UITextField * search;
@property(nonatomic,strong)UIView * normalView;

@end

@implementation DeviceSwitchView

- (UIView *)normalView{
    if (!_normalView) {
        _normalView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
        UIImageView * icon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 100, 84)];
        icon.image = [UIImage imageNamed:@"icon_empty"];
        [_normalView addSubview:icon];
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, _normalView.width, 20)];
        label.text = @"No other device";
        label.textAlignment = 1;
        label.textColor = UIColor.whiteColor;
        label.font = [UIFont systemFontOfSize:16];
        [_normalView addSubview:label];
    }
    _normalView.frame = CGRectMake(SCREEN_WIDTH/2-_normalView.width/2-15, self.otherTableView.height/2-_normalView.height/2, _normalView.width, _normalView.height);
    return _normalView;
}

+ (void)showDeviceSwitchViewWithDelegate:(id<DeviceSwitchViewDelegate>)delegate
                               dataArray:(nonnull NSArray *)dataArray{
    DeviceSwitchView * view = [[DeviceSwitchView alloc] initWithDelegate:delegate
                                                               dataArray:dataArray];
    [view show];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(nonnull UITouch *)touch{
    CGPoint point = [touch locationInView:self];
    point = [self.contentView.layer convertPoint:point fromLayer:self.layer];
    if( [self.contentView.layer containsPoint:point]){
        return false;
    }else{
        return true;
    }
}

- (instancetype)initWithDelegate:(id<DeviceSwitchViewDelegate>)delegate
                       dataArray:(nonnull NSArray *)dataArray
{
    self = [super init];
    if (self) {
        
        self.frame = UIScreen.mainScreen.bounds;
        self.alpha = 0;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        [UIApplication.sharedApplication.keyWindow addSubview:self];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
        
        [NSNotificationCenter.defaultCenter addObserverForName:UITextFieldTextDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            UITextField * textfield = note.object;
            if (textfield.text.length == 0){
                self.normalView.hidden = true;
                self.searchArray = @[];
                [self.otherTableView reloadData];
                self.normalView.hidden = self.otherTableView.visibleCells.count > 1;
            }
        }];
        
        self.delegate = delegate;
        self.dataArray = dataArray;
        CGFloat height = SCREEN_HEIGHT*0.7;
        self.contentView = [[UIView alloc] initWithFrame:CGRectMake(15, (SCREEN_HEIGHT-height)/2, SCREEN_WIDTH-30, height)];
        self.contentView.backgroundColor = [UIColor colorWithHexString:@"#1B1B1B"];
        self.contentView.layer.cornerRadius = 4;
        self.contentView.clipsToBounds = true;
        [self addSubview:self.contentView];
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundColor = UIColor.clearColor;
        self.tableView.scrollEnabled = false;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.contentView addSubview:self.tableView];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.mas_equalTo(0);
            make.width.mas_equalTo(self.contentView.width);
            make.height.mas_equalTo(self.contentView.height-56);
        }];
        
        self.otherTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.otherTableView.delegate = self;
        self.otherTableView.dataSource = self;
        self.otherTableView.backgroundColor = UIColor.clearColor;
        self.otherTableView.bounces = false;
        self.otherTableView.tableFooterView = [UIView new];
        self.otherTableView.tableHeaderView = [UIView new];
        self.otherTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        self.otherTableView.estimatedSectionFooterHeight = 0;
        [self.contentView addSubview:self.otherTableView];
        [self.otherTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.mas_equalTo(250);
            make.width.mas_equalTo(SCREEN_WIDTH-30);
            make.bottom.mas_equalTo(-74);
        }];
        
        UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 52)];
        headerView.backgroundColor = UIColor.clearColor;
        
        UILabel * label = [[UILabel alloc] init];
        [headerView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(0);
            make.left.mas_equalTo(15);
        }];
        label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        label.text = @"Switch device".localized;
        label.textColor = UIColor.whiteColor;
        
        UIButton * closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [headerView addSubview:closeButton];
        [closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
        closeButton.backgroundColor = [UIColor colorWithHexString:@"#333333"];
        closeButton.layer.cornerRadius = 12;
        [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-12);
            make.width.height.mas_equalTo(24);
            make.centerY.mas_equalTo(headerView.mas_centerY);
        }];
        self.tableView.tableHeaderView = headerView;
        
        [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([DeviceSwitchTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([DeviceSwitchTableViewCell class])];
        [self.otherTableView registerNib:[UINib nibWithNibName:NSStringFromClass([DeviceSwitchTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([DeviceSwitchTableViewCell class])];
        
        UIButton * addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:addButton];
        [addButton showBorderWithRadius:22];
        [addButton setTitle:@"Add device".localized forState:UIControlStateNormal];
        [addButton setTitleColor:[UIColor colorWithHexString:COLOR_MAIN_COLOR] forState:UIControlStateNormal];
        [addButton addTarget:self action:@selector(addDeviceClick) forControlEvents:UIControlEventTouchUpInside];
        addButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [addButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(self.contentView.mas_centerX);
            make.bottom.mas_equalTo(-15);
            make.width.mas_equalTo(200);
            make.height.mas_equalTo(44);
        }];
        
        NSArray<DevideModel*> * array = [self.dataArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"lastConnect = %@",@"1"]];
        if (array.count>0) {
            self.currentDevice = array.firstObject;
        }
        [self.tableView reloadData];
        [self.otherTableView reloadData];
        [self.otherTableView addSubview:self.normalView];
        self.normalView.hidden = self.dataArray.count > 1;
        
        CGFloat contentHeight = self.tableView.contentSize.height+self.otherTableView.contentSize.height;
        if (contentHeight < 340 + self.normalView.height){
            contentHeight = 340 + self.normalView.height;
        }
        CGFloat containerHeight = contentHeight > SCREEN_HEIGHT-90*2 ? SCREEN_HEIGHT-90*2 : contentHeight;
        self.contentView.frame = CGRectMake(15, SCREEN_HEIGHT/2-containerHeight/2, self.contentView.width, containerHeight);
        [self.contentView layoutIfNeeded];
        
    }
    return self;
}

- (void)addDeviceClick{
    if (RMHelper.isTouristsModel){
        [RMHelper showToast:@"Visitor has no permission" toView:self];
        return;
    }
    [self dismiss];
    AddDeviceViewController * add = [[AddDeviceViewController alloc] init];
    add.title = @"Add Device".localized;
    add.hidesBottomBarWhenPushed = true;
    [RMHelper.getCurrentVC.navigationController pushViewController:add animated:true];
}

- (void)getDeviceList:(void(^)(void))completion{
    [Request.shareInstance getUrl:DeviceList params:@{} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        self.dataArray = [DevideModel mj_objectArrayWithKeyValuesArray:result[@"data"]];
        NSArray<DevideModel*> * array = [self.dataArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"lastConnect = %@",@"1"]];
        if (array.count>0) {
            self.currentDevice = array.firstObject;
        }
        [self.tableView reloadData];
        [self.otherTableView reloadData];
        [self.otherTableView addSubview:self.normalView];
        self.normalView.hidden = self.dataArray.count > 1;
        completion();
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
}

- (void)closeAction{
    [self dismiss];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DeviceSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DeviceSwitchTableViewCell class]) forIndexPath:indexPath];
    DevideModel * model = tableView == self.tableView ? self.currentDevice : (self.searchArray.count==0?self.dataArray[indexPath.section]:self.searchArray[indexPath.section]);
    cell.model = model;
    cell.status.text = [model.isOnline boolValue] ? @"Online".localized : @"Offine".localized;
    cell.status.textColor = [UIColor colorWithHexString:[model.isOnline boolValue] ? COLOR_MAIN_COLOR : @"#999999"];
    cell.bgView.backgroundColor = [model.isOnline boolValue] ? [[UIColor colorWithHexString:@"#8CDFA5"] colorWithAlphaComponent:0.2] : [UIColor colorWithHexString:@"#333333"];
    [cell.switchDeviceBtn addTarget:self action:@selector(switchDeviceAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.switchDeviceBtn.hidden = tableView == self.tableView;
    return cell;
}

- (void)switchDeviceAction:(UIButton *)btn{
    if (RMHelper.isTouristsModel){
        [RMHelper showToast:@"Visitor has no permission" toView:self];
        return;
    }
    [BleManager.shareInstance disconnectPeripheral];
    DeviceSwitchTableViewCell * cell = (DeviceSwitchTableViewCell *)[[[btn superview] superview] superview];
    NSIndexPath * indexPath = [self.otherTableView indexPathForCell:cell];
    DevideModel * model = self.searchArray.count==0?self.dataArray[indexPath.section]:self.searchArray[indexPath.section];
    [self showHUDToast:@"Loading"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        Request.shareInstance.hiddenHUD = true;
        [Request.shareInstance getUrl:SwitchDevice params:@{@"id":model.deviceId} progress:^(float progress) {
                
        } success:^(NSDictionary * _Nonnull result) {
            Request.shareInstance.hiddenHUD = false;
            [self hiddenHUD];
            [NSUserDefaults.standardUserDefaults setValue:model.deviceId forKey:CURRENR_DEVID];
            [self getDeviceList:^{
                if (RMHelper.getLoadDataForBluetooth) {
                    [GlobelDescAlertView showAlertViewWithTitle:@"Tips" desc:@"Please connect the bluetooth device first" btnTitle:nil completion:nil];
                }
            }];
            [[NSNotificationCenter defaultCenter] postNotificationName:SWITCH_DEVICE_NOTIFICATION object:nil];
        } failure:^(NSString * _Nonnull errorMsg) {
            Request.shareInstance.hiddenHUD = false;
            [self hiddenHUD];
        }];
    });
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return tableView == self.tableView ? 2 : (self.search.text.length>0? self.searchArray.count:self.dataArray.count);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.tableView) {
        return section == 0 && self.currentDevice ? 1 : 0;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.otherTableView) {
        DevideModel * model = self.search.text.length > 0 ? self.searchArray[indexPath.section] : self.dataArray[indexPath.section];
        if ([model.rtuSn isEqualToString:self.currentDevice.rtuSn]) {
            return 0.01;
        }else{
            return UITableViewAutomaticDimension;
        }
    }
    return UITableViewAutomaticDimension;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (tableView == self.tableView) {
        UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, section == 0 ? 28 : 28+54)];
        headerView.backgroundColor = UIColor.clearColor;
        
        UIView * line = [[UIView alloc] initWithFrame:CGRectMake(15, 4, 2, 12)];
        line.backgroundColor = [UIColor colorWithHexString:COLOR_MAIN_COLOR];
        line.layer.cornerRadius = 1;
        [headerView addSubview:line];
        
        UILabel * label = [[UILabel alloc] init];
        [headerView addSubview:label];
        label.font = [UIFont systemFontOfSize:14];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(line.mas_left).offset(10);
                make.top.mas_equalTo(0);
            make.height.mas_equalTo(20);
        }];
        label.text = section == 0 ? @"Current device".localized : @"Other device".localized;
        label.textColor = UIColor.whiteColor;
        
        
        if (section == 1) {
            UIView * contentView = [[UIView alloc] initWithFrame:CGRectMake(15, 36, SCREEN_WIDTH-60, 32)];
            contentView.backgroundColor = [UIColor colorWithHexString:@"#1B1B1B"];
            contentView.layer.cornerRadius = 16;
            contentView.layer.borderColor = [UIColor colorWithHexString:@"#393939"].CGColor;
            contentView.layer.borderWidth = 1;
            [headerView addSubview:contentView];
            
            UIButton * searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [contentView addSubview:searchButton];
            [searchButton setTitle:@"Query".localized forState:UIControlStateNormal];
            searchButton.titleLabel.font = [UIFont systemFontOfSize:13];
            [searchButton setTitleColor:[UIColor colorWithHexString:COLOR_MAIN_COLOR] forState:UIControlStateNormal];
            [searchButton addTarget:self action:@selector(queryClick) forControlEvents:UIControlEventTouchUpInside];
            [searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.mas_equalTo(0);
                make.right.mas_equalTo(-15);
                make.width.mas_equalTo(50);
            }];
            
            UITextField * search = [[UITextField alloc] init];
            [contentView addSubview:search];
            search.placeholder = @"Search by device name or SN".localized;
            search.placeholderColor = [UIColor colorWithHexString:@"#999999"];
            search.font = [UIFont systemFontOfSize:13];
            search.keyboardType = UIKeyboardTypeDefault;
            [search mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(15);
                make.top.bottom.mas_equalTo(0);
                make.right.mas_equalTo(searchButton.mas_left).offset(-15);
            }];
            self.search = search;
        }
        
        return headerView;
    }else{
        return [UIView new];
    }
}

- (void)queryClick{
    self.searchArray = [self.dataArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name CONTAINS %@ || rtuSn CONTAINS %@ || sgSn CONTAINS %@",self.search.text,self.search.text,self.search.text]];
    [self.otherTableView reloadData];
    if (self.search.text.length > 0){
        self.normalView.hidden = self.searchArray.count > 0 || self.search.text.length == 0;
    }else{
        self.normalView.hidden = self.dataArray.count > 1;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView == self.tableView){
        return section == 0 ? 35 : 35 + 54;
    }
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return tableView == self.tableView ? 10 : 0.01;
}

- (void)show{
    [UIView animateWithDuration:0.1 animations:^{
        self.alpha = 1;
    }];
}

- (void)dismiss{
    [UIView animateWithDuration:0.1 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
