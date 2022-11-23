//
//  CompleteImageTableViewCell.m
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/10/28.
//

#import "CompleteImageTableViewCell.h"
#import "GlobelDescAlertView.h"
#import "SelectImageCollectionViewCell.h"
@import BRPickerView;
@import HXPhotoPicker;

@interface CompleteImageTableViewCell ()<HXPhotoViewCellCustomProtocol,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property(nonatomic,weak)IBOutlet UICollectionView * collectionView;
@property(nonatomic,strong) HXPhotoManager * manager;
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
    self.images = [[NSMutableArray alloc] init];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([SelectImageCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([SelectImageCollectionViewCell class])];
}

- (void)setPhotos:(NSArray *)photos{
    _photos = photos;
    [self.images removeAllObjects];
    for (int i=0; i<photos.count; i++) {
        NSString * model = [NSString stringWithFormat:@"%@/%@",Host,photos[i]];
        [self.images addObject:model];
    }
    [self updateCollectionViewHeight];
    [self.collectionView reloadData];
}

- (void)updateCollectionViewHeight{
    NSInteger selectArrayCount = self.images.count+1;
    CGFloat space = (SCREEN_WIDTH-60)/3;
    if (self.updateFrameBlock){
        if (selectArrayCount%3 == 0){
            self.updateFrameBlock(CGRectMake(0, 0, SCREEN_WIDTH, selectArrayCount/3*(space+15)));
        }else{
            self.updateFrameBlock(CGRectMake(0, 0, SCREEN_WIDTH, (selectArrayCount/3+1)*(space+15)));
        }
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SelectImageCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([SelectImageCollectionViewCell class]) forIndexPath:indexPath];
    if (indexPath.row == self.images.count){
        cell.addView.hidden = false;
    }else{
        id obj = self.images[indexPath.row];
        if ([obj isKindOfClass:[UIImage class]]){
            cell.icon.image = obj;
        }else{
            [cell.icon sd_setImageWithURL:[NSURL URLWithString:obj] placeholderImage:nil completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                if (image){
                    [self.images replaceObjectAtIndex:indexPath.row withObject:image];
                }
            }];
        }
        cell.addView.hidden = true;
    }
    cell.deleteBtn.tag = indexPath.row+10;
    [cell.deleteBtn addTarget:self action:@selector(deleteImageAction:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)deleteImageAction:(UIButton *)btn{
    [self.images removeObjectAtIndex:btn.tag-10];
    [self updateCollectionViewHeight];
    [self.collectionView reloadData];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.images.count){
        [RMHelper.getCurrentVC.view endEditing:true];
        BRStringPickerView * picker = [[BRStringPickerView alloc] initWithPickerMode:BRStringPickerComponentSingle];
        picker.pickerStyle = self.style;
        picker.dataSourceArr = @[@"camera",@"photo album"];
        picker.resultModelBlock = ^(BRResultModel * _Nullable resultModel) {
            [self selectSourceType:resultModel.index];
        };
        [picker show];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.images.count < 20 ? self.images.count+1 : 20;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((SCREEN_WIDTH-15*4)/3, (SCREEN_WIDTH-15*4)/3);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 15, 0, 15);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 15;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 15;
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
        [self.manager clearSelectedList];
        self.manager.configuration.photoMaxNum = 20-self.images.count;
        [RMHelper.getCurrentVC hx_presentSelectPhotoControllerWithManager:self.manager didDone:^(NSArray<HXPhotoModel *> * _Nullable allList, NSArray<HXPhotoModel *> * _Nullable photoList, NSArray<HXPhotoModel *> * _Nullable videoList, BOOL isOriginal, UIViewController * _Nullable viewController, HXPhotoManager * _Nullable manager) {
            [photoList hx_requestImageWithOriginal:false completion:^(NSArray<UIImage *> * _Nullable imageArray, NSArray<HXPhotoModel *> * _Nullable errorArray) {
                [self.images addObjectsFromArray:imageArray];
                [self updateCollectionViewHeight];
                [self.collectionView reloadData];
            }];
        } cancel:^(UIViewController * _Nullable viewController, HXPhotoManager * _Nullable manager) {
            
        }];
    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [RMHelper.getCurrentVC dismissViewControllerAnimated:true completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info{
    UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.images addObject:image];
    [self updateCollectionViewHeight];
    [self.collectionView reloadData];
    [RMHelper.getCurrentVC dismissViewControllerAnimated:true completion:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
