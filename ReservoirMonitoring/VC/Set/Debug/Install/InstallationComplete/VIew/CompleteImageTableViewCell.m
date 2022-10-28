//
//  CompleteImageTableViewCell.m
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/10/28.
//

#import "CompleteImageTableViewCell.h"
@import HXPhotoPicker;

@interface CompleteImageTableViewCell ()

@property(nonatomic,strong) HXPhotoManager * manager;
@property(nonatomic,strong) HXPhotoView * photoView;

@end

@implementation CompleteImageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.manager = [HXPhotoManager managerWithType:HXPhotoManagerSelectedTypePhoto];
    self.manager.configuration.themeColor = UIColor.whiteColor;
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
    self.photoView.spacing = 6;
    [self.contentView addSubview:self.photoView];
    [self.photoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_offset(0);
    }];
    HXWeakSelf;
    self.photoView.updateFrameBlock = ^(CGRect frame) {
        if (weakSelf.updateFrameBlock){
            weakSelf.updateFrameBlock(frame);
        }
    };
    self.photoView.changeCompleteBlock = ^(NSArray<HXPhotoModel *> * _Nonnull allList, NSArray<HXPhotoModel *> * _Nonnull photos, NSArray<HXPhotoModel *> * _Nonnull videos, BOOL isOriginal) {
        weakSelf.photos = photos;
    };
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
