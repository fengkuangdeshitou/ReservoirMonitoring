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
@property(nonatomic,weak)IBOutlet UILabel * temp;
@property(nonatomic,weak)IBOutlet UILabel * weather;
@property(nonatomic,weak)IBOutlet UILabel * symbol;
@property(nonatomic,strong) NSMutableArray * list;

@end

@implementation WeatherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([WeatherInfoTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([WeatherInfoTableViewCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([WeatherTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([WeatherTableViewCell class])];
    self.list = [[NSMutableArray alloc] init];
    [self getWeatherData];
}

- (void)getWeatherData{
    [Request.shareInstance getUrl:Weather params:@{@"deviceId":self.deviceId,@"type":@"1"} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        NSDictionary * item = result[@"data"][@"list"];
        NSArray * keys = item.allKeys;
        NSArray * sortArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [obj1 longLongValue] > [obj2 longLongValue];
        }];
        for (int i=0; i<sortArray.count; i++) {
            NSString * key = sortArray[i];
            NSArray * value = item[key];
            [self.list addObject:value];
        }
        [self.tableView reloadData];
        self.temp.text = [NSString stringWithFormat:@"%.0f",[self.list[0][0][@"main"][@"temp"] floatValue]];
        NSString * interval = [NSString stringWithFormat:@"%.0f°-%.0f°",[self.list[0][0][@"main"][@"temp_min"] floatValue],[self.list[0][0][@"main"][@"temp_max"] floatValue]];
        self.weather.text = [NSString stringWithFormat:@"%@\n%@",interval,self.list[0][0][@"weather"][0][@"description"]];
        self.symbol.hidden = false;
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 1) {
        WeatherInfoTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WeatherInfoTableViewCell class]) forIndexPath:indexPath];
        cell.model = self.list[0];
        return cell;
    }else{
        WeatherTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WeatherTableViewCell class]) forIndexPath:indexPath];
        cell.model = self.list[indexPath.row==0?0:indexPath.row-1];
        cell.icon.hidden = indexPath.row == 0;
        return cell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.list.count == 0 ? 0 : self.list.count+1;
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
