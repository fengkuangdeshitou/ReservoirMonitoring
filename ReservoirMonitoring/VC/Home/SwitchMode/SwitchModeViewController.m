//
//  SwitchModeViewController.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/16.
//

#import "SwitchModeViewController.h"
#import "SwitchModelTableViewCell.h"
#import "SwitchProgressTableViewCell.h"
#import "PeakTimeTableViewCell.h"
#import "GlobelDescAlertView.h"

@interface SwitchModeViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,weak)IBOutlet UITableView * tableView;
@property(nonatomic,weak)IBOutlet UIButton * submitButton;
@property(nonatomic,assign)NSInteger flag;
@property(nonatomic,weak)IBOutlet UILabel * weather;

@end

@implementation SwitchModeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.weather.text = @"Weather watch".localized;
    [self.submitButton setTitle:@"Submit".localized forState:UIControlStateNormal];
    [[NSNotificationCenter defaultCenter] addObserverForName:TIME_TABLEVIEW_HEIGHT_CHANGE object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self.tableView reloadData];
    }];
    [self.submitButton showBorderWithRadius:25];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SwitchModelTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([SwitchModelTableViewCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SwitchProgressTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([SwitchProgressTableViewCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([PeakTimeTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([PeakTimeTableViewCell class])];
    
}

- (IBAction)helpAction:(id)sender{
    [GlobelDescAlertView showAlertViewWithTitle:@"Weather watch".localized desc:@"Monitor local weather condition, automatically stores energy for hazard backup."];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        SwitchModelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchModelTableViewCell class]) forIndexPath:indexPath];
        cell.icon.image = [UIImage imageNamed:self.flag == indexPath.section ? @"icon_choose" : @"icon_unchoose"];
        cell.titleLabel.text = indexPath.section == 0 ? @"Self-consumption" : (indexPath.section == 1 ? @"Back up" : @"Time Of Use");
        cell.indexPath = indexPath;
        return cell;
    }else{
        if (indexPath.section == 2) {
            PeakTimeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([PeakTimeTableViewCell class]) forIndexPath:indexPath];
            return cell;
        }else{
            SwitchProgressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SwitchProgressTableViewCell class]) forIndexPath:indexPath];
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.flag = indexPath.section;
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.flag == section) {
        return 2;
    }else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 44;
    }else{
        if (indexPath.section == 2) {
            return [NSUserDefaults.standardUserDefaults objectForKey:TIME_TABLEVIEW_HEIGHT_CHANGE] ? [[NSUserDefaults.standardUserDefaults objectForKey:TIME_TABLEVIEW_HEIGHT_CHANGE] floatValue]+15 : 500;
        }else{
            return 77;
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 47)];
    headerView.backgroundColor = UIColor.clearColor;
    headerView.clipsToBounds = true;
    
    UIView * colorView = [[UIView alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH-30, 47)];
    colorView.backgroundColor = [UIColor colorWithHexString:@"#1B1B1B"];
    [headerView addSubview:colorView];
    
    UILabel * label = [[UILabel alloc] init];
    [colorView addSubview:label];
    label.text = @"Switch operation mode".localized;
    label.textColor = UIColor.whiteColor;
    label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.mas_equalTo(15);
            make.height.mas_equalTo(22);
    }];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section == 0 ? 47 : 0.001;
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
