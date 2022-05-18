//
//  WifiViewController.m
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/5/18.
//

#import "WifiViewController.h"
#import "WifiTableViewCell.h"
#import "WifiInfoTableViewCell.h"
#import "WifiAlertView.h"

@interface WifiViewController ()<UITableViewDelegate>

@property(nonatomic,weak)IBOutlet UITableView * tableView;

@end

@implementation WifiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([WifiInfoTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([WifiInfoTableViewCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([WifiTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([WifiTableViewCell class])];
    [self.model addObserver:self forKeyPath:@"isConnected" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    NSLog(@"change=%@",object);
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        WifiInfoTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WifiInfoTableViewCell class]) forIndexPath:indexPath];
        cell.model = self.model;
        return cell;
    }else{
        WifiTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WifiTableViewCell class]) forIndexPath:indexPath];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        [WifiAlertView showWifiAlertViewWithTitle:@"KLX TEST TWS" completion:^(NSString * _Nonnull value) {
                    
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section == 0 ? 1 : 5;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.section == 0 ? 185 : 78;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
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
