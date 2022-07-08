//
//  HelpViewController.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/19.
//

#import "HelpViewController.h"
#import "HelpTableViewCell.h"
#import "HelpDetailViewController.h"

@interface HelpViewController ()<UITableViewDelegate>

@property(nonatomic,weak)IBOutlet UITableView * tableView;
@property(nonatomic,strong) NSArray * dataArray;

@end

@implementation HelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self getHelpData];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([HelpTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([HelpTableViewCell class])];
}

- (void)getHelpData{
    [Request.shareInstance getUrl:HelpList params:@{} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        self.dataArray = result[@"data"];
        [self.tableView reloadData];
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HelpTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HelpTableViewCell class]) forIndexPath:indexPath];
    cell.line.hidden = indexPath.row == self.dataArray.count-1;
    NSDictionary * item = self.dataArray[indexPath.row];
    cell.titleLabel.text = item[@"titleEn"];
    cell.content.text = item[@"subtitleEn"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary * item = self.dataArray[indexPath.row];
    HelpDetailViewController * detail = [[HelpDetailViewController alloc] init];
    detail.helpId = [NSString stringWithFormat:@"%@",item[@"id"]];
    detail.title = item[@"titleEn"];
    [self.navigationController pushViewController:detail animated:true];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 15;
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
