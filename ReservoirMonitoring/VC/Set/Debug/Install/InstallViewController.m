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
#import "CardViewController.h"
#import "CompleteImageTableViewCell.h"
#import "CompletePhoneTableViewCell.h"
#import "ServiceInputTableViewCell.h"
#import "GlobelDescAlertView.h"

@interface InstallViewController ()<UITextFieldDelegate>

@property(nonatomic,weak)IBOutlet UITableView * tableView;
@property(nonatomic,weak)IBOutlet UICollectionView * collectionView;
@property(nonatomic,weak)IBOutlet UIButton * config;
@property(nonatomic,weak)IBOutlet NSLayoutConstraint * configBtnHeight;
@property(nonatomic,weak)IBOutlet NSLayoutConstraint * configBtnTop;
@property(nonatomic,weak)IBOutlet UIButton * back;
@property(nonatomic,weak)IBOutlet UIButton * next;
@property(nonatomic,strong) NSArray * dataArray;
@property(nonatomic,assign) NSInteger current;
@property(nonatomic,assign) CGFloat imageHeight;
@property(nonatomic,strong) NSMutableArray * urlArray;
@property(nonatomic,strong) NSString * auditStatus;
@property(nonatomic,strong) NSArray * photos;
@property(nonatomic,strong) NSString * remark;
@property(nonatomic,strong) NSString * appUserPhone;

@end

@implementation InstallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.dataArray = @[@"Add Device".localized,@"Bluetooth config".localized,@"Grid config".localized,@"Smart Gateway config".localized,@"Hybrid config".localized,@"Card config".localized,@"Wi-Fi config".localized,@"Finish"];
    [self.config showBorderWithRadius:25];
    [self.next showBorderWithRadius:25];
    [self.back showBorderWithRadius:25];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addDeviceSuccess) name:ADD_DEVICE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserverForName:UPDATE_RESS_NOTIFICATION object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self.navigationController popToViewController:self animated:true];
    }];
    [self.config setTitle:@"Config".localized forState:UIControlStateNormal];
    [self.next setTitle:@"Next".localized forState:UIControlStateNormal];
    [self.back setTitle:@"Back".localized forState:UIControlStateNormal];
    [self loadBackBtnStyle];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([InstallCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([InstallCollectionViewCell class])];
    self.imageHeight = (SCREEN_WIDTH-15*2)/3;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([CompleteImageTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([CompleteImageTableViewCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([CompletePhoneTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([CompletePhoneTableViewCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ServiceInputTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([ServiceInputTableViewCell class])];
}

- (void)loadBackBtnStyle{
    if (self.current == 0){
        [self.back setTitleColor:[UIColor colorWithHexString:@"#999999"] forState:UIControlStateNormal];
        self.back.layer.borderColor = self.back.titleLabel.textColor.CGColor;
        self.back.userInteractionEnabled = false;
    }else{
        [self.back setTitleColor:[UIColor colorWithHexString:COLOR_MAIN_COLOR] forState:UIControlStateNormal];
        self.back.layer.borderColor = self.back.titleLabel.textColor.CGColor;
        self.back.userInteractionEnabled = true;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSInteger existedLength = textField.text.length;
    NSInteger selectedLength = range.length;
    NSInteger replaceLength = string.length;
    NSInteger pointLength = existedLength - selectedLength + replaceLength;
    if (pointLength > 11) {
        return NO;
    }else{
        return true;
    }
}

- (void)queryInstallLogInfoCompletion:(void(^)(NSDictionary * resule))completion{
    NSDictionary * params = @{};
    if (self.installLogId){
        params = @{@"installLogId":self.installLogId};
    }else{
        params = @{@"deviceId":[NSUserDefaults.standardUserDefaults objectForKey:CURRENR_DEVID]};
    }
    [Request.shareInstance getUrl:QueryInstallLogInfo params:params progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        completion(result);
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
}

- (void)addDeviceSuccess{
    [self.navigationController popToViewController:self animated:true];
}

- (IBAction)configAction:(id)sender{
    if (self.current > 0 && self.current<self.dataArray.count-1 && ![NSUserDefaults.standardUserDefaults objectForKey:CURRENR_DEVID]){
        [GlobelDescAlertView showAlertViewWithTitle:@"Tips" desc:@"Please add device to continue" btnTitle:nil completion:nil];
        return;
    }
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
        HybridViewController * hybrid = [[HybridViewController alloc] init];
        hybrid.title = self.dataArray[self.current];
        [self.navigationController pushViewController:hybrid animated:true];
    }
//    else if (self.current == 4){
//        GeneratorViewController * generator = [[GeneratorViewController alloc] init];
//        generator.title = self.dataArray[self.current];
//        [self.navigationController pushViewController:generator animated:true];
//    }
    else if (self.current == 4){
        InverterViewController * inverter = [[InverterViewController alloc] init];
        inverter.title = self.dataArray[self.current];
        [self.navigationController pushViewController:inverter animated:true];
    }else if (self.current == 5){
        CardViewController * card = [[CardViewController alloc] init];
        card.title = @"Card config".localized;
        card.hidesBottomBarWhenPushed = true;
        [self.navigationController pushViewController:card animated:true];
    }else if (self.current == 6){
        WifiViewController * wifi = [[WifiViewController alloc] init];
        wifi.title = @"Wi-Fi Config".localized;
        wifi.devId = [NSUserDefaults.standardUserDefaults objectForKey:CURRENR_DEVID];
        wifi.hidesBottomBarWhenPushed = true;
        [self.navigationController pushViewController:wifi animated:true];
    }else if (self.current == 7){
        [self submitInstallAction];
    }
}

- (void)submitInstallAction{
    CompleteImageTableViewCell * imageCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    CompletePhoneTableViewCell * phoneCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    ServiceInputTableViewCell * descCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    if (imageCell.images.count == 0){
        [RMHelper showToast:@"Please add pictures" toView:self.view];
        return;
    }
    if (phoneCell.textfield.text.length == 0){
        [RMHelper showToast:@"Please input User phone" toView:self.view];
        return;
    }
    [UIApplication.sharedApplication.keyWindow showHUDToast:@"Loading"];
    [self uploadImages:imageCell.images completion:^(NSString *url) {
        [self submitInstallLog:@{@"deviceId":[NSUserDefaults.standardUserDefaults objectForKey:CURRENR_DEVID],@"photos":url,@"phone":[NSString stringWithFormat:@"%@-%@",phoneCell.phone.text,phoneCell.textfield.text],@"remark":descCell.content.text?:@""}];
    }];
}

- (void)uploadImages:(NSArray *)images completion:(void(^)(NSString * url))completion{
    [Request.shareInstance upload:[NSString stringWithFormat:@"%@/%@",BatchUpload,DEVICEINSTALLIMG] params:@{} images:images progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        [UIApplication.sharedApplication.keyWindow hiddenHUD];
        NSArray * urls = result[@"data"];
        completion([urls componentsJoinedByString:@","]);
    } failure:^(NSString * _Nonnull errorMsg) {
        [UIApplication.sharedApplication.keyWindow hiddenHUD];
    }];
}

- (void)submitInstallLog:(NSDictionary *)params{
    [Request.shareInstance postUrl:SubmitInstall params:params progress:^(float progress) {
        
    } success:^(NSDictionary * _Nonnull result) {
        [UIApplication.sharedApplication.keyWindow hiddenHUD];
        [RMHelper showToast:result[@"message"] toView:self.view];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:true];
        });
    } failure:^(NSString * _Nonnull errorMsg) {
        [UIApplication.sharedApplication.keyWindow hiddenHUD];
    }];
}

- (IBAction)nextAction:(id)sender{
    if (self.current == self.dataArray.count -2 && ![NSUserDefaults.standardUserDefaults objectForKey:CURRENR_DEVID]){
        [GlobelDescAlertView showAlertViewWithTitle:@"Tips" desc:@"Please add device to continue" btnTitle:nil completion:nil];
        return;
    }
    if (self.current == self.dataArray.count-1) {
        [self.navigationController popViewControllerAnimated:true];
    }else{
        if (self.current == self.dataArray.count - 2){
            [self queryInstallLogInfoCompletion:^(NSDictionary *result) {
                if ([result[@"data"] isKindOfClass:[NSDictionary class]]){
                    self.appUserPhone = result[@"data"][@"appUserPhone"];
                    self.auditStatus = result[@"data"][@"auditStatus"];
                    NSString * photos = result[@"data"][@"photos"];
                    self.photos = [photos componentsSeparatedByString:@","];
                    self.remark = result[@"data"][@"remark"];
                    if (self.auditStatus.intValue != 2){
                        self.config.layer.borderColor = [UIColor colorWithHexString:@"#999999"].CGColor;
                        [self.config setTitleColor:[UIColor colorWithHexString:@"#999999"] forState:UIControlStateNormal];
                        self.config.userInteractionEnabled = false;
                    }
                    [self.tableView reloadData];
                }
            }];
        }
        self.current++;
        [self loadBackBtnStyle];
        [self.tableView reloadData];
        [self.collectionView reloadData];
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.current inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:true];
        if (self.current == self.dataArray.count-1) {
            [self.config setTitle:@"Submit" forState:UIControlStateNormal];
            [self.next setTitle:@"Finish".localized forState:UIControlStateNormal];
        }
    }
}

- (IBAction)backAction:(id)sender{
    [self.config setTitle:@"Config" forState:UIControlStateNormal];
    [self.config setTitleColor:[UIColor colorWithHexString:COLOR_MAIN_COLOR] forState:UIControlStateNormal];
    [self.config showBorderWithRadius:25];
    [self.next setTitle:@"Next".localized forState:UIControlStateNormal];
    if (self.current == 0) {
        return;
    }
    self.current--;
    [self loadBackBtnStyle];
    [self.tableView reloadData];
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
    return CGSizeMake(SCREEN_WIDTH/3+20, 100);
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0){
        CompleteImageTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CompleteImageTableViewCell class]) forIndexPath:indexPath];
        cell.photos = self.photos;
        cell.updateFrameBlock = ^(CGRect frame){
            [tableView beginUpdates];
            self.imageHeight = frame.size.height;
            [tableView endUpdates];
        };
        cell.contentView.userInteractionEnabled = !self.auditStatus || self.auditStatus.intValue == 2;
        return cell;
    }else if (indexPath.row == 1){
        CompletePhoneTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CompletePhoneTableViewCell class]) forIndexPath:indexPath];
        if (self.appUserPhone){
            if ([self.appUserPhone containsString:@"-"]){
                cell.phone.text = [self.appUserPhone componentsSeparatedByString:@"-"].firstObject;
                cell.textfield.text = [self.appUserPhone componentsSeparatedByString:@"-"].lastObject;
            }else{
                cell.textfield.text = self.appUserPhone;
            }
        }
        cell.textfield.delegate = self;
        cell.textfield.userInteractionEnabled = !self.auditStatus || self.auditStatus.intValue == 2;
        cell.codeBtn.userInteractionEnabled = !self.auditStatus || self.auditStatus.intValue == 2;
        return cell;
    }else{
        ServiceInputTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ServiceInputTableViewCell class]) forIndexPath:indexPath];
        cell.titleLabel.text = @"Description";
        cell.content.text = self.remark;
        cell.content.userInteractionEnabled = !self.auditStatus || self.auditStatus.intValue == 2;
        return cell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.current == self.dataArray.count - 1 ? 3 : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0){
        return self.imageHeight+35;
    }else if (indexPath.row == 1){
        return 70;
    }else{
        return 156;
    }
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
