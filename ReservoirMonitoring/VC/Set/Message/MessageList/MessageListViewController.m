//
//  MessageListViewController.m
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/11/8.
//

#import "MessageListViewController.h"
#import "MessageListTableViewCell.h"
#import "MessageModel.h"
#import "RefreshBackFooter.h"

@interface MessageListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,weak)IBOutlet UITableView * tableView;
@property(nonatomic,strong) NSMutableArray<MessageModel*> * dataArray;
@property(nonatomic,assign) NSInteger page;

@end

@implementation MessageListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.page = 1;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([MessageListTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([MessageListTableViewCell class])];
    [self getMessageListData];
    self.tableView.mj_footer = [RefreshBackFooter footerWithRefreshingBlock:^{
        self.page++;
        [self getMessageListData];
    }];
}

- (void)getMessageListData{
    [Request.shareInstance getUrl:MessageList params:@{@"type":self.type,@"pageNo":[NSString stringWithFormat:@"%ld",self.page],@"pageSize":@"10"} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        self.dataArray = [MessageModel mj_objectArrayWithKeyValuesArray:result[@"data"]];
        [self.tableView.mj_footer endRefreshing];
        [self.tableView reloadData];
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageListTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([MessageListTableViewCell class]) forIndexPath:indexPath];
    cell.model = self.dataArray[indexPath.section];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 206;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
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
