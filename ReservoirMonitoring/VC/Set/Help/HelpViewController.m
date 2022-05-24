//
//  HelpViewController.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/19.
//

#import "HelpViewController.h"
#import "HelpTableViewCell.h"

@interface HelpViewController ()

@property(nonatomic,weak)IBOutlet UITableView * tableView;

@end

@implementation HelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([HelpTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([HelpTableViewCell class])];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HelpTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HelpTableViewCell class]) forIndexPath:indexPath];
    cell.line.hidden = indexPath.row == 4;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
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
