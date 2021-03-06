//
//  ServiceViewController.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/5/14.
//

#import "ServiceViewController.h"
#import "InputTableViewCell.h"
#import "SelecteTableViewCell.h"
#import "SelectItemAlertView.h"
#import "GlobelDescAlertView.h"
#import "UserModel.h"
@import AFNetworking;

@interface ServiceViewController ()<UITableViewDelegate>

@property(nonatomic,weak)IBOutlet UITableView * tableView;
@property(nonatomic,strong)NSMutableArray * dataArray;
@property(nonatomic,weak)IBOutlet UIButton * submit;
@property(nonatomic,weak)IBOutlet UILabel * time;
@property(nonatomic,strong) NSTimer * timer;
@property(nonatomic,assign) NSInteger timeCount;
@property(nonatomic,strong)UserModel * model;

@end

@implementation ServiceViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self requestUserInfo];
}

- (void)requestUserInfo{
    [Request.shareInstance getUrl:UserInfo params:@{} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        self.model = [UserModel mj_objectWithKeyValues:result[@"data"]];
        [self loadTimer];
        self.dataArray = [[NSMutableArray alloc] initWithArray:@[
            @{@"title":@"Contact name".localized,@"placeholder":self.model.nickName},
            @{@"title":@"Email".localized,@"placeholder":self.model.email},
            @{@"title":@"Phone".localized,@"placeholder":self.model.phonenumber?:@""},
            @{@"title":@"SN",@"placeholder":self.model.defDevSgSn?:@""},
            @{@"title":@"Case Reason",@"placeholder":@"None".localized},
            @{@"title":@"Description".localized,@"placeholder":@""}
            ]];
        [self.tableView reloadData];
        self.submit.hidden = false;
        self.time.hidden = false;
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setLeftBarImageForSel:nil];
    self.time.text = @"Can't submit twice in 30 minutes.".localized;
    [self.submit showBorderWithRadius:25];
    self.submit.hidden = true;
    self.time.hidden = true;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([InputTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([InputTableViewCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SelecteTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([SelecteTableViewCell class])];

}

- (void)loadTimer{
    if ([NSUserDefaults.standardUserDefaults objectForKey:self.model.email]) {
        NSString * string = [NSUserDefaults.standardUserDefaults objectForKey:self.model.email];
        self.timeCount = 30*60-([[self getCurrentTimeString] integerValue] - [string integerValue]);
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"mm:ss"];
        [self.submit setTitle:[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.timeCount]] forState:UIControlStateNormal];
        if (!_timer) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:true block:^(NSTimer * _Nonnull timer) {
                self.timeCount --;
                if (self.timeCount == 0) {
                    self.submit.userInteractionEnabled = true;
                    [NSUserDefaults.standardUserDefaults removeObjectForKey:self.model.email];
                    [self.submit setTitle:@"Submit".localized forState:UIControlStateNormal];
                    [self.submit setTitleColor:[UIColor colorWithHexString:COLOR_MAIN_COLOR] forState:UIControlStateNormal];
                    self.submit.layer.borderColor = [UIColor colorWithHexString:COLOR_MAIN_COLOR].CGColor;
                }else{
                    self.submit.userInteractionEnabled = false;
                    [self.submit setTitle:[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.timeCount]] forState:UIControlStateNormal];
                    [self.submit setTitleColor:[UIColor colorWithHexString:@"#999999"] forState:UIControlStateNormal];
                    self.submit.layer.borderColor = [UIColor colorWithHexString:@"#999999"].CGColor;
                }
            }];
        }
    }else{
        [self.submit setTitle:@"Submit".localized forState:UIControlStateNormal];
    }
}

- (IBAction)submitAction:(id)sender{
    NSDictionary * params = @{@"encoding":@"UTF-8",
                              @"orgid":@"00D8c000003UHSM",
                              @"retURL":@"www.moonflow.com",
                              @"name":self.model.nickName,
                              @"email":self.model.email,
                              @"phone":self.model.phonenumber,
                              @"subject":@"",
                              @"reason":self.dataArray[4][@"placeholder"],
                              @"description":@"",
                              @"external":@"1"};
    NSLog(@"params=%@",params);
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain", nil];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:@"https://webto.salesforce.com/servlet/servlet.WebToCase" parameters:params headers:@{} progress:^(NSProgress * _Nonnull uploadProgress) {
            
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString * data = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"obj=%@",data);
        
        NSString * string = [self getCurrentTimeString];
        NSLog(@"strint=%@",string);
        [NSUserDefaults.standardUserDefaults setValue:string forKey:self.model.email];
        [self loadTimer];
        [GlobelDescAlertView showAlertViewWithTitle:@"Ticket received".localized desc:@"The manufacturer will contact you via Email or phone call within the next hour regarding the case, please pay attention.".localized btnTitle:nil completion:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

    }];
}

- (NSString *)getCurrentTimeString{
    NSDate * date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval time = [date timeIntervalSince1970];
    NSString * string = [NSString stringWithFormat:@"%.0f",time];
    return string;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.dataArray.count-2) {
        SelecteTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SelecteTableViewCell class]) forIndexPath:indexPath];
        cell.titleLabel.text = self.dataArray[indexPath.row][@"title"];
        cell.content.text = self.dataArray[indexPath.row][@"placeholder"];
        return cell;
    }else{
        InputTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([InputTableViewCell class]) forIndexPath:indexPath];
        cell.titleLabel.text = self.dataArray[indexPath.row][@"title"];
        cell.textfield.text = self.dataArray[indexPath.row][@"placeholder"];
        if (indexPath.row <= 3) {
            cell.textfield.userInteractionEnabled = false;
        }else{
            cell.textfield.userInteractionEnabled = true;
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.dataArray.count-2) {
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section]];
        CGRect frame = [cell.superview convertRect:cell.frame toView:UIApplication.sharedApplication.keyWindow];
        [SelectItemAlertView showSelectItemAlertViewWithDataArray:@[@"None".localized,@"Product Installation".localized,@"Product Inquiry".localized,@"Product Issue / Repair".localized,@"Customer Complaint".localized] tableviewFrame:CGRectMake(SCREEN_WIDTH/2, frame.origin.y, SCREEN_WIDTH/2, 50*5) completion:^(NSString * _Nonnull value, NSInteger idx) {
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithDictionary:self.dataArray[indexPath.row]];
            dict[@"placeholder"] = value;
            self.dataArray[indexPath.row] = dict;
            [tableView reloadData];
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 53;
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
