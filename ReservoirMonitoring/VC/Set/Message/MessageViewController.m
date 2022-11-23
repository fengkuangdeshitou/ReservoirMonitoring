//
//  MessageViewController.m
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/11/7.
//

#import "MessageViewController.h"
#import "MessageTableViewCell.h"
#import "MessageModel.h"
#import "MessageListViewController.h"

@interface MessageViewController ()<UITableViewDelegate>

@property(nonatomic,weak)IBOutlet UITableView * tableView;
@property(nonatomic,strong) NSArray<MessageModel*> * dataArray;


@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([MessageTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([MessageTableViewCell class])];
    self.tableView.refreshControl = self.refreshController;
    [self.refreshController addTarget:self action:@selector(refreshMessageData) forControlEvents:UIControlEventValueChanged];
    [self setRightBarButtonItemWithTitlt:@"Read all" sel:@selector(readAllAction)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithHexString:COLOR_MAIN_COLOR];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getMessageList];
}

- (void)refreshMessageData{
    [self.refreshController endRefreshing];
    [self getMessageList];
}

- (void)readAllAction{
    [Request.shareInstance getUrl:ReadAll params:@{} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        [self getMessageList];
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
}

- (void)getMessageList{
    [Request.shareInstance getUrl:MessageTypeInfo params:@{} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        self.dataArray = [MessageModel mj_objectArrayWithKeyValuesArray:result[@"data"]];
        [self.tableView reloadData];
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([MessageTableViewCell class]) forIndexPath:indexPath];
    cell.model = self.dataArray[indexPath.row];
    cell.line.hidden = indexPath.row == self.dataArray.count-1;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageListViewController * list = [[MessageListViewController alloc] init];
    list.type = self.dataArray[indexPath.row].type;
    list.title = self.dataArray[indexPath.row].typeName;
    [self.navigationController pushViewController:list animated:true];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 86;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 15;
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
