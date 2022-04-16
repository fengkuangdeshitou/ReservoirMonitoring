//
//  DeviceSwitchView.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/16.
//

#import "DeviceSwitchView.h"
#import "DeviceSwitchTableViewCell.h"

@interface DeviceSwitchView ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UIView * contentView;
@property(nonatomic,strong)UITableView * tableView;

@end

@implementation DeviceSwitchView

+ (void)showDeviceSwitchViewWithDelegate:(id<DeviceSwitchViewDelegate>)delegate{
    DeviceSwitchView * view = [[DeviceSwitchView alloc] initWithDelegate:delegate];
    [view show];
}

- (instancetype)initWithDelegate:(id<DeviceSwitchViewDelegate>)delegate
{
    self = [super init];
    if (self) {
        
        self.frame = UIScreen.mainScreen.bounds;
        self.alpha = 0;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        [UIApplication.sharedApplication.keyWindow addSubview:self];
        
        self.contentView = [[UIView alloc] initWithFrame:CGRectMake(15, 90, SCREEN_WIDTH-30, self.height-90*2)];
        self.contentView.backgroundColor = [UIColor colorWithHexString:@"#1B1B1B"];
        self.contentView.layer.cornerRadius = 4;
        self.contentView.clipsToBounds = true;
        [self addSubview:self.contentView];
        
        self.tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds style:UITableViewStyleGrouped];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundColor = UIColor.clearColor;
        [self.contentView addSubview:self.tableView];
        
        UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 52)];
        headerView.backgroundColor = UIColor.clearColor;
        
        UILabel * label = [[UILabel alloc] init];
        [headerView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(0);
            make.left.mas_equalTo(15);
        }];
        label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        label.text = @"The device switch";
        label.textColor = UIColor.whiteColor;
        
        UIButton * closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [headerView addSubview:closeButton];
        [closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
        [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.top.bottom.mas_equalTo(0);
            make.width.mas_equalTo(44);
        }];
        self.tableView.tableHeaderView = headerView;
        
        [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([DeviceSwitchTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([DeviceSwitchTableViewCell class])];
        
    }
    return self;
}

- (void)closeAction{
    [self dismiss];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DeviceSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DeviceSwitchTableViewCell class]) forIndexPath:indexPath];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section == 0 ? 1 : 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 28)];
    headerView.backgroundColor = UIColor.clearColor;
    
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(15, 4, 2, 12)];
    line.backgroundColor = [UIColor colorWithHexString:COLOR_MAIN_COLOR];
    line.layer.cornerRadius = 1;
    [headerView addSubview:line];
    
    UILabel * label = [[UILabel alloc] init];
    [headerView addSubview:label];
    label.font = [UIFont systemFontOfSize:14];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(line.mas_left).offset(10);
            make.top.mas_equalTo(0);
        make.height.mas_equalTo(20);
    }];
    label.text = section == 0 ? @"The current bound device" : @"Unbound devices";
    label.textColor = UIColor.whiteColor;
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView * footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 54)];
    footerView.backgroundColor = UIColor.clearColor;
    
    if (section == 0) {
        UIView * contentView = [[UIView alloc] initWithFrame:CGRectMake(15, 8, SCREEN_WIDTH-60, 32)];
        contentView.backgroundColor = [UIColor colorWithHexString:@"#1B1B1B"];
        contentView.layer.cornerRadius = 16;
        contentView.layer.borderColor = [UIColor colorWithHexString:@"#393939"].CGColor;
        contentView.layer.borderWidth = 1;
        [footerView addSubview:contentView];
        
        UIButton * searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [contentView addSubview:searchButton];
        [searchButton setTitle:@"Search" forState:UIControlStateNormal];
        searchButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [searchButton setTitleColor:[UIColor colorWithHexString:COLOR_MAIN_COLOR] forState:UIControlStateNormal];
        [searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(0);
            make.right.mas_equalTo(-15);
            make.width.mas_equalTo(50);
        }];
        
        UITextField * search = [[UITextField alloc] init];
        [contentView addSubview:search];
        search.placeholder = @"Enter the user name or SN filter";
        search.placeholderColor = [UIColor colorWithHexString:@"#999999"];
        search.font = [UIFont systemFontOfSize:13];
        [search mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.top.bottom.mas_equalTo(0);
            make.right.mas_equalTo(searchButton.mas_left).offset(-15);
        }];
    }else{
        UIButton * addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [footerView addSubview:addButton];
        [addButton showBorderWithRadius:16];
        [addButton setTitle:@"Add equipment" forState:UIControlStateNormal];
        addButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [addButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(footerView.mas_centerX);
            make.top.mas_equalTo(8);
            make.width.mas_equalTo(200);
            make.height.mas_equalTo(32);
        }];
    }
    
    
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 28;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 54;
}

- (void)show{
    [UIView animateWithDuration:0.1 animations:^{
        self.alpha = 1;
    }];
}

- (void)dismiss{
    [UIView animateWithDuration:0.1 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
