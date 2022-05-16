//
//  RegisterViewController.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/12.
//

#import "RegisterViewController.h"
#import "RegisterTableViewCell.h"
#import "ImageAuthenticationView.h"

@interface RegisterViewController ()<ImageAuthenticationViewDelegate>

@property(nonatomic,weak)IBOutlet UITableView * tableView;
@property(nonatomic,weak)IBOutlet UIButton * registerBtn;
@property(nonatomic,weak)IBOutlet UIButton * loginBtn;
@property(nonatomic,weak)IBOutlet UILabel * agree;
@property(nonatomic,weak)IBOutlet UIButton * agreement;
@property(nonatomic,strong)NSArray * dataArray;
@property(nonatomic,strong)UIButton * sendCodeButton;

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
    [ImageAuthenticationView showImageAuthemticationWithDelegate:self];
}

- (void)onAuthemticationSuccess{
    NSArray * cells = self.tableView.visibleCells;
    for (RegisterTableViewCell * cell in cells) {
        NSLog(@"%@",cell.textfield.text);
    }
}

- (IBAction)popViewAction:(id)sender{
    [self.navigationController popViewControllerAnimated:true];
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
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
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
