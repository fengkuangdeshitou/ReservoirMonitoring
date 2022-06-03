//
//  PeakTimeTableViewCell.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/16.
//

#import "PeakTimeTableViewCell.h"
#import "TimeTableViewCell.h"

@interface PeakTimeTableViewCell ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,weak)IBOutlet UITableView * tableView;
@property(nonatomic,weak)IBOutlet UILabel * titleLabel;
@property(nonatomic,weak)IBOutlet UIButton * gridBtn;

@end

@implementation PeakTimeTableViewCell

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
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [BleManager.shareInstance readWithCMDString:@"6FE" count:2 finish:^(NSArray * _Nonnull array) {
            dispatch_semaphore_signal(semaphore);
            self.gridBtn.selected = [array.firstObject boolValue];
            NSInteger count = [array.lastObject integerValue];
            NSMutableArray * countArray = [[NSMutableArray alloc] init];
            for (int i=0; i<count; i++) {
                NSDictionary * dict = @{@"startTime":@"",@"endTime":@"",@"price":@""};
                [countArray addObject:dict];
            }
            [self.dataArray replaceObjectAtIndex:0 withObject:countArray];
            [self.tableView reloadData];
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"702" count:4 finish:^(NSArray * _Nonnull array) {
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
            [dict setValue:[NSString stringWithFormat:@"%@:%@",array[0],array[1]] forKey:@"startTime"];
            [dict setValue:[NSString stringWithFormat:@"%@:%@",array[2],array[3]] forKey:@"endTime"];
            NSMutableArray * indexArray = [[NSMutableArray alloc] initWithArray:self.dataArray[0]];
            NSMutableArray * valueArray = [[NSMutableArray alloc] initWithArray:indexArray[0]];
            [valueArray replaceObjectAtIndex:0 withObject:dict];
            [indexArray replaceObjectAtIndex:0 withObject:valueArray];
            [self.dataArray replaceObjectAtIndex:0 withObject:indexArray];
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"708" count:4 finish:^(NSArray * _Nonnull array) {
            if ([self.dataArray[0] count] >=2) {
                NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
                [dict setValue:[NSString stringWithFormat:@"%@:%@",array[0],array[1]] forKey:@"startTime"];
                [dict setValue:[NSString stringWithFormat:@"%@:%@",array[2],array[3]] forKey:@"endTime"];
                NSMutableArray * indexArray = [[NSMutableArray alloc] initWithArray:self.dataArray[0]];
                NSMutableArray * valueArray = [[NSMutableArray alloc] initWithArray:indexArray[1]];
                [valueArray replaceObjectAtIndex:0 withObject:dict];
                [indexArray replaceObjectAtIndex:1 withObject:valueArray];
                [self.dataArray replaceObjectAtIndex:0 withObject:indexArray];
            }
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [BleManager.shareInstance readWithCMDString:@"70E" count:4 finish:^(NSArray * _Nonnull array) {
            if ([self.dataArray[0] count] >=3) {
                NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
                [dict setValue:[NSString stringWithFormat:@"%@:%@",array[0],array[1]] forKey:@"startTime"];
                [dict setValue:[NSString stringWithFormat:@"%@:%@",array[2],array[3]] forKey:@"endTime"];
                NSMutableArray * indexArray = [[NSMutableArray alloc] initWithArray:self.dataArray[0]];
                NSMutableArray * valueArray = [[NSMutableArray alloc] initWithArray:indexArray[2]];
                [valueArray replaceObjectAtIndex:0 withObject:dict];
                [indexArray replaceObjectAtIndex:2 withObject:valueArray];
                [self.dataArray replaceObjectAtIndex:0 withObject:indexArray];
            }
            dispatch_semaphore_signal(semaphore);
        }];
    });
}

- (void)updateTableViewHeight{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView setNeedsLayout];
        [self.tableView layoutIfNeeded];
        NSLog(@"---%f",self.tableView.contentSize.height);
        [NSUserDefaults.standardUserDefaults setValue:[NSNumber numberWithFloat:self.tableView.contentSize.height] forKey:TIME_TABLEVIEW_HEIGHT_CHANGE];
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
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, SCREEN_WIDTH, 40)];
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
    return 40;
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
    [array addObject:@{}];
    [self.dataArray removeObjectAtIndex:index];
    [self.dataArray insertObject:array atIndex:index];
    [self.tableView reloadData];
    [self updateTableViewHeight];
}

- (void)removeButtonAction:(UIButton *)btn{
    TimeTableViewCell * cell = (TimeTableViewCell *)[[[btn superview] superview] superview];
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    NSMutableArray * array = [[NSMutableArray alloc] initWithArray:self.dataArray[indexPath.section]];
    [array removeObjectAtIndex:indexPath.row];
    [self.dataArray removeObjectAtIndex:indexPath.section];
    [self.dataArray insertObject:array atIndex:indexPath.row];
    [self.tableView reloadData];
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
