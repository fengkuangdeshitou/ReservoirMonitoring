//
//  WarningListView.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/19.
//

#import "WarningListView.h"
#import "WarningTableViewCell.h"

@interface WarningListView ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UITableView * tableView;

@end

@implementation WarningListView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStyleGrouped];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundColor = [UIColor colorWithHexString:@"#0C0C0C"];
        [self addSubview:self.tableView];
        [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([WarningTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([WarningTableViewCell class])];
    }
    return self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WarningTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WarningTableViewCell class]) forIndexPath:indexPath];
    cell.typeLabel.textColor = [UIColor colorWithHexString:self.tag == 10 ? @"#EE8805" : @"#AE0000"];
    cell.typeLabel.text = self.tag == 10 ? @"Alarm".localized : @"Fault".localized;
    cell.time.text = self.tag == 10 ? @"Alarm Time".localized : @"Fault Time".localized;
    cell.line.hidden = indexPath.row == 4;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
