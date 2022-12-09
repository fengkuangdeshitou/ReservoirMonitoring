//
//  ServiceViewController.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/5/14.
//

#import "ServiceViewController.h"
#import "SelecteTableViewCell.h"
#import "SelectItemAlertView.h"
#import "GlobelDescAlertView.h"
#import "UserModel.h"
#import "ServiceInputTableViewCell.h"
#import "ServiceDescTableViewCell.h"
#import "InfoViewController.h"
@import AFNetworking;

@interface ServiceViewController ()<UITableViewDelegate,UITextViewDelegate>

@property(nonatomic,weak)IBOutlet UITableView * tableView;
@property(nonatomic,strong)NSMutableArray * dataArray;
@property(nonatomic,weak)IBOutlet UIButton * submit;
@property(nonatomic,weak)IBOutlet UILabel * time;
@property(nonatomic,strong) NSTimer * timer;
@property(nonatomic,assign) NSInteger timeCount;
@property(nonatomic,strong) UserModel * model;
@property(nonatomic,strong) NSString * hotline;
@property(nonatomic,strong) NSString * cacheCategory;
@property(nonatomic,strong) NSString * cacheDesc;

@end

@implementation ServiceViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self requestUserInfo];
    [self getHotlineNumber];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self removeTimer];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (![RMHelper.getCurrentVC isKindOfClass:[InfoViewController class]] && ![RMHelper.getCurrentVC isKindOfClass:NSClassFromString(@"HelpViewController")]){
            self.cacheCategory = nil;
            self.cacheDesc = nil;
        }
    });
}

- (void)removeTimer{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)requestUserInfo{
    [Request.shareInstance getUrl:UserInfo params:@{} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        self.model = [UserModel mj_objectWithKeyValues:result[@"data"]];
        NSString * reason = @"None".localized;
        if ([NSUserDefaults.standardUserDefaults objectForKey:[self reasonCacheKey]]) {
            reason = [NSUserDefaults.standardUserDefaults objectForKey:[self reasonCacheKey]];
        }else{
            if (self.cacheCategory){
                reason = self.cacheCategory;
            }
        }
        NSString * desc = @"";
        if ([NSUserDefaults.standardUserDefaults objectForKey:[self descCacheKey]]) {
            desc = [NSUserDefaults.standardUserDefaults objectForKey:[self descCacheKey]];
        }else{
            if (self.cacheDesc){
                desc = self.cacheDesc;
            }
        }
        self.dataArray = [[NSMutableArray alloc] initWithArray:@[
            @{@"title":@"",@"placeholder":@""},
            @{@"title":@"Category",@"placeholder":reason},
            @{@"title":@"Description".localized,@"placeholder":desc}
            ]];
        [self.tableView reloadData];
        self.time.hidden = false;
        [self loadTimer];
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(requestUserInfo) name:UIApplicationWillEnterForegroundNotification object:nil];
    [self setLeftBarImageForSel:nil];
    self.time.text = @"Can't submit twice in 30 minutes.".localized;
    [self loadSubmitStyle:false];
    self.dataArray = [[NSMutableArray alloc] initWithArray:@[
        @{@"title":@"",@"placeholder":@""},
        @{@"title":@"Category",@"placeholder":@"None".localized},
        @{@"title":@"Description".localized,@"placeholder":@""}
        ]];
    [self loadTimer];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ServiceDescTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([ServiceDescTableViewCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SelecteTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([SelecteTableViewCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ServiceInputTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([ServiceInputTableViewCell class])];
}

- (void)getHotlineNumber{
    [Request.shareInstance getUrl:ServiceData params:@{} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        self.hotline = result[@"data"][@"hotline"];
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
}

- (void)loadSubmitStyle:(BOOL)status{
    if (status){
        self.submit.userInteractionEnabled = true;
        [self.submit showBorderWithRadius:25];
        [self.submit setTitle:@"Submit".localized forState:UIControlStateNormal];
        [self.submit setTitleColor:[UIColor colorWithHexString:COLOR_MAIN_COLOR] forState:UIControlStateNormal];
    }else{
        self.submit.userInteractionEnabled = false;
        [self.submit setTitle:@"Submit".localized forState:UIControlStateNormal];
        [self.submit setTitleColor:[UIColor colorWithHexString:@"#999999"] forState:UIControlStateNormal];
        self.submit.layer.borderColor = [UIColor colorWithHexString:@"#999999"].CGColor;
    }
}

- (void)resetTableivewData{
    [NSUserDefaults.standardUserDefaults removeObjectForKey:self.model.email];
    [NSUserDefaults.standardUserDefaults removeObjectForKey:[self reasonCacheKey]];
    [NSUserDefaults.standardUserDefaults removeObjectForKey:[self descCacheKey]];
    [self.dataArray replaceObjectAtIndex:1 withObject:@{@"title":@"Case Reason",@"placeholder":@"None".localized}];
    [self.dataArray replaceObjectAtIndex:2 withObject:@{@"title":@"Description",@"placeholder":@""}];
    [self.tableView reloadData];
}

- (void)loadTimer{
    if ([NSUserDefaults.standardUserDefaults objectForKey:self.model.email]) {
        NSString * string = [NSUserDefaults.standardUserDefaults objectForKey:self.model.email];
        if ([[self getCurrentTimeString] integerValue] - [string integerValue] > 30*60) {
            if (self.timer){
                [self removeTimer];
            }
            [self loadSubmitStyle:true];
            [self resetTableivewData];
            return;
        }
        [self loadSubmitStyle:false];
        self.timeCount = 30*60-([[self getCurrentTimeString] integerValue] - [string integerValue]);
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"mm:ss"];
        [self.submit setTitle:[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.timeCount]] forState:UIControlStateNormal];
        if (!_timer) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:true block:^(NSTimer * _Nonnull timer) {
                self.timeCount --;
                if (self.timeCount == 0) {
                    [self removeTimer];
                    [self loadSubmitStyle:true];
                    [self resetTableivewData];
                }else{
                    [self loadSubmitStyle:false];
                    [self.submit setTitle:[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.timeCount]] forState:UIControlStateNormal];
                    ServiceInputTableViewCell * cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                    cell.content.userInteractionEnabled = false;
                }
            }];
            [NSRunLoop.currentRunLoop addTimer:self.timer forMode:NSRunLoopCommonModes];
        }
    }else{
        [self loadSubmitStyle:true];
        [NSUserDefaults.standardUserDefaults removeObjectForKey:[self reasonCacheKey]];
        if (RMHelper.getUserType || !self.model.defDevSgSn || RMHelper.isTouristsModel) {
            [self loadSubmitStyle:false];
        }
    }
}

- (IBAction)submitAction:(id)sender{
    if (self.model.defDevSgSn.length == 0) {
        [GlobelDescAlertView showAlertViewWithTitle:@"Tips" desc:@"Smart Gateway SN cannot be empty" btnTitle:nil completion:nil];
        return;
    }
    if (self.model.phonenumber.length == 0){
        [GlobelDescAlertView showAlertViewWithTitle:@"Tips" desc:@"Personal contact missing, please provide a mobile phone number to proceed." btnTitle:nil completion:^{
            ServiceInputTableViewCell * cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
            self.cacheCategory = self.dataArray[1][@"placeholder"];
            self.cacheDesc = cell.content.text;
            InfoViewController * info = [[InfoViewController alloc] init];
            info.title = @"Info";
            info.model = self.model;
            info.hidesBottomBarWhenPushed = true;
            [self.navigationController pushViewController:info animated:true];
        }];
        return;
    }
    ServiceInputTableViewCell * cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    NSDictionary * params = @{@"encoding":@"UTF-8",
                              @"orgid":@"00D8c000003UHSM",
                              @"retURL":@"www.moonflow.com",
                              @"name":self.model.nickName?:@"",
                              @"email":self.model.email?:@"",
                              @"phone":self.model.phonenumber?:@"",
                              @"subject":self.model.defDevSgSn?[self formatDefDevSgSn]:@"",
                              @"reason":self.dataArray[1][@"placeholder"],
                              @"description":cell.content.text.length>0?cell.content.text:@"",
                              @"external":@"1"};
    NSLog(@"params=%@",params);
    [self.view showHUDToast:@"Loading"];
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain", nil];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:@"https://webto.salesforce.com/servlet/servlet.WebToCase" parameters:params headers:@{} progress:^(NSProgress * _Nonnull uploadProgress) {
            
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self.view hiddenHUD];
        NSString * data = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"obj=%@",data);
        [NSUserDefaults.standardUserDefaults setValue:self.dataArray[1][@"placeholder"] forKey:[self reasonCacheKey]];
        [NSUserDefaults.standardUserDefaults setValue:params[@"description"] forKey:[self descCacheKey]];
        NSString * string = [self getCurrentTimeString];
        NSLog(@"strint=%@",string);
        [NSUserDefaults.standardUserDefaults setValue:string forKey:self.model.email];
        [self loadTimer];
        [GlobelDescAlertView showAlertViewWithTitle:@"Ticket received".localized desc:@"The manufacturer will contact you via Email or phone call within the next hour regarding the case, please pay attention.".localized btnTitle:nil completion:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.view hiddenHUD];
    }];
}

- (NSString *)reasonCacheKey{
    return [NSString stringWithFormat:@"%@_reasonCacheKey",self.model.email];
}

- (NSString *)descCacheKey{
    return [NSString stringWithFormat:@"%@_descCacheKey",self.model.email];
}

- (NSString *)formatDefDevSgSn{
    NSMutableString * string = [[NSMutableString alloc] initWithString:self.model.defDevSgSn];
    if (string.length == 21) {
        [string insertString:@"-" atIndex:4];
        [string insertString:@"-" atIndex:10];
        [string insertString:@"-" atIndex:13];
    }
    return string;
}

- (NSString *)getCurrentTimeString{
    NSDate * date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval time = [date timeIntervalSince1970];
    NSString * string = [NSString stringWithFormat:@"%.0f",time];
    return string;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 1) {
        SelecteTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SelecteTableViewCell class]) forIndexPath:indexPath];
        cell.titleLabel.text = self.dataArray[indexPath.row][@"title"];
        cell.content.text = self.dataArray[indexPath.row][@"placeholder"];
        return cell;
    }else if (indexPath.row == 2) {
        ServiceInputTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ServiceInputTableViewCell class]) forIndexPath:indexPath];
        cell.titleLabel.text = self.dataArray[indexPath.row][@"title"];
        cell.content.text = self.dataArray[indexPath.row][@"placeholder"];
        cell.content.userInteractionEnabled = !RMHelper.getUserType && ![NSUserDefaults.standardUserDefaults objectForKey:[self descCacheKey]] && !RMHelper.isTouristsModel && self.model.defDevSgSn;
        return cell;
    }else{
        ServiceDescTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ServiceDescTableViewCell class]) forIndexPath:indexPath];
        cell.hotline = self.hotline;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (RMHelper.isTouristsModel || !self.model.defDevSgSn){
        return;
    }
    if (indexPath.row == self.dataArray.count-2) {
        if ([NSUserDefaults.standardUserDefaults objectForKey:[self reasonCacheKey]] || RMHelper.getUserType) {
            return;
        }
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section]];
        CGRect frame = [cell.superview convertRect:cell.frame toView:UIApplication.sharedApplication.keyWindow];
        [SelectItemAlertView showSelectItemAlertViewWithDataArray:@[@"None".localized,@"Product Installation".localized,@"Product Inquiry".localized,@"Product Issue / Repair".localized,@"Customer Complaint".localized] tableviewFrame:CGRectMake(SCREEN_WIDTH/2, frame.origin.y, SCREEN_WIDTH/2, 50*5) completion:^(NSString * _Nonnull value, NSInteger idx) {
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithDictionary:self.dataArray[indexPath.row]];
            dict[@"placeholder"] = value;
            self.dataArray[indexPath.row] = dict;
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0){
        return UITableViewAutomaticDimension;
    }else if (indexPath.row == 1){
        return 53;
    }else{
        return indexPath.row == 2 ? 156 : 53;
    }
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
