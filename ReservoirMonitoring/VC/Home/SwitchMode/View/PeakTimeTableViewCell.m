//
//  PeakTimeTableViewCell.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/16.
//

#import "PeakTimeTableViewCell.h"

@interface PeakTimeTableViewCell ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,weak)IBOutlet UILabel * titleLabel;
@property(nonatomic,assign) BOOL offPeakTimeChange;
@property(nonatomic,assign) BOOL peakTimeChange;
@property(nonatomic,assign) BOOL superPeakTimeChange;

@end

@implementation PeakTimeTableViewCell

- (void)setTouArray:(NSArray *)touArray{
    _touArray = touArray;
    if (touArray.count > 0 &&
        !self.offPeakTimeChange) {
        [self.dataArray replaceObjectAtIndex:0 withObject:touArray];
        [self.tableView reloadData];
    }
    CGFloat height = self.tableView.contentSize.height;
    if (ceilf(height) != ceilf([[NSUserDefaults.standardUserDefaults objectForKey:TIME_TABLEVIEW_HEIGHT_CHANGE] floatValue])) {
        [self updateTableViewHeight];
    }
}

- (void)setPeakTimeArray:(NSArray *)peakTimeArray{
    _peakTimeArray = peakTimeArray;
    if (peakTimeArray.count > 0 &&
        !self.peakTimeChange) {
        [self.dataArray replaceObjectAtIndex:1 withObject:peakTimeArray];
        [self.tableView reloadData];
    }
    CGFloat height = self.tableView.contentSize.height;
    if (ceilf(height) != ceilf([[NSUserDefaults.standardUserDefaults objectForKey:TIME_TABLEVIEW_HEIGHT_CHANGE] floatValue])) {
        [self updateTableViewHeight];
    }
}

- (void)setSuperPeakTimeArray:(NSArray *)superPeakTimeArray{
    _peakTimeArray = superPeakTimeArray;
    if (superPeakTimeArray.count > 0 &&
        !self.superPeakTimeChange) {
        [self.dataArray replaceObjectAtIndex:2 withObject:superPeakTimeArray];
        [self.tableView reloadData];
    }
    CGFloat height = self.tableView.contentSize.height;
    if (ceilf(height) != ceilf([[NSUserDefaults.standardUserDefaults objectForKey:TIME_TABLEVIEW_HEIGHT_CHANGE] floatValue])) {
        [self updateTableViewHeight];
    }
}

- (IBAction)switchChange:(UIButton *)sender{
    sender.selected = !sender.selected;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearBtnClick) name:CLEAR_NOTIFICATION object:nil];
    self.titleLabel.text = @"Allow charging via grid".localized;
    self.dataArray = [[NSMutableArray alloc] init];
    for (int i=0; i<3; i++) {
        NSArray * array = @[@{@"startTime":@"",@"endTime":@"",@"price":@""}];
        [self.dataArray addObject:array];
    }
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([TimeTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([TimeTableViewCell class])];
    [self updateTableViewHeight];
    
}

- (void)clearBtnClick{
    self.offPeakTimeChange = true;
    self.peakTimeChange = true;
    self.superPeakTimeChange = true;
    self.dataArray = [[NSMutableArray alloc] init];
    for (int i=0; i<3; i++) {
        NSArray * array = @[@{@"startTime":@"",@"endTime":@"",@"price":@""}];
        [self.dataArray addObject:array];
    }
    [self.tableView reloadData];
    [self updateTableViewHeight];
}

- (void)updateTableViewHeight{
    [self.tableView setNeedsLayout];
    [self.tableView layoutIfNeeded];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [NSUserDefaults.standardUserDefaults setValue:[NSNumber numberWithFloat:ceilf(self.tableView.contentSize.height)] forKey:TIME_TABLEVIEW_HEIGHT_CHANGE];
        [[NSNotificationCenter defaultCenter] postNotificationName:TIME_TABLEVIEW_HEIGHT_CHANGE object:nil];
    });
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TimeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TimeTableViewCell class]) forIndexPath:indexPath];
    cell.removeButton.hidden = indexPath.row == 0;
    [cell.removeButton addTarget:self action:@selector(removeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    NSDictionary * item = self.dataArray[indexPath.section][indexPath.row];
    cell.startTime.text = item[@"startTime"];
    cell.endTime.text = item[@"endTime"];
    cell.electricity.text = item[@"price"];
    cell.indexPath = indexPath;
    cell.valueChangeCompletion = ^(NSIndexPath * indexPath,NSString * _Nonnull key, NSString * _Nonnull value) {
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithDictionary:self.dataArray[indexPath.section][indexPath.row]];
        [dict setValue:value forKey:key];
        NSMutableArray * array = [[NSMutableArray alloc] initWithArray:self.dataArray[indexPath.section]];
        [array replaceObjectAtIndex:indexPath.row withObject:dict];
        [self.dataArray replaceObjectAtIndex:indexPath.section withObject:array];
    };
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataArray[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, SCREEN_WIDTH, 30)];
    headerView.backgroundColor = UIColor.clearColor;
    
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(35, 14, 2, 12)];
    line.backgroundColor = [UIColor colorWithHexString:COLOR_MAIN_COLOR];
    line.layer.cornerRadius = 1;
    [headerView addSubview:line];
    
    UILabel * label = [[UILabel alloc] init];
    [headerView addSubview:label];
    label.font = [UIFont systemFontOfSize:14];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(line.mas_left).offset(10);
            make.top.mas_equalTo(10);
        make.height.mas_equalTo(20);
    }];
    label.text = section == 0 ? @"Off-peak time".localized : (section == 1 ? @"Peak time".localized : @"Super-peak time".localized);
    label.textColor = UIColor.whiteColor;
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView * footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 43)];
    footerView.clipsToBounds = true;
    footerView.backgroundColor = UIColor.clearColor;
    
    UIView * contentView = [[UIView alloc] initWithFrame:CGRectMake(35, 0, tableView.width-65, 43)];
    contentView.backgroundColor = [UIColor colorWithHexString:@"#222222"];
    [footerView addSubview:contentView];
    
    UIButton * addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [footerView addSubview:addButton];
    [addButton showBorderWithRadius:14];
    [addButton setImage:[UIImage imageNamed:@"ic_home_scan_add"] forState:UIControlStateNormal];
    addButton.tag = section+10;
    [addButton addTarget:self action:@selector(addButtonClck:) forControlEvents:UIControlEventTouchUpInside];
    [addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(95);
        make.height.mas_equalTo(28);
        make.top.mas_equalTo(0);
        make.centerX.mas_equalTo(footerView.mas_centerX);
    }];
    
    return footerView;
}

- (void)addButtonClck:(UIButton *)btn{
    NSInteger index = btn.tag-10;
    if (index == 0) {
        self.offPeakTimeChange = true;
    }else if (index == 1){
        self.peakTimeChange = true;
    }else{
        self.superPeakTimeChange = true;
    }
    NSMutableArray * array = [[NSMutableArray alloc] initWithArray:self.dataArray[index]];
    [array addObject:@{@"startTime":@"",@"endTime":@"",@"price":@""}];
    [self.dataArray replaceObjectAtIndex:index withObject:array];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.dataArray[index] count]-1 inSection:index]] withRowAnimation:UITableViewRowAnimationNone];
    [self updateTableViewHeight];
}

- (void)removeButtonAction:(UIButton *)btn{
    TimeTableViewCell * cell = (TimeTableViewCell *)[[[btn superview] superview] superview];
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    NSMutableArray * array = [[NSMutableArray alloc] initWithArray:self.dataArray[indexPath.section]];
    [array removeObjectAtIndex:indexPath.row];
    [self.dataArray replaceObjectAtIndex:indexPath.section withObject:array];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationNone];
    if (indexPath.section == 0) {
        self.offPeakTimeChange = true;
    }else if (indexPath.section == 1){
        self.peakTimeChange = true;
    }else{
        self.superPeakTimeChange = true;
    }
    [self updateTableViewHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return [self.dataArray[section] count] < 3 ? 43 : 0.01;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
