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
@property(nonatomic,strong)NSArray * dataArray;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.dataArray = @[
    @{@"title":@"Name",@"placeholder":@"Please enter your name"},
    @{@"title":@"Email address",@"placeholder":@"Please enter your registered email address"},
    @{@"title":@"Verification code",@"placeholder":@"Email verification code"},
    @{@"title":@"Login password",@"placeholder":@"Please set 6-20 login password"},
    @{@"title":@"Confirm password",@"placeholder":@"Please confirm your login password again"}
    ];
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
