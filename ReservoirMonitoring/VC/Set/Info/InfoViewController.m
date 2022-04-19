//
//  InfoViewController.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/18.
//

#import "InfoViewController.h"
#import "InfoTableViewCell.h"

@interface InfoViewController ()

@property(nonatomic,weak)IBOutlet UITableView * tableView;
@property(nonatomic,weak)IBOutlet UIButton * save;
@property(nonatomic,strong)NSArray * dataArray;
@property(nonatomic,strong)NSArray * iconArray;

@end

@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.save showBorderWithRadius:25];
    self.dataArray = @[@"",@"Please enter your name",@"Please enter your phone"];
    self.iconArray = @[@"icon_email",@"icon_info",@"icon_phone"];

    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([InfoTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([InfoTableViewCell class])];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    InfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([InfoTableViewCell class]) forIndexPath:indexPath];
    cell.textfield.placeholder = self.dataArray[indexPath.row];
    cell.textfield.placeholderColor = [UIColor colorWithHexString:@"#A3A3A3"];
    cell.icon.image = [UIImage imageNamed:self.iconArray[indexPath.row]];
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
