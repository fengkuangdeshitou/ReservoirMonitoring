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

@interface DataViewController ()<UICollectionViewDataSource,SGPageTitleViewDelegate>

@property(nonatomic,strong) SGPageTitleView * titleView;
@property(nonatomic,weak)IBOutlet UICollectionView * collectionView;
@property(nonatomic,strong) NSArray * titleArray;
@property(nonatomic,strong) NSArray * imageArray;
@end

@implementation DataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setLeftBatButtonItemWithImage:[UIImage imageNamed:@"logo"] sel:nil];
    self.titleArray = @[@"From grid:6 kWh".localized,@"Solar".localized,@"Generator".localized,@"EV".localized,@"Other loads".localized,@"Backup loads".localized];;
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

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        DataCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([DataCollectionViewCell class]) forIndexPath:indexPath];
        cell.icon.image = [UIImage imageNamed:self.imageArray[indexPath.row]];
        cell.titleLabel.text = self.titleArray[indexPath.row];
        cell.descLabel.text = @"0 kWh";
        cell.titleLabel.font = [UIFont systemFontOfSize:indexPath.row == 0 ? 9 : 12];
        cell.descLabel.font = [UIFont systemFontOfSize:indexPath.row == 0 ? 9 : 12];
        return cell;
    }else{
        DataEchartsCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([DataEchartsCollectionViewCell class]) forIndexPath:indexPath];
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
