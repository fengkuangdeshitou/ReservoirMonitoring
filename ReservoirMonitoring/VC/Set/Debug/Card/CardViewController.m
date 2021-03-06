//
//  CardViewController.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/6/26.
//

#import "CardViewController.h"
@import AFNetworking;
#import "BleManager.h"

@interface CardViewController ()

@property(nonatomic,weak)IBOutlet UIButton * queryBtn;
@property(nonatomic,weak)IBOutlet UIButton * statusBtn;
@property(nonatomic,weak)IBOutlet UIButton * activaBtn;
@property(nonatomic,weak)IBOutlet UILabel * sn;
@property(nonatomic,weak)IBOutlet UILabel * iccid;
@property(nonatomic,weak)IBOutlet UILabel * state;

@property(nonatomic,strong)AFHTTPSessionManager * manager;
@property(nonatomic,strong)NSMutableDictionary * header;
@property(nonatomic,strong)NSDictionary * cardDictionary;

@end

@implementation CardViewController

- (AFHTTPSessionManager *)manager{
    if (!_manager) {
        _manager = [AFHTTPSessionManager manager];
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return _manager;
}

- (NSMutableDictionary *)header{
    if (!_header) {
        _header = [[NSMutableDictionary alloc] init];
    }
    NSString * account = @"wenchu@vidagrid.com";
    NSString * password = @"WenChu1234";
    [_header setValue:account forKey:@"account"];
    [_header setValue:password forKey:@"password"];
    [_header setValue:[self getAuthorization:[NSString stringWithFormat:@"%@:%@",account,password]] forKey:@"authorization"];
    return _header;
}

- (NSString *)getAuthorization:(NSString *)string{
    NSData * data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [NSString stringWithFormat:@"Basic %@",[data base64EncodedStringWithOptions:0]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.queryBtn setTitle:@"Query sn and iccid" forState:UIControlStateNormal];
    [self.statusBtn setTitle:@"Query device for network state" forState:UIControlStateNormal];
    [self.activaBtn setTitle:@"Activation" forState:UIControlStateNormal];
    [self.queryBtn showBorderWithRadius:25];
    [self.statusBtn showBorderWithRadius:25];
    [self.activaBtn showBorderWithRadius:25];
}

- (IBAction)queryAction:(id)sender{
//    self.cardDictionary = @{@"ICCID":@"89882390000353142105",@"SN":@"VC51030622208003"};
    if (!BleManager.shareInstance.isConnented) {
        [RMHelper showToast:@"Please connect device" toView:self.view];
        return;
    }
    [self.view showHUDToast:@"Loading"];
    [BleManager.shareInstance readWithDictionary:@{@"type":@"SN-ICCID"} finish:^(NSDictionary * _Nonnull dict) {
        if (dict[@"SN"]) {
            self.cardDictionary = dict;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self loadIcciData];
                [self.view hiddenHUD];
            });
        }
    }];
}

- (void)loadIcciData{
    self.sn.text = self.cardDictionary[@"SN"];
    self.iccid.text = self.cardDictionary[@"ICCID"];
}

- (IBAction)queryStatus:(id)sender{
    if (!self.cardDictionary) {
        [RMHelper showToast:@"Please connect device" toView:self.view];
        return;
    }
    [self.view showHUDToast:@"Loading"];
    [self.manager POST:@"https://fudascms.vidagrid.com/querystatus" parameters:@{@"devices":@[self.cardDictionary[@"SN"]]} headers:self.header progress:^(NSProgress * _Nonnull uploadProgress) {
            
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * json = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        [self.view hiddenHUD];
        if ([json[@"code"] intValue] == 0) {
            self.state.text = [NSString stringWithFormat:@"Device status:%@",json[@"details"][0][@"msg"]];
        }else{
            [RMHelper showToast:json[@"msg"] toView:self.view];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.view hiddenHUD];
        [RMHelper showToast:error.description toView:self.view];
    }];
}

- (IBAction)activationAction:(id)sender{
    if (!self.cardDictionary) {
        [RMHelper showToast:@"Please connect device" toView:self.view];
        return;
    }
    // @[@{@"iccid":@"89882390000353142105",@"sn":@"VC51030622208003"}]
    [self.view showHUDToast:@"Loading"];
    [self.manager POST:@"https://fudascms.vidagrid.com/active" parameters:@[@{@"sn":self.cardDictionary[@"SN"],@"iccid":self.cardDictionary[@"ICCID"]}] headers:self.header progress:^(NSProgress * _Nonnull uploadProgress) {
            
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self.view hiddenHUD];
        NSDictionary * json = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([json[@"code"] intValue] == 0) {
            [RMHelper showToast:json[@"details"][0][@"msg"] toView:self.view];
        }else{
            [RMHelper showToast:json[@"msg"] toView:self.view];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error=%@,%@",error,task.currentRequest.allHTTPHeaderFields);
        [self.view hiddenHUD];
        [RMHelper showToast:error.description toView:self.view];
    }];
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
