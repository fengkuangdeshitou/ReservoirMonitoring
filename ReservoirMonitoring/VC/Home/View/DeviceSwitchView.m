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
@property(nonatomic,strong)UITableView * otherTableView;

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
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, self.contentView.height-56) style:UITableViewStyleGrouped];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundColor = UIColor.clearColor;
        self.tableView.scrollEnabled = false;
        [self.contentView addSubview:self.tableView];
        
        self.otherTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 230, SCREEN_WIDTH-30, self.contentView.height-295) style:UITableViewStylePlain];
        self.otherTableView.delegate = self;
        self.otherTableView.dataSource = self;
        self.otherTableView.backgroundColor = UIColor.clearColor;
        self.otherTableView.bounces = false;
        self.otherTableView.tableFooterView = [UIView new];
        self.otherTableView.tableHeaderView = [UIView new];
        self.otherTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        self.otherTableView.estimatedSectionFooterHeight = 0;
        [self.contentView addSubview:self.otherTableView];
        
        UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 52)];
        headerView.backgroundColor = UIColor.clearColor;
        
        UILabel * label = [[UILabel alloc] init];
        [headerView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(0);
            make.left.mas_equalTo(15);
        }];
        label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        label.text = @"Switch device".localized;
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
        [self.otherTableView registerNib:[UINib nibWithNibName:NSStringFromClass([DeviceSwitchTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([DeviceSwitchTableViewCell class])];
        
        UIButton * addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:addButton];
        [addButton showBorderWithRadius:16];
        [addButton setTitle:@"Add device".localized forState:UIControlStateNormal];
        addButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [addButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(self.contentView.mas_centerX);
            make.bottom.mas_equalTo(-15);
            make.width.mas_equalTo(200);
            make.height.mas_equalTo(32);
        }];
        
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
    return tableView == self.tableView ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.tableView) {
        return section == 0 ? 1 : 0;
    }
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (tableView == self.tableView) {
        UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, section == 0 ? 28 : 28+54)];
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
        label.text = section == 0 ? @"Current device".localized : @"Other device".localized;
        label.textColor = UIColor.whiteColor;
        
        
        if (section == 1) {
            UIView * contentView = [[UIView alloc] initWithFrame:CGRectMake(15, 36, SCREEN_WIDTH-60, 32)];
            contentView.backgroundColor = [UIColor colorWithHexString:@"#1B1B1B"];
            contentView.layer.cornerRadius = 16;
            contentView.layer.borderColor = [UIColor colorWithHexString:@"#393939"].CGColor;
            contentView.layer.borderWidth = 1;
            [headerView addSubview:contentView];
            
            UIButton * searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [contentView addSubview:searchButton];
            [searchButton setTitle:@"Query".localized forState:UIControlStateNormal];
            searchButton.titleLabel.font = [UIFont systemFontOfSize:13];
            [searchButton setTitleColor:[UIColor colorWithHexString:COLOR_MAIN_COLOR] forState:UIControlStateNormal];
            [searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.mas_equalTo(0);
                make.right.mas_equalTo(-15);
                make.width.mas_equalTo(50);
            }];
            
            UITextField * search = [[UITextField alloc] init];
            [contentView addSubview:search];
            search.placeholder = @"Search by device name or SN".localized;
            search.placeholderColor = [UIColor colorWithHexString:@"#999999"];
            search.font = [UIFont systemFontOfSize:13];
            [search mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(15);
                make.top.bottom.mas_equalTo(0);
                make.right.mas_equalTo(searchButton.mas_left).offset(-15);
            }];
        }
        
        return headerView;
    }else{
        return [UIView new];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView == self.tableView){
        return section == 0 ? 28 : 25 + 54;
    }
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
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
