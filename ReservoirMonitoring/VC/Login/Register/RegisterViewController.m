//
//  RegisterViewController.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/12.
//

#import "RegisterViewController.h"
#import "RegisterTableViewCell.h"
#import "ImageAuthenticationView.h"

@interface RegisterViewController ()<ImageAuthenticationViewDelegate,UITableViewDelegate>

@property(nonatomic,weak)IBOutlet UITableView * tableView;
@property(nonatomic,weak)IBOutlet UIButton * registerBtn;
@property(nonatomic,weak)IBOutlet UIButton * loginBtn;
@property(nonatomic,weak)IBOutlet UIButton * statusBtn;
@property(nonatomic,weak)IBOutlet UILabel * agree;
@property(nonatomic,weak)IBOutlet UIButton * agreement;
@property(nonatomic,strong)NSArray * dataArray;
@property(nonatomic,strong)UIButton * sendCodeButton;
@property(nonatomic,assign)NSInteger time;
@property(nonatomic,strong)NSTimer * timer;
@property(nonatomic,strong)NSString * uuid;

@end

@implementation RegisterViewController

- (UIButton *)sendCodeButton{
    if (!_sendCodeButton) {
        _sendCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendCodeButton setTitle:@"Send code".localized forState:UIControlStateNormal];
        [_sendCodeButton setTitleColor:[UIColor colorWithHexString:COLOR_MAIN_COLOR] forState:UIControlStateNormal];
        _sendCodeButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_sendCodeButton addTarget:self action:@selector(sendCodeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendCodeButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.time = 60;
    self.dataArray = @[
    @{@"title":@"Name".localized,@"placeholder":@"Please input your name".localized},
    @{@"title":@"Email".localized,@"placeholder":@"Please input your Email".localized},
    @{@"title":@"Email verification".localized,@"placeholder":@"Enter verification code".localized},
    @{@"title":@"Password".localized,@"placeholder":@"Please enter 6-20 digit password".localized},
    @{@"title":@"Password confirmation".localized,@"placeholder":@"Please enter password again".localized}
    ];
    self.agree.text = @"I have read and agree".localized;
    [self.agreement setTitle:@"EULA".localized forState:UIControlStateNormal];
    [self.registerBtn setTitle:@"Register".localized forState:UIControlStateNormal];
    [self.loginBtn setTitle:@"Login if you have an account".localized forState:UIControlStateNormal];
    [self.registerBtn showBorderWithRadius:25];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([RegisterTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([RegisterTableViewCell class])];
}

- (IBAction)statusChange:(UIButton *)sender{
    sender.selected = !sender.selected;
}

- (IBAction)registration:(id)sender{
    NSArray<RegisterTableViewCell *> * cells = self.tableView.visibleCells;
    for (int i=0; i<cells.count; i++) {
        RegisterTableViewCell * cell = cells[i];
        NSLog(@"%@",cell.textfield.text);
        if (i == 2 && self.uuid == nil) {
            [RMHelper showToast:@"Please get verification code".localized toView:self.view];
            return;
        }
        if (cell.textfield.text.length == 0) {
            [RMHelper showToast:cell.textfield.placeholder toView:self.view];
            return;
        }
    }
    if (![cells[3].textfield.text isEqualToString:cells[4].textfield.text]) {
        [RMHelper showToast:@"The passwords are inconsistent".localized toView:self.view];
        return;
    }
    if (!self.statusBtn.selected) {
        [RMHelper showToast:@"Please read and agree EULA".localized toView:self.view];
        return;
    }
    for (int i=0; i<cells.count; i++) {
        RegisterTableViewCell * cell = cells[i];
        NSLog(@"%@",cell.textfield.text);
        if (cell.textfield.text.length == 0) {
            [RMHelper showToast:cell.textfield.placeholder.localized toView:self.view];
            return;
        }
    }
    [Request.shareInstance postUrl:CommonRegister params:@{@"nickName":cells[0].textfield.text,@"userName":cells[1].textfield.text,@"code":cells[2].textfield.text,@"password":cells[3].textfield.text,@"uuid":self.uuid} progress:^(float progress) {

    } success:^(NSDictionary * _Nonnull result) {
        if (self.registerSuccess) {
            self.registerSuccess(cells[1].textfield.text, cells[3].textfield.text);
        }
        [self.navigationController popViewControllerAnimated:true];
    } failure:^(NSString * _Nonnull errorMsg) {

    }];
}

- (void)onAuthemticationSuccess{
    RegisterTableViewCell * cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    [Request.shareInstance postUrl:EmailCode params:@{@"type":@"1",@"email":cell.textfield.text} progress:^(float progress) {

    } success:^(NSDictionary * _Nonnull result) {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:true block:^(NSTimer * _Nonnull timer) {
        self.uuid = [NSString stringWithFormat:@"%@",result[@"data"]];
            self.time--;
            if (self.time == 0) {
                self.time = 60;
                [timer invalidate];
                self.sendCodeButton.userInteractionEnabled = true;
                [self.sendCodeButton setTitle:@"Send code".localized forState:UIControlStateNormal];
            }else{
                self.sendCodeButton.userInteractionEnabled = false;
                [self.sendCodeButton setTitle:[NSString stringWithFormat:@"%ld",self.time] forState:UIControlStateNormal];
            }
        }];
    } failure:^(NSString * _Nonnull errorMsg) {

    }];
}

- (void)sendCodeAction{
    RegisterTableViewCell * cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    if (cell.textfield.text.length == 0) {
        [RMHelper showToast:cell.textfield.placeholder.localized toView:self.view];
        return;
    }
    [ImageAuthenticationView showImageAuthemticationWithDelegate:self];
}

- (IBAction)popViewAction:(id)sender{
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)agrementAction:(id)sender{
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RegisterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([RegisterTableViewCell class]) forIndexPath:indexPath];
    if (indexPath.row == 2) {
        [cell.contentView addSubview:self.sendCodeButton];
        [self.sendCodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.mas_equalTo(-20);
                    make.centerY.mas_equalTo(cell.textfield.mas_centerY);
        }];
    }
    cell.titleLabel.text = self.dataArray[indexPath.row][@"title"];
    cell.textfield.placeholder = self.dataArray[indexPath.row][@"placeholder"];
    if (indexPath.row == 3 || indexPath.row == 4) {
        cell.textfield.secureTextEntry = true;
    }else{
        cell.textfield.secureTextEntry = false;
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 96;
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
