//
//  TimeZoneViewController.m
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/6/8.
//

#import "TimeZoneViewController.h"

@interface TimeZoneViewController ()<UITableViewDelegate>

@property(nonatomic,weak)IBOutlet UITableView * tableView;
@property(nonatomic,strong) NSArray * dataArray;

@end

@implementation TimeZoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self getTimeZoneData];
}

- (void)getTimeZoneData{
    [Request.shareInstance getUrl:TimeZoneList params:@{@"countryId":self.countryId} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        self.dataArray = result[@"data"];
        [self.tableView reloadData];
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.dataArray[indexPath.row][@"zoneId"][1];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textColor = UIColor.whiteColor;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.contentView.backgroundColor = tableView.backgroundColor;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.selectTimeZone) {
        self.selectTimeZone(self.dataArray[indexPath.row]);
    }
    [self.navigationController popViewControllerAnimated:true];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
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
