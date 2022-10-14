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
#import "ServiceInputTableViewCell.h"
@import AFNetworking;

@interface ServiceViewController ()<UITableViewDelegate,UITextFieldDelegate,UITextViewDelegate>

@property(nonatomic,weak)IBOutlet UITableView * tableView;
@property(nonatomic,strong)NSMutableArray * dataArray;
@property(nonatomic,weak)IBOutlet UIButton * submit;
@property(nonatomic,weak)IBOutlet UILabel * time;
@property(nonatomic,strong) NSTimer * timer;
@property(nonatomic,assign) NSInteger timeCount;
@property(nonatomic,strong) UserModel * model;
@property(nonatomic,assign) CGFloat descHeight;

@end

@implementation ServiceViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self requestUserInfo];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
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
        }
        NSString * desc = @"";
        if ([NSUserDefaults.standardUserDefaults objectForKey:[self descCacheKey]]) {
            desc = [NSUserDefaults.standardUserDefaults objectForKey:[self descCacheKey]];
        }
        self.dataArray = [[NSMutableArray alloc] initWithArray:@[
            @{@"title":@"Contact name".localized,@"placeholder":self.model.nickName},
            @{@"title":@"Email".localized,@"placeholder":self.model.email},
            @{@"title":@"Phone".localized,@"placeholder":self.model.phonenumber?:@""},
            @{@"title":@"SN",@"placeholder":self.model.defDevSgSn?:@""},
            @{@"title":@"Case Reason",@"placeholder":reason},
            @{@"title":@"Description".localized,@"placeholder":desc}
            ]];
        [self.tableView reloadData];
        self.submit.hidden = false;
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
    [self.submit showBorderWithRadius:25];
    self.dataArray = [[NSMutableArray alloc] initWithArray:@[
        @{@"title":@"Contact name".localized,@"placeholder":@"--"},
        @{@"title":@"Email".localized,@"placeholder":@"--"},
        @{@"title":@"Phone".localized,@"placeholder":@"--"},
        @{@"title":@"SN",@"placeholder":@""},
        @{@"title":@"Case Reason",@"placeholder":@"None".localized},
        @{@"title":@"Description".localized,@"placeholder":@""}
        ]];
    [self loadTimer];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([InputTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([InputTableViewCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SelecteTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([SelecteTableViewCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ServiceInputTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([ServiceInputTableViewCell class])];
}

- (void)loadTimer{
    if ([NSUserDefaults.standardUserDefaults objectForKey:self.model.email]) {
        NSString * string = [NSUserDefaults.standardUserDefaults objectForKey:self.model.email];
        if ([[self getCurrentTimeString] integerValue] - [string integerValue] > 30*60) {
            self.submit.userInteractionEnabled = true;
            [NSUserDefaults.standardUserDefaults removeObjectForKey:self.model.email];
            [self.submit setTitle:@"Submit".localized forState:UIControlStateNormal];
            [self.submit setTitleColor:[UIColor colorWithHexString:COLOR_MAIN_COLOR] forState:UIControlStateNormal];
            self.submit.layer.borderColor = [UIColor colorWithHexString:COLOR_MAIN_COLOR].CGColor;
            [NSUserDefaults.standardUserDefaults removeObjectForKey:[self reasonCacheKey]];
            [self.dataArray replaceObjectAtIndex:4 withObject:@{@"title":@"Case Reason",@"placeholder":@"None".localized}];
            [NSUserDefaults.standardUserDefaults removeObjectForKey:[self descCacheKey]];
            [self.dataArray replaceObjectAtIndex:5 withObject:@{@"title":@"Description",@"placeholder":@""}];
            [self.tableView reloadData];
            return;
        }
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
                    [NSUserDefaults.standardUserDefaults removeObjectForKey:[self reasonCacheKey]];
                    [self.dataArray replaceObjectAtIndex:4 withObject:@{@"title":@"Case Reason",@"placeholder":@"None".localized}];
                    [NSUserDefaults.standardUserDefaults removeObjectForKey:[self descCacheKey]];
                    [self.dataArray replaceObjectAtIndex:5 withObject:@{@"title":@"Description",@"placeholder":@""}];
                    [self.tableView reloadData];
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
        [NSUserDefaults.standardUserDefaults removeObjectForKey:[self reasonCacheKey]];
        if (RMHelper.getUserType) {
            self.submit.userInteractionEnabled = false;
            [self.submit setTitleColor:[UIColor colorWithHexString:@"#999999"] forState:UIControlStateNormal];
            self.submit.layer.borderColor = [UIColor colorWithHexString:@"#999999"].CGColor;
        }
    }
}

- (IBAction)submitAction:(id)sender{
    if (self.model.defDevSgSn.length == 0) {
        [GlobelDescAlertView showAlertViewWithTitle:@"Tips" desc:@"Smart Gateway SN cannot be empty" btnTitle:nil completion:nil];
        return;
    }
    InputTableViewCell * cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
    NSDictionary * params = @{@"encoding":@"UTF-8",
                              @"orgid":@"00D8c000003UHSM",
                              @"retURL":@"www.moonflow.com",
                              @"name":self.model.nickName?:@"",
                              @"email":self.model.email?:@"",
                              @"phone":self.model.phonenumber?:@"",
                              @"subject":self.model.defDevSgSn?[self formatDefDevSgSn]:@"",
                              @"reason":self.dataArray[4][@"placeholder"],
                              @"description":cell.textfield.text.length>0?cell.textfield.text:@"",
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
        [NSUserDefaults.standardUserDefaults setValue:self.dataArray[4][@"placeholder"] forKey:[self reasonCacheKey]];
        [NSUserDefaults.standardUserDefaults setValue:params[@"description"] forKey:[self descCacheKey]];
        NSString * string = [self getCurrentTimeString];
        NSLog(@"strint=%@",string);
        [NSUserDefaults.standardUserDefaults setValue:string forKey:self.model.email];
        [self loadTimer];
        [GlobelDescAlertView showAlertViewWithTitle:@"Ticket received".localized desc:@"The manufacturer will contact you via Email or phone call within the next hour regarding the case, please pay attention.".localized btnTitle:nil completion:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

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

- (void)textViewDidChange:(UITextView *)textView{
    CGRect bounds = textView.bounds;
    CGSize maxSize = CGSizeMake(bounds.size.width, CGFLOAT_MAX);
    CGSize newSize = [textView sizeThatFits:maxSize];
    bounds.size = newSize;
    textView.bounds = bounds;
    self.descHeight = textView.bounds.size.height;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.dataArray.count-2) {
        SelecteTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SelecteTableViewCell class]) forIndexPath:indexPath];
        cell.titleLabel.text = self.dataArray[indexPath.row][@"title"];
        cell.content.text = self.dataArray[indexPath.row][@"placeholder"];
        return cell;
    }else if (indexPath.row == self.dataArray.count-1) {
        ServiceInputTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ServiceInputTableViewCell class]) forIndexPath:indexPath];
        cell.titleLabel.text = self.dataArray[indexPath.row][@"title"];
        cell.content.text = self.dataArray[indexPath.row][@"placeholder"];
        cell.content.delegate = self;
        return cell;
    }else{
        InputTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([InputTableViewCell class]) forIndexPath:indexPath];
        cell.titleLabel.text = self.dataArray[indexPath.row][@"title"];
        cell.textfield.text = self.dataArray[indexPath.row][@"placeholder"];
        if (indexPath.row <= 3) {
            cell.textfield.userInteractionEnabled = false;
        }else{
            if (indexPath.row == 5) {
                if ([NSUserDefaults.standardUserDefaults objectForKey:[self reasonCacheKey]] || RMHelper.getUserType) {
                    cell.textfield.userInteractionEnabled = false;
                }else{
                    cell.textfield.userInteractionEnabled = true;
                }
                cell.textfield.delegate = self;
            }else{
                cell.textfield.userInteractionEnabled = true;
            }
        }
        return cell;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.textAlignment == NSTextAlignmentRight) {
        NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
        textField.text = [text stringByReplacingOccurrencesOfString:@" " withString:@"\u00a0"];

        UITextPosition *startPos = [textField positionFromPosition:textField.beginningOfDocument offset:range.location + string.length];
        UITextRange *textRange = [textField textRangeFromPosition:startPos toPosition:startPos];
        textField.selectedTextRange = textRange;
        return NO;
    }
    return YES;
}

//- (BOOL)textField:(UITextField *)textField
//        shouldChangeCharactersInRange:(NSRange)range
//        replacementString:(NSString *)string
//{
//    /* 如果不是右对齐，直接返回YES，不做处理 */
//    if (textField.textAlignment != NSTextAlignmentRight) {
//        return YES;
//    }
//
//    /* 在右对齐的情况下*/
//    // 如果string是@""，说明是删除字符（剪切删除操作），则直接返回YES，不做处理
//    // 如果把这段删除，在删除字符时光标位置会出现错误
//    if ([string isEqualToString:@""]) {
//        return YES;
//    }
//
//    /* 在输入单个字符或者粘贴内容时做如下处理，已确定光标应该停留的正确位置，
//    没有下段从字符中间插入或者粘贴光标位置会出错 */
//    // 首先使用 non-breaking space 代替默认输入的@“ ”空格
//    string = [string stringByReplacingOccurrencesOfString:@" "
//                     withString:@"\u00a0"];
//    textField.text = [textField.text stringByReplacingCharactersInRange:range
//                                     withString:string];
//    //确定输入或者粘贴字符后光标位置
//    UITextPosition *beginning = textField.beginningOfDocument;
//    UITextPosition *cursorLoc = [textField positionFromPosition:beginning
//                                 offset:range.location+string.length];
//    // 选中文本起使位置和结束为止设置同一位置
//    UITextRange *textRange = [textField textRangeFromPosition:cursorLoc
//                                        toPosition:cursorLoc];
//    // 选中字符范围（由于textRange范围的起始结束位置一样所以并没有选中字符）
//    [textField setSelectedTextRange:textRange];
//
//    return NO;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
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
    return indexPath.row == self.dataArray.count-1 ? (self.descHeight+20 < 53 ? 53 : self.descHeight+20) : 53;
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
