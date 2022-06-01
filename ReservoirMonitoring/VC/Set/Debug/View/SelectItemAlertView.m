//
//  SelectItemAlertView.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/5/14.
//

#import "SelectItemAlertView.h"

@interface SelectItemAlertView ()<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>

@property(nonatomic,strong) UITableView * tableView;
@property(nonatomic,strong) NSArray * dataArray;
@property(nonatomic,copy) void(^completion)(NSString * value, NSInteger idx);

@end

@implementation SelectItemAlertView

+ (void)showSelectItemAlertViewWithDataArray:(NSArray<NSString *> *)dataArray tableviewFrame:(CGRect)tableviewFrame completion:(void (^)(NSString * _Nonnull, NSInteger idx))completion{
    SelectItemAlertView * alertView = [[SelectItemAlertView alloc] init];
    alertView.frame = UIScreen.mainScreen.bounds;
    alertView.alpha = 0;
    alertView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.7];
    [UIApplication.sharedApplication.keyWindow addSubview:alertView];
    alertView.completion = completion;
    alertView.dataArray = dataArray;
    if (tableviewFrame.origin.y + tableviewFrame.size.height > SCREEN_HEIGHT) {
        tableviewFrame = CGRectMake(tableviewFrame.origin.x, SCREEN_HEIGHT-tableviewFrame.size.height, tableviewFrame.size.width, tableviewFrame.size.height);
    }
    alertView.tableView = [[UITableView alloc] initWithFrame:tableviewFrame style:UITableViewStylePlain];
    alertView.tableView.delegate = alertView;
    alertView.tableView.dataSource = alertView;
    alertView.tableView.tableHeaderView = [UIView new];
    alertView.tableView.tableFooterView = [UIView new];
    alertView.tableView.scrollEnabled = false;
    alertView.tableView.backgroundColor = [UIColor colorWithHexString:COLOR_BACK_COLOR];
    [alertView addSubview:alertView.tableView];
    [alertView show];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:alertView action:@selector(dismiss)];
    tap.delegate = alertView;
    [alertView addGestureRecognizer:tap];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return YES;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * cellIdentifity = @"cellIdentifity";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifity];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifity];
    }
    cell.contentView.backgroundColor = tableView.backgroundColor;
    cell.textLabel.text = self.dataArray[indexPath.row];
    cell.textLabel.textColor = UIColor.whiteColor;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.completion){
        [self dismiss];
        self.completion(self.dataArray[indexPath.row],indexPath.row);
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
