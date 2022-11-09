//
//  CompleteImageTableViewCell.m
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/10/28.
//

#import "CompleteImageTableViewCell.h"
#import "GlobelDescAlertView.h"
@import BRPickerView;
@import HXPhotoPicker;

@interface CompleteImageTableViewCell ()<HXPhotoViewCellCustomProtocol>

@property(nonatomic,strong) HXPhotoManager * manager;
@property(nonatomic,strong) HXPhotoView * photoView;
@property(nonatomic,strong) BRPickerStyle * style;

@end

@implementation CompleteImageTableViewCell

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

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.manager = [HXPhotoManager managerWithType:HXPhotoManagerSelectedTypePhoto];
    self.manager.configuration.photoMaxNum = 20;
    self.manager.configuration.themeColor = [UIColor colorWithHexString:COLOR_MAIN_COLOR];
    self.manager.configuration.navBarBackgroudColor = [UIColor colorWithHexString:COLOR_BACK_COLOR];
    self.manager.configuration.navigationTitleColor = UIColor.whiteColor;
    self.manager.configuration.statusBarStyle = UIStatusBarStyleLightContent;
    self.manager.configuration.bottomViewBgColor = [UIColor colorWithHexString:COLOR_BACK_COLOR];
    self.manager.configuration.albumListViewBgColor = [UIColor colorWithHexString:COLOR_BACK_COLOR];
    self.manager.configuration.albumListViewCellBgColor = [UIColor colorWithHexString:COLOR_BACK_COLOR];
    self.manager.configuration.rowCount = 4;
    self.manager.configuration.openCamera = false;
    self.manager.configuration.photoCanEdit = false;
    self.photoView = [HXPhotoView photoManager:self.manager];
    self.photoView.spacing = 15;
    self.photoView.interceptAddCellClick = true;
    self.photoView.collectionView.bounces = false;
    self.photoView.cellCustomProtocol = self;
    [self.contentView addSubview:self.photoView];
    HXWeakSelf;
    self.photoView.didAddCellBlock = ^(HXPhotoView * _Nonnull myPhotoView) {
        BRStringPickerView * picker = [[BRStringPickerView alloc] initWithPickerMode:BRStringPickerComponentSingle];
        picker.pickerStyle = weakSelf.style;
        picker.dataSourceArr = @[@"camera",@"photo album"];
        picker.resultModelBlock = ^(BRResultModel * _Nullable resultModel) {
            [weakSelf selectSourceType:resultModel.index];
        };
        [picker show];
    };
    [self.photoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(35);
        make.left.mas_offset(15);
        make.right.mas_equalTo(-15);
        make.bottom.mas_equalTo(0);
    }];
    self.photoView.updateFrameBlock = ^(CGRect frame) {
        NSInteger selectArrayCount = weakSelf.manager.afterSelectedCount+1;
        CGFloat space = (SCREEN_WIDTH-60)/3;
        if (weakSelf.updateFrameBlock){
            if (selectArrayCount%3 == 0){
                weakSelf.updateFrameBlock(CGRectMake(0, 0, SCREEN_WIDTH, selectArrayCount/3*(space+15)));
            }else{
                weakSelf.updateFrameBlock(CGRectMake(0, 0, SCREEN_WIDTH, (selectArrayCount/3+1)*(space+15)));
            }
        }
    };
    self.photoView.changeCompleteBlock = ^(NSArray<HXPhotoModel *> * _Nonnull allList, NSArray<HXPhotoModel *> * _Nonnull photos, NSArray<HXPhotoModel *> * _Nonnull videos, BOOL isOriginal) {
        [photos hx_requestImageWithOriginal:false completion:^(NSArray<UIImage *> * _Nullable imageArray, NSArray<HXPhotoModel *> * _Nullable errorArray) {
            weakSelf.images = imageArray;
        }];
    };
}

- (void)setPhotos:(NSArray *)photos{
    _photos = photos;
    [self.manager clearSelectedList];
    NSMutableArray * assetModels = [[NSMutableArray alloc] init];
    for (int i=0; i<photos.count; i++) {
        HXCustomAssetModel * model = [HXCustomAssetModel assetWithNetworkImageURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",Host,photos[i]]] selected:true];
        [assetModels addObject:model];
    }
    [self.manager addCustomAssetModel:assetModels];
    [self.photoView refreshView];
}

- (UIView *)customView:(HXPhotoSubViewCell *)cell
             indexPath:(NSIndexPath *)indexPath{
    cell.imageView.layer.cornerRadius = 4;
    return nil;
}

- (void)selectSourceType:(NSInteger)index{
    if (index == 1) {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied)
        {
            [GlobelDescAlertView showAlertViewWithTitle:@"Tips" desc:@"Photo album permission required, please go to setting and enable usage." btnTitle:@"Setting" completion:^{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
            }];
            return;
        }
    }else{
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];//读取设备授权状态
        if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
            [GlobelDescAlertView showAlertViewWithTitle:@"Tips" desc:@"Camera permission required, please go to setting and enable usage." btnTitle:@"Setting" completion:^{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
            }];
            return;
        }
    }
    if (index == 0){
        UIImagePickerController * picker = [[UIImagePickerController alloc] init];
        picker.sourceType = index == 0 ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate = self;
        [RMHelper.getCurrentVC presentViewController:picker animated:true completion:nil];
    }else{
        [RMHelper.getCurrentVC hx_presentSelectPhotoControllerWithManager:self.manager didDone:^(NSArray<HXPhotoModel *> * _Nullable allList, NSArray<HXPhotoModel *> * _Nullable photoList, NSArray<HXPhotoModel *> * _Nullable videoList, BOOL isOriginal, UIViewController * _Nullable viewController, HXPhotoManager * _Nullable manager) {
            [self.photoView refreshView];
        } cancel:^(UIViewController * _Nullable viewController, HXPhotoManager * _Nullable manager) {
            
        }];
    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [RMHelper.getCurrentVC dismissViewControllerAnimated:true completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info{
    UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];
    HXCustomAssetModel * model = [HXCustomAssetModel assetWithLocalImage:image selected:true];
    [self.manager addCustomAssetModel:@[model]];
    [self.photoView refreshView];
    [RMHelper.getCurrentVC dismissViewControllerAnimated:true completion:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
