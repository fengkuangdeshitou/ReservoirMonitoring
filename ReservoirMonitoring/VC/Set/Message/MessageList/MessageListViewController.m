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
#import "MessageDetailViewController.h"

@interface MessageListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,weak)IBOutlet UITableView * tableView;
@property(nonatomic,strong) NSMutableArray<MessageModel*> * dataArray;
@property(nonatomic,assign) NSInteger page;
@property(nonatomic,weak)IBOutlet UIView * normalView;

@end

@implementation MessageListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.page = 1;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([MessageListTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([MessageListTableViewCell class])];
    [self getMessageListData];
    self.tableView.refreshControl = self.refreshController;
    [self.refreshController addTarget:self action:@selector(refreshMessageData) forControlEvents:UIControlEventValueChanged];
    self.tableView.mj_footer = [RefreshBackFooter footerWithRefreshingBlock:^{
        self.page++;
        [self getMessageListData];
    }];
    [self setRightBarButtonItemWithTitlt:@"Read all" sel:@selector(readAllAction)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithHexString:COLOR_MAIN_COLOR];
}

- (void)refreshMessageData{
    [self.refreshController endRefreshing];
    self.page = 1;
    [self getMessageListData];
}

- (void)readAllAction{
    [Request.shareInstance getUrl:[NSString stringWithFormat:@"%@/%@",ReadAll,self.type] params:@{} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        self.page = 1;
        [self getMessageListData];
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
}

- (void)getMessageListData{
    [Request.shareInstance getUrl:MessageList params:@{@"type":self.type,@"pageNo":[NSString stringWithFormat:@"%ld",self.page],@"pageSize":@"10"} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        NSArray * modelArray = [MessageModel mj_objectArrayWithKeyValuesArray:result[@"data"]];
        if (self.page == 1){
            self.dataArray = [[NSMutableArray alloc] initWithArray:modelArray];
        }else{
            [self.dataArray addObjectsFromArray:modelArray];
        }
        [self.tableView.mj_footer endRefreshing];
        [self.tableView reloadData];
        self.normalView.hidden = self.dataArray.count != 0;
    } failure:^(NSString * _Nonnull errorMsg) {
        [self.tableView.mj_footer endRefreshing];
    }];
}

- (void)readMessage:(NSString *)messageId{
    [Request.shareInstance getUrl:[NSString stringWithFormat:@"%@/%@",Read,messageId] params:@{} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageListTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([MessageListTableViewCell class]) forIndexPath:indexPath];
    cell.model = self.dataArray[indexPath.section];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageModel * model = self.dataArray[indexPath.section];
    if (model.ready.intValue == 0){
        model.ready = @"1";
        [self readMessage:model.Id];
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    MessageDetailViewController * detail = [[MessageDetailViewController alloc] initWithMessageId:model.Id];
    detail.title = @"Message details";
    [self.navigationController pushViewController:detail animated:true];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
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
