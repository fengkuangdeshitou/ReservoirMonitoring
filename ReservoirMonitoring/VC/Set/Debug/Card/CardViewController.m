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
@property(nonatomic,weak)IBOutlet UIButton * activaBtn;

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
    [self.queryBtn setTitle:@"Query" forState:UIControlStateNormal];
    [self.activaBtn setTitle:@"Activation" forState:UIControlStateNormal];
    [self.queryBtn showBorderWithRadius:25];
    [self.activaBtn showBorderWithRadius:25];
}

- (IBAction)queryAction:(id)sender{
    [BleManager.shareInstance readWithDictionary:@{@"type":@"SN-ICCID"} finish:^(NSDictionary * _Nonnull dict) {
        self.cardDictionary = dict;
        NSLog(@"===%@",self.cardDictionary);
        [self quereWithDevices:self.cardDictionary[@"SN"]];
    }];
}

- (void)quereWithDevices:(NSString *)device{
    [self.manager POST:@"https://fudascms.vidagrid.com/querystatus" parameters:@{@"devices":@[device]} headers:self.header progress:^(NSProgress * _Nonnull uploadProgress) {
            
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * json = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"json=%@",json);
        NSData * data = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingSortedKeys error:nil];
        NSString * string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [RMHelper showToast:string toView:self.view];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (IBAction)activationAction:(id)sender{
    [self.manager POST:@"https://fudascms.vidagrid.com/active" parameters:@{@"devices":@[@{@"sn":self.cardDictionary[@"SN"],@"iccid":self.cardDictionary[@"ICCID"]}]} headers:self.header progress:^(NSProgress * _Nonnull uploadProgress) {
            
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * json = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"res=%@",json);
        NSData * data = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingSortedKeys error:nil];
        NSString * string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [RMHelper showToast:string toView:self.view];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error=%@,%@",error,task.currentRequest.allHTTPHeaderFields);
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
