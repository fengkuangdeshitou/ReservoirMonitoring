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

@interface DataViewController ()<UICollectionViewDataSource,SGPageTitleViewDelegate>

@property(nonatomic,strong) SGPageTitleView * titleView;
@property(nonatomic,weak)IBOutlet UICollectionView * collectionView;
@property(nonatomic,strong) NSMutableArray * titleArray;
@property(nonatomic,strong) NSArray * valueArray;
@property(nonatomic,strong) NSArray * imageArray;
@property(nonatomic,strong) NSString * devId;
@property(nonatomic,strong) DevideModel * model;
@property(nonatomic,strong) NSArray * data;

@end

@implementation DataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self getCurrentDevice];
    [self setLeftBatButtonItemWithImage:[UIImage imageNamed:@"logo"] sel:nil];
    self.titleArray = [[NSMutableArray alloc] initWithArray:@[@"From grid:0 kWh".localized,@"Solar".localized,@"Generator".localized,@"EV".localized,@"Non-backup".localized,@"Backup loads".localized]];
    self.imageArray = @[@"icon_grid_active",@"icon_solar_active",@"icon_generator_active",@"icon_ev_active",@"icon_non_backup_active",@"icon_backup_active"];
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

- (void)pageTitleView:(SGPageTitleView *)pageTitleView selectedIndex:(NSInteger)selectedIndex{
    if (!self.devId) {
        return;
    }
    [self getDataWithScopeType:selectedIndex == 3 ? 0 : (selectedIndex+1)];
    [self.collectionView reloadData];
}

- (void)getCurrentDevice{
    [Request.shareInstance getUrl:DeviceList params:@{} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        NSArray * modelArray = [DevideModel mj_objectArrayWithKeyValuesArray:result[@"data"]];
        NSArray<DevideModel*> * array = [modelArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"lastConnect = %@",@"1"]];
        self.devId = array.firstObject.deviceId;
        [self getDataWithScopeType:1];
    } failure:^(NSString * _Nonnull errorMsg) {

    }];
}

- (void)getDataWithScopeType:(NSInteger)scopeType{
    /// 0-全部 1-天 2-月 3-年
    NSDate * date = [NSDate date];
    NSString * formatter = @"";
    if (scopeType <= 1) {
        formatter = [NSString stringWithFormat:@"%ld-%02ld-%02ld",date.br_year,date.br_month,date.br_day];
    }else if (scopeType == 2){
        formatter = [NSString stringWithFormat:@"%ld-%02ld",date.br_year,date.br_month];
    }else if (scopeType == 3){
        formatter = [NSString stringWithFormat:@"%ld",date.br_year];
    }
    [self getEcharsDataWithScopeType:scopeType dateTimeFormatter:formatter];
    [Request.shareInstance getUrl:QueryDataElectricity params:@{@"devId":self.devId,@"scopeType":[NSString stringWithFormat:@"%ld",scopeType],@"dateTimeFormatter":formatter} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        self.model = [DevideModel mj_objectWithKeyValues:result[@"data"]];
        [self.titleArray replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@"From grid:%.0f kWh",self.model.gridElectricityQd]];
        self.valueArray = @[@(self.model.gridElectricityFd),@(self.model.solarElectricity),@(self.model.generatorElectricity),@(self.model.evElectricity),@(self.model.nonBackUpElectricity),@(self.model.backUpElectricity)];
        [self.collectionView reloadData];
    } failure:^(NSString * _Nonnull errorMsg) {

    }];
}

- (void)getEcharsDataWithScopeType:(NSInteger)scopeType dateTimeFormatter:(NSString *)dateTimeFormatter{
    [Request.shareInstance getUrl:QueryDataGraph params:@{@"devId":self.devId,@"scopeType":[NSString stringWithFormat:@"%ld",scopeType],@"dateTimeFormatter":dateTimeFormatter} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        self.data = result[@"data"];
        [self.collectionView reloadData];
    } failure:^(NSString * _Nonnull errorMsg) {

    }];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        DataCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([DataCollectionViewCell class]) forIndexPath:indexPath];
        cell.icon.image = [UIImage imageNamed:self.imageArray[indexPath.row]];
        cell.titleLabel.text = self.titleArray[indexPath.row];
        cell.descLabel.text = [NSString stringWithFormat:@"%@ kWh",!self.valueArray[indexPath.row]?@"0":self.valueArray[indexPath.row]];
        cell.titleLabel.font = [UIFont systemFontOfSize:indexPath.row == 0 ? 9 : 12];
        cell.descLabel.font = [UIFont systemFontOfSize:indexPath.row == 0 ? 9 : 12];
        return cell;
    }else{
        DataEchartsCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([DataEchartsCollectionViewCell class]) forIndexPath:indexPath];
        cell.time = self.titleView.selectedIndex;
        cell.dataArray = self.data;
        cell.selfHelpRate.text = [[NSString stringWithFormat:@"%.0f",self.model.selfHelpRate] stringByAppendingString:@"%"];
        cell.treeNum.text = [NSString stringWithFormat:@"%.1f",self.model.treeNum];
        cell.coalValue.text = [NSString stringWithFormat:@"%.0f",self.model.coal];
        return cell;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return section == 0 ? 6 : 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.section == 0 ? CGSizeMake((SCREEN_WIDTH-50)/3, 100) : CGSizeMake(SCREEN_WIDTH, 430);
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
