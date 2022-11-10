//
//  MessageDetailViewController.m
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/11/10.
//

#import "MessageDetailViewController.h"
#import "MessageDetailTableViewCell.h"
#import "MessageModel.h"

@interface MessageDetailViewController ()

@property(nonatomic,weak)IBOutlet UITableView * tableView;
@property(nonatomic,strong)NSString * messageId;
@property(nonatomic,strong)MessageModel * model;

@end

@implementation MessageDetailViewController

- (instancetype)initWithMessageId:(NSString *)messageId
{
    self = [super init];
    if (self) {
        self.messageId = messageId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([MessageDetailTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([MessageDetailTableViewCell class])];
    [self getMessageDetail];
    
}

- (void)getMessageDetail{
    [Request.shareInstance getUrl:[NSString stringWithFormat:@"%@/%@",MessageDetail,self.messageId] params:@{} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        self.model = [MessageModel mj_objectWithKeyValues:result[@"data"]];
        [self.tableView reloadData];
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([MessageDetailTableViewCell class]) forIndexPath:indexPath];
    cell.model = self.model;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
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
