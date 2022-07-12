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

@interface InfoViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property(nonatomic,weak)IBOutlet UITableView * tableView;
@property(nonatomic,weak)IBOutlet UIButton * save;
@property(nonatomic,weak)IBOutlet UIButton * photoBtn;

@property(nonatomic,strong)NSArray * dataArray;
@property(nonatomic,strong)NSArray * iconArray;
@property(nonatomic,strong)NSString * avatar;
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
    self.dataArray = @[self.model.email,self.model.nickName,self.model.phonenumber];
    self.iconArray = @[@"icon_email",@"icon_info",@"icon_phone"];
    [self.photoBtn sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",Host,self.model.avatar]] forState:UIControlStateNormal];

    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([InfoTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([InfoTableViewCell class])];
}

- (IBAction)selectPhoto:(id)sender{
    BRStringPickerView * picker = [[BRStringPickerView alloc] initWithPickerMode:BRStringPickerComponentSingle];
    picker.pickerStyle = self.style;
    picker.dataSourceArr = @[@"camera",@"photo album"];
    picker.resultModelBlock = ^(BRResultModel * _Nullable resultModel) {
        [self selectSourceType:resultModel.index];
    };
    [picker show];
}

- (void)selectSourceType:(NSInteger)index{
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
        return;
    }
    if ([self getModelValueForIndex:1].length == 0) {
        return;
    }
    if ([self getModelValueForIndex:2].length == 0) {
        return;
    }
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
    [params setValue:self.model.userId forKey:@"userId"];
    [params setValue:[self getModelValueForIndex:0] forKey:@"email"];
    [params setValue:[self getModelValueForIndex:1] forKey:@"nickName"];
    [params setValue:[self getModelValueForIndex:2] forKey:@"phonenumber"];
    if (self.avatar) {
        [params setValue:self.avatar forKey:@"avatar"];
    }
    [Request.shareInstance putUrl:EditUserInfo params:params success:^(NSDictionary * _Nonnull result) {
        [RMHelper showToast:@"Update info success" toView:self.view];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:true];
        });
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
}

- (NSString *)getModelValueForIndex:(NSInteger)index{
    InfoTableViewCell * cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    return cell.textfield.text;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    InfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([InfoTableViewCell class]) forIndexPath:indexPath];
    cell.textfield.text = self.dataArray[indexPath.row];
    cell.textfield.placeholderColor = [UIColor colorWithHexString:@"#A3A3A3"];
    cell.icon.image = [UIImage imageNamed:self.iconArray[indexPath.row]];
    cell.line.hidden = indexPath.row == self.iconArray.count - 1;
    return cell;
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
