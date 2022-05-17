//
//  WeatherViewController.m
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/5/17.
//

#import "WeatherViewController.h"
#import "WeatherInfoTableViewCell.h"
#import "WeatherTableViewCell.h"

@interface WeatherViewController ()

@property(nonatomic,weak)IBOutlet UITableView * tableView;

@end

@implementation WeatherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([WeatherInfoTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([WeatherInfoTableViewCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([WeatherTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([WeatherTableViewCell class])];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 1) {
        WeatherInfoTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WeatherInfoTableViewCell class]) forIndexPath:indexPath];
        return cell;
    }else{
        WeatherTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WeatherTableViewCell class]) forIndexPath:indexPath];
        return cell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.row == 1 ? 112 : 44;
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
