//
//  DebugViewController.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/19.
//

#import "DebugViewController.h"
#import "DebugCollectionViewCell.h"
#import "GridViewController.h"
#import "InverterViewController.h"
#import "GeneratorViewController.h"
#import "HybridViewController.h"
#import "OtherViewController.h"
#import "CardViewController.h"
#import "InstallViewController.h"

@interface DebugViewController ()<UICollectionViewDelegate>

@property(nonatomic,weak)IBOutlet UICollectionView * collectionView;
@property(nonatomic,strong) NSArray * dataArray;

@end

@implementation DebugViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.dataArray = @[@"Installation".localized,@"Grid config".localized,@"SG config".localized,@"Hybrid Config".localized,@"Card config".localized,@"Other config".localized];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([DebugCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([DebugCollectionViewCell class])];
    [[NSNotificationCenter defaultCenter] addObserverForName:UPDATE_RESS_NOTIFICATION object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self.navigationController popToViewController:self animated:true];
    }];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    DebugCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([DebugCollectionViewCell class]) forIndexPath:indexPath];
    cell.titleLabel.text = self.dataArray[indexPath.row];
    cell.icon.image = [UIImage imageNamed:[NSString stringWithFormat:@"debug%ld",indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString * title = self.dataArray[indexPath.row];
    if (indexPath.row == 0) {
        InstallViewController * install = [[InstallViewController alloc] init];
        install.title = title;
        [self.navigationController pushViewController:install animated:true];
    }else if (indexPath.row == 1){
        GridViewController * grid = [[GridViewController alloc] init];
        grid.title = title;
        [self.navigationController pushViewController:grid animated:true];
    }else if (indexPath.row == 2){
        HybridViewController * hybrid = [[HybridViewController alloc] init];
        hybrid.title = title;
        [self.navigationController pushViewController:hybrid animated:true];
    }
//    else if (indexPath.row == 3){
//        GeneratorViewController * generator = [[GeneratorViewController alloc] init];
//        generator.title = title;
//        [self.navigationController pushViewController:generator animated:true];
//    }
    else if (indexPath.row == 3){
        InverterViewController * inverter = [[InverterViewController alloc] init];
        inverter.title = title;
        [self.navigationController pushViewController:inverter animated:true];
    }else if (indexPath.row == 4){
        CardViewController * card = [[CardViewController alloc] init];
        card.title = title;
        [self.navigationController pushViewController:card animated:true];
    }else if (indexPath.row == 5){
        OtherViewController * other = [[OtherViewController alloc] init];
        other.title = title;
        [self.navigationController pushViewController:other animated:true];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((SCREEN_WIDTH-15*2-15)/2, 130);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(15, 15, 15, 15);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 15;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 15;
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
