//
//  PeakTimeTableViewCell.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/16.
//

#import "PeakTimeTableViewCell.h"

@interface PeakTimeTableViewCell ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,weak)IBOutlet UILabel * titleLabel;

@end

@implementation PeakTimeTableViewCell

- (void)setTouArray:(NSArray *)touArray{
    _touArray = touArray;
    if (touArray.count > 0) {
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
    if (peakTimeArray.count > 0) {
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
    if (superPeakTimeArray.count > 0) {
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
    self.titleLabel.text = @"Allow charging via grid".localized;
    self.dataArray = [[NSMutableArray alloc] init];
    for (int i=0; i<3; i++) {
        NSArray * array = @[@{@"startTime":@"",@"endTime":@"",@"price":@""}];
        [self.dataArray addObject:array];
    }
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([TimeTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([TimeTableViewCell class])];
    [self updateTableViewHeight];
    
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
//        [BleManager.shareInstance readWithCMDString:@"6FE" count:2 finish:^(NSArray * _Nonnull array) {
//            dispatch_semaphore_signal(semaphore);
//            self.switchBtn.selected = [array.firstObject boolValue];
//            NSInteger count = [array.lastObject integerValue] == 0 ? 1 : [array.lastObject integerValue];
//            NSMutableArray * countArray = [[NSMutableArray alloc] init];
//            for (int i=0; i<count; i++) {
//                NSDictionary * dict = @{@"startTime":@"",@"endTime":@"",@"price":@""};
//                [countArray addObject:dict];
//            }
//            [self.dataArray replaceObjectAtIndex:0 withObject:countArray];
//            [self.tableView reloadData];
//        }];
//
//        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//        [BleManager.shareInstance readWithCMDString:@"702" count:4 finish:^(NSArray * _Nonnull array) {
//            NSLog(@"array=%@",array);
//            if (array.count < 4) {
//                return;
//            }
//            NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
//            [dict setValue:[NSString stringWithFormat:@"%@:%@",array[0],array[1]] forKey:@"startTime"];
//            [dict setValue:[NSString stringWithFormat:@"%@:%@",array[2],array[3]] forKey:@"endTime"];
//            NSMutableArray * indexArray = [[NSMutableArray alloc] initWithArray:self.dataArray[0]];
//            NSLog(@"%@",indexArray);
//
//            NSMutableArray * valueArray = [[NSMutableArray alloc] initWithArray:@[indexArray[0]]];
//            [valueArray replaceObjectAtIndex:0 withObject:dict];
//            [indexArray replaceObjectAtIndex:0 withObject:valueArray];
//            [self.dataArray replaceObjectAtIndex:0 withObject:indexArray];
//            dispatch_semaphore_signal(semaphore);
//        }];
//        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//        [BleManager.shareInstance readWithCMDString:@"708" count:4 finish:^(NSArray * _Nonnull array) {
//            if ([self.dataArray[0] count] >=2) {
//                NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
//                [dict setValue:[NSString stringWithFormat:@"%@:%@",array[0],array[1]] forKey:@"startTime"];
//                [dict setValue:[NSString stringWithFormat:@"%@:%@",array[2],array[3]] forKey:@"endTime"];
//                NSMutableArray * indexArray = [[NSMutableArray alloc] initWithArray:self.dataArray[0]];
//                NSMutableArray * valueArray = [[NSMutableArray alloc] initWithArray:indexArray[1]];
//                [valueArray replaceObjectAtIndex:0 withObject:dict];
//                [indexArray replaceObjectAtIndex:1 withObject:valueArray];
//                [self.dataArray replaceObjectAtIndex:0 withObject:indexArray];
//            }
//            dispatch_semaphore_signal(semaphore);
//        }];
//        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//        [BleManager.shareInstance readWithCMDString:@"70E" count:4 finish:^(NSArray * _Nonnull array) {
//            if ([self.dataArray[0] count] >=3) {
//                NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
//                [dict setValue:[NSString stringWithFormat:@"%@:%@",array[0],array[1]] forKey:@"startTime"];
//                [dict setValue:[NSString stringWithFormat:@"%@:%@",array[2],array[3]] forKey:@"endTime"];
//                NSMutableArray * indexArray = [[NSMutableArray alloc] initWithArray:self.dataArray[0]];
//                NSMutableArray * valueArray = [[NSMutableArray alloc] initWithArray:indexArray[2]];
//                [valueArray replaceObjectAtIndex:0 withObject:dict];
//                [indexArray replaceObjectAtIndex:2 withObject:valueArray];
//                [self.dataArray replaceObjectAtIndex:0 withObject:indexArray];
//            }
//            dispatch_semaphore_signal(semaphore);
//        }];
//    });
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
    label.text = section == 0 ? @"Off-peak time".localized : (section == 1 ? @"Peak time".localized : @"Super peak time".localized);
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
