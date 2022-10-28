//
//  DataViewController.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/11.
//

#import "DataViewController.h"
#import "DataCollectionViewCell.h"
#import "DataEchartsCollectionViewCell.h"
@import SGPagingView;
@import BRPickerView;
#import "DevideModel.h"
#import "GlobelDescAlertView.h"

@interface DataViewController ()<UICollectionViewDataSource,SGPageTitleViewDelegate>

@property(nonatomic,strong) SGPageTitleView * titleView;
@property(nonatomic,weak)IBOutlet UICollectionView * collectionView;
@property(nonatomic,strong) NSMutableArray * titleArray;
@property(nonatomic,strong) NSArray * valueArray;
@property(nonatomic,strong) NSArray * imageArray;
@property(nonatomic,strong) NSString * devId;
@property(nonatomic,strong) NSString * backUpType;
@property(nonatomic,strong) DevideModel * model;
@property(nonatomic,strong) NSArray * data;
@property(nonatomic,assign) NSInteger scopeType;
@property(nonatomic,strong) BRPickerStyle * style;
@property(nonatomic,strong) NSString * queryDateStr;

@end

@implementation DataViewController

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
    self.collectionView.refreshControl = self.refreshController;
    [self.refreshController addTarget:self action:@selector(getCurrentDevice) forControlEvents:UIControlEventValueChanged];
    [self setLeftBarImageForSel:nil];
    self.titleArray = [[NSMutableArray alloc] initWithArray:@[@"From grid:0 kWh".localized,@"Solar".localized,@"Generator".localized,@"EV".localized,@"Non-backup".localized,@"Backup loads".localized]];
    self.valueArray = @[[NSString stringWithFormat:@"To grid:%@",@(0)],@(0),@(0),@(0),@(0),@(0)];
    self.imageArray = @[@"data_select_0",@"data_select_1",@"data_select_2",@"data_select_3",@"data_select_4",@"data_select_5"];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([DataCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([DataCollectionViewCell class])];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([DataEchartsCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([DataEchartsCollectionViewCell class])];
    SGPageTitleViewConfigure * config = [SGPageTitleViewConfigure pageTitleViewConfigure];
    config.showBottomSeparator = false;
    config.titleColor = [UIColor colorWithHexString:@"#747474"];
    config.titleSelectedColor = [UIColor colorWithHexString:@"#00E252"];
    config.titleFont = [UIFont systemFontOfSize:14];
    config.titleSelectedFont = [UIFont systemFontOfSize:14];
    config.showIndicator = false;
    self.titleView = [SGPageTitleView pageTitleViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40) delegate:self titleNames:@[@"Day".localized,@"Month".localized,@"Year".localized,@"All".localized] configure:config];
    self.titleView.backgroundColor = [UIColor colorWithHexString:@"#1E1E1E"];
    [self.collectionView addSubview:self.titleView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (![NSUserDefaults.standardUserDefaults objectForKey:CURRENR_DEVID]) {
        [GlobelDescAlertView showAlertViewWithTitle:@"Tips" desc:@"Please add device to continue" btnTitle:nil completion:nil];
        return;
    }
    [self getCurrentDevice];
}

- (void)pageTitleView:(SGPageTitleView *)pageTitleView selectedIndex:(NSInteger)selectedIndex{
    if (selectedIndex == 3){
        [self getCurrentDevice];
    }else{
        BRDatePickerView * picker = [[BRDatePickerView alloc] initWithPickerMode:selectedIndex == 0 ? BRDatePickerModeYMD : (selectedIndex == 1 ? BRDatePickerModeYM : BRDatePickerModeY)];
        picker.showUnitType = BRShowUnitTypeNone;
        picker.pickerStyle = self.style;
        picker.resultBlock = ^(NSDate * _Nullable selectDate, NSString * _Nullable selectValue) {
            self.queryDateStr = selectValue;
            [self getCurrentDevice];
        };
        [picker show];
    }
}

- (void)getCurrentDevice{
    [self.refreshController endRefreshing];
    [Request.shareInstance getUrl:DeviceList params:@{} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        NSArray * modelArray = [DevideModel mj_objectArrayWithKeyValuesArray:result[@"data"]];
        NSArray<DevideModel*> * array = [modelArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"lastConnect = %@",@"1"]];
        if (array.count > 0) {
            self.devId = array.firstObject.deviceId;
            [self getHomeData:array.firstObject.sgSn];
        }
    } failure:^(NSString * _Nonnull errorMsg) {
        [self.refreshController endRefreshing];
    }];
}

- (void)getHomeData:(NSString *)sgSn{
    NSDate * date = [NSDate date];
    [Request.shareInstance getUrl:HomeDeviceInfo params:@{@"sgSn":sgSn,@"dayMonthYearFormat":[NSString stringWithFormat:@"%ld-%02ld-%02ld",date.br_year,date.br_month,date.br_day]} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        DevideModel * model = [DevideModel mj_objectWithKeyValues:result[@"data"]];
        self.backUpType = model.backUpType;
        [self getDataWithScopeType:self.titleView.selectedIndex==3?0:self.titleView.selectedIndex+1];
    } failure:^(NSString * _Nonnull errorMsg) {
    
    }];
}

- (void)getDataWithScopeType:(NSInteger)scopeType{
    self.scopeType = scopeType;
    /// 0-全部 1-天 2-月 3-年
    NSDate * date = [NSDate date];
    NSString * startDateTime = @"";
    if (scopeType == 2){
        NSDate *currentDate = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *lastMonthComps = [[NSDateComponents alloc] init];
        [lastMonthComps setMonth:-1];
        [lastMonthComps setDay:1];
        NSDate *newdate = [calendar dateByAddingComponents:lastMonthComps toDate:currentDate options:0];
        NSString *dateStr = [formatter stringFromDate:newdate];
        startDateTime = dateStr;
    }else if (scopeType == 3){
        NSDate *currentDate = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *lastMonthComps = [[NSDateComponents alloc] init];
        [lastMonthComps setYear:-1];
        [lastMonthComps setMonth:1];
        NSDate *newdate = [calendar dateByAddingComponents:lastMonthComps toDate:currentDate options:0];
        NSString *dateStr = [formatter stringFromDate:newdate];
        startDateTime = dateStr;
    }else{
        startDateTime = [NSString stringWithFormat:@"%ld-%02ld-%02ld",date.br_year,date.br_month,date.br_day];
    }
    NSString * currentDateTime = [NSString stringWithFormat:@"%ld-%02ld-%02ld",date.br_year,date.br_month,date.br_day];
    [Request.shareInstance getUrl:QueryDataElectricity params:@{@"devId":self.devId,@"scopeType":[NSString stringWithFormat:@"%ld",scopeType],@"currentDateTime":currentDateTime,@"startDateTime":startDateTime} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        self.model = [DevideModel mj_objectWithKeyValues:result[@"data"]];
        if (self.backUpType.intValue == 1) {
            self.imageArray = @[@"data_select_0",@"data_select_1",@"data_select_2",@"data_select_3",@"data_select_5"];
            self.titleArray = [[NSMutableArray alloc] initWithArray:@[[NSString stringWithFormat:@"From grid:%.02f kWh",self.model.gridElectricityFrom],@"Solar".localized,@"Generator".localized,@"EV".localized,@"Backup loads".localized]];
            self.valueArray = @[[NSString stringWithFormat:@"To grid:%.02f",self.model.gridElectricityTo],@(self.model.solarElectricity),@(self.model.generatorElectricity),@(self.model.evElectricity),@(self.model.backUpElectricity)];
        }else{
            self.imageArray = @[@"data_select_0",@"data_select_1",@"data_select_2",@"data_select_3",@"data_select_4",@"data_select_5"];
            self.titleArray = [[NSMutableArray alloc] initWithArray:@[[NSString stringWithFormat:@"From grid:%.02f kWh",self.model.gridElectricityFrom],@"Solar".localized,@"Generator".localized,@"EV".localized,@"Non-backup".localized,@"Backup loads".localized]];
            self.valueArray = @[[NSString stringWithFormat:@"To grid:%.02f",self.model.gridElectricityTo],@(self.model.solarElectricity),@(self.model.generatorElectricity),@(self.model.evElectricity),@(self.model.nonBackUpElectricity),@(self.model.backUpElectricity)];
        }
        [self.refreshController endRefreshing];
        [self.collectionView reloadData];
        [self getEcharsDataWithScopeType:scopeType currentDateTime:currentDateTime startDateTime:startDateTime];
    } failure:^(NSString * _Nonnull errorMsg) {
        [self.refreshController endRefreshing];
    }];
}

- (void)getEcharsDataWithScopeType:(NSInteger)scopeType currentDateTime:(NSString *)currentDateTime startDateTime:(NSString *)startDateTime{
    [Request.shareInstance getUrl:QueryDataGraph params:@{@"devId":self.devId,@"scopeType":[NSString stringWithFormat:@"%ld",scopeType],@"currentDateTime":currentDateTime,@"startDateTime":startDateTime} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        self.data = result[@"data"];
        [self.collectionView reloadData];
        [self.refreshController endRefreshing];
    } failure:^(NSString * _Nonnull errorMsg) {
        [self.refreshController endRefreshing];
    }];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        DataCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([DataCollectionViewCell class]) forIndexPath:indexPath];
        cell.icon.image = [UIImage imageNamed:self.imageArray[indexPath.row]];
        cell.titleLabel.text = self.titleArray[indexPath.row];
        if (indexPath.row == 0) {
            cell.descLabel.text = [NSString stringWithFormat:@"%@ kWh",self.valueArray[indexPath.row]];
        }else{
            cell.descLabel.text = [NSString stringWithFormat:@"%.02f kWh",[self.valueArray[indexPath.row] floatValue]];
        }
        cell.titleLabel.font = [UIFont systemFontOfSize:indexPath.row == 0 ? 9 : 12];
        cell.descLabel.font = [UIFont systemFontOfSize:indexPath.row == 0 ? 9 : 12];
        return cell;
    }else{
        DataEchartsCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([DataEchartsCollectionViewCell class]) forIndexPath:indexPath];
        cell.time = self.titleView.selectedIndex;
        cell.dataArray = self.data;
        cell.selfHelpRate.text = [[NSString stringWithFormat:@"%.0f",self.model.selfHelpRate] stringByAppendingString:@"%"];
        cell.treeNum.text = [NSString stringWithFormat:@"%.0f",self.model.treeNum];
        cell.coalValue.text = [NSString stringWithFormat:@"%.1f",self.model.coal];
        cell.scopeType = self.scopeType;
        cell.backUpType = self.backUpType;
        return cell;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return section == 0 ? self.titleArray.count : 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.section == 0 ? CGSizeMake((SCREEN_WIDTH-50)/3, 110) : CGSizeMake(SCREEN_WIDTH, 430);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return section == 0 ? UIEdgeInsetsMake(55, 15, 0, 15) : UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
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
