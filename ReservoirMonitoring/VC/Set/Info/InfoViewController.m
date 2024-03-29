//
//  InfoViewController.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/18.
//

#import "InfoViewController.h"
#import "InfoTableViewCell.h"
@import BRPickerView;
@import SDWebImage;
@import Photos;
@import AVFoundation;
#import "GlobelDescAlertView.h"
#import "CountryCodeViewController.h"

@interface InfoViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate>

@property(nonatomic,weak)IBOutlet UITableView * tableView;
@property(nonatomic,strong)IBOutlet UITableViewCell * phoneCell;
@property(nonatomic,strong)IBOutlet UITextField * phoneTextfield;
@property(nonatomic,weak)IBOutlet UILabel * phone;
@property(nonatomic,weak)IBOutlet UIButton * save;
@property(nonatomic,weak)IBOutlet UIButton * photoBtn;

@property(nonatomic,strong) NSArray * dataArray;
@property(nonatomic,strong) NSArray * iconArray;
@property(nonatomic,strong) NSString * avatar;
@property(nonatomic,strong) BRPickerStyle * style;

@end

@implementation InfoViewController

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
    [self.save showBorderWithRadius:25];
    NSString * phonenumber = self.model.phonenumber?:@"--";
    if ([self.model.phonenumber containsString:@"-"]){
        self.phone.text = [self.model.phonenumber componentsSeparatedByString:@"-"].firstObject;
        phonenumber = [self.model.phonenumber componentsSeparatedByString:@"-"].lastObject;
    }
    self.dataArray = @[self.model.email?:@"--",self.model.nickName?:@"--",phonenumber];
    self.iconArray = @[@"icon_email",@"icon_info",@"icon_phone"];
    
    self.photoBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.photoBtn sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",Host,self.model.avatar]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"info"]];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([InfoTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([InfoTableViewCell class])];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSInteger existedLength = textField.text.length;
    NSInteger selectedLength = range.length;
    NSInteger replaceLength = string.length;
    NSInteger pointLength = existedLength - selectedLength + replaceLength;
    if (textField == self.phoneTextfield){
        if (pointLength > 11) {
            return NO;
        }else{
            return YES;
        }
    }else{
        if (pointLength > 30) {
            return NO;
        }else{
            return YES;
        }
    }
}

- (IBAction)selectCountryCodeAction:(UIButton *)sender{
    CountryCodeViewController * code = [[CountryCodeViewController alloc] init];
    code.selectCountryCode = ^(NSDictionary * _Nonnull item) {
        self.phone.text = [NSString stringWithFormat:@"+%@",item[@"countryCode"]];
    };
    [RMHelper.getCurrentVC.navigationController pushViewController:code animated:true];
}

- (IBAction)selectPhoto:(id)sender{
    [self.view endEditing:true];
    BRStringPickerView * picker = [[BRStringPickerView alloc] initWithPickerMode:BRStringPickerComponentSingle];
    picker.pickerStyle = self.style;
    picker.dataSourceArr = @[@"camera",@"photo album"];
    picker.resultModelBlock = ^(BRResultModel * _Nullable resultModel) {
        [self selectSourceType:resultModel.index];
    };
    [picker show];
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
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.sourceType = index == 0 ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [self presentViewController:picker animated:true completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info{
    UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.photoBtn setImage:image forState:UIControlStateNormal];
    [self uploadImage:image];
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)uploadImage:(UIImage *)image{
    [Request.shareInstance upload:UploadImg params:@{} image:image progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        self.avatar = result[@"data"];
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
}

- (IBAction)updateInfo:(id)sender{
    if ([self getModelValueForIndex:0].length == 0) {
        [RMHelper showToast:@"Please input your email" toView:self.view];
        return;
    }
    if ([self getModelValueForIndex:1].length == 0) {
        [RMHelper showToast:@"Please input your name" toView:self.view];
        return;
    }
    if (self.phoneTextfield.text.length == 0) {
        [RMHelper showToast:@"Please input your phone" toView:self.view];
        return;
    }
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
    [params setValue:self.model.userId forKey:@"userId"];
    [params setValue:[self getModelValueForIndex:0] forKey:@"email"];
    [params setValue:[self getModelValueForIndex:1] forKey:@"nickName"];
    [params setValue:[NSString stringWithFormat:@"%@-%@",self.phone.text,self.phoneTextfield.text] forKey:@"phonenumber"];
    if (self.avatar) {
        [params setValue:self.avatar forKey:@"avatar"];
    }
    [Request.shareInstance putUrl:EditUserInfo params:params success:^(NSDictionary * _Nonnull result) {
        [RMHelper showToast:@"Success" toView:self.view];
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
}

- (NSString *)getModelValueForIndex:(NSInteger)index{
    InfoTableViewCell * cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    return cell.textfield.text;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.dataArray.count-1){
        self.phoneTextfield.text = self.dataArray[indexPath.row];
        self.phoneTextfield.placeholderColor = [UIColor colorWithHexString:@"#A3A3A3"];
        self.phoneTextfield.delegate = self;
        return self.phoneCell;
    }else{
        InfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([InfoTableViewCell class]) forIndexPath:indexPath];
        cell.textfield.text = self.dataArray[indexPath.row];
        cell.textfield.placeholderColor = [UIColor colorWithHexString:@"#A3A3A3"];
        cell.icon.image = [UIImage imageNamed:self.iconArray[indexPath.row]];
        cell.line.hidden = indexPath.row == self.iconArray.count - 1;
        cell.textfield.userInteractionEnabled = indexPath.row!=0;
        if(indexPath.row == 1){
            cell.textfield.delegate = self;
        }
        return cell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
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
