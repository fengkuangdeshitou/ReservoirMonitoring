//
//  InstallViewController.m
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/5/19.
//

#import "InstallViewController.h"
#import "InstallCollectionViewCell.h"
#import "AddDeviceViewController.h"
#import "NetworkViewController.h"
#import "GridViewController.h"
#import "InverterViewController.h"
#import "GeneratorViewController.h"
#import "HybridViewController.h"
#import "WifiViewController.h"

@interface InstallViewController ()

@property(nonatomic,weak)IBOutlet UICollectionView * collectionView;
@property(nonatomic,weak)IBOutlet UIButton * config;
@property(nonatomic,weak)IBOutlet UIButton * next;
@property(nonatomic,strong) NSArray * dataArray;
@property(nonatomic,assign) NSInteger current;

@end

@implementation InstallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.dataArray = @[@"Add Device".localized,@"BLE connection".localized,@"Grid config".localized,@"Inverter config".localized,@"Generator config".localized,@"Hybrid config".localized,@"NetworK".localized];
    [self.config showBorderWithRadius:25];
    [self.next showBorderWithRadius:25];
    [self.config setTitle:@"Config".localized forState:UIControlStateNormal];
    [self.next setTitle:@"Next".localized forState:UIControlStateNormal];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([InstallCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([InstallCollectionViewCell class])];
}

- (IBAction)configAction:(id)sender{
    if (self.current == 0) {
        AddDeviceViewController * add = [[AddDeviceViewController alloc] init];
        add.title = self.dataArray[self.current];
        [self.navigationController pushViewController:add animated:true];
    }else if (self.current == 1){
        NetworkViewController * network = [[NetworkViewController alloc] init];
        network.title = self.dataArray[self.current];
        network.hidesBottomBarWhenPushed = true;
        [self.navigationController pushViewController:network animated:true];
    }else if (self.current == 2){
        GridViewController * grid = [[GridViewController alloc] init];
        grid.title = self.dataArray[self.current];
        [self.navigationController pushViewController:grid animated:true];
    }else if (self.current == 3){
        InverterViewController * inverter = [[InverterViewController alloc] init];
        inverter.title = self.dataArray[self.current];
        [self.navigationController pushViewController:inverter animated:true];
    }else if (self.current == 4){
        GeneratorViewController * generator = [[GeneratorViewController alloc] init];
        generator.title = self.dataArray[self.current];
        [self.navigationController pushViewController:generator animated:true];
    }else if (self.current == 5){
        HybridViewController * hybrid = [[HybridViewController alloc] init];
        hybrid.title = self.dataArray[self.current];
        [self.navigationController pushViewController:hybrid animated:true];
    }else if (self.current == 6){
        WifiViewController * wifi = [[WifiViewController alloc] init];
        wifi.title = @"Wi-Fi".localized;
        wifi.hidesBottomBarWhenPushed = true;
        [self.navigationController pushViewController:wifi animated:true];
    }
}

- (IBAction)nextAction:(id)sender{
    if (self.current == self.dataArray.count-1) {
        return;
    }
    self.current++;
    [self.collectionView reloadData];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.current inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:true];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    InstallCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([InstallCollectionViewCell class]) forIndexPath:indexPath];
    cell.indexLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row+1];
    cell.titleLabel.text = self.dataArray[indexPath.row];
    
    cell.leftLine.hidden = indexPath.row == 0;
    cell.rightLine.hidden = indexPath.row == self.dataArray.count-1;
    if (indexPath.row<=self.current) {
        cell.indexLabel.backgroundColor = [UIColor colorWithHexString:COLOR_MAIN_COLOR];
    }else{
        cell.indexLabel.backgroundColor = [UIColor colorWithHexString:@"#999999"];
    }
    if (indexPath.row < self.current) {
        cell.leftLine.backgroundColor = [UIColor colorWithHexString:COLOR_MAIN_COLOR];
        cell.rightLine.backgroundColor = [UIColor colorWithHexString:COLOR_MAIN_COLOR];
    }else if (indexPath.row == self.current){
        cell.leftLine.backgroundColor = [UIColor colorWithHexString:COLOR_MAIN_COLOR];
        cell.rightLine.backgroundColor = [UIColor whiteColor];
    }else{
        cell.leftLine.backgroundColor = UIColor.whiteColor;
        cell.rightLine.backgroundColor = UIColor.whiteColor;
    }
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(SCREEN_WIDTH/3, 100);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
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
