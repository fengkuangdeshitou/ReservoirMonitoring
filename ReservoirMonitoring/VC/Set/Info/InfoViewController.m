//
//  InfoViewController.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/18.
//

#import "InfoViewController.h"
#import "InfoTableViewCell.h"

@interface InfoViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property(nonatomic,weak)IBOutlet UITableView * tableView;
@property(nonatomic,weak)IBOutlet UIButton * save;
@property(nonatomic,weak)IBOutlet UIButton * photoBtn;

@property(nonatomic,strong)NSArray * dataArray;
@property(nonatomic,strong)NSArray * iconArray;
@property(nonatomic,strong)NSString * avatar;

@end

@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.save showBorderWithRadius:25];
    self.dataArray = @[self.model.email,self.model.nickName,self.model.phonenumber];
    self.iconArray = @[@"icon_email",@"icon_info",@"icon_phone"];

    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([InfoTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([InfoTableViewCell class])];
}

- (IBAction)selectPhoto:(id)sender{
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
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
        [self.navigationController popViewControllerAnimated:true];
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
