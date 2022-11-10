//
//  MessageDetailViewController.m
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/11/10.
//

#import "MessageDetailViewController.h"

@interface MessageDetailViewController ()

@property(nonatomic,strong)NSString * messageId;

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
    
    [self getMessageDetail];
    
}

- (void)getMessageDetail{
    [Request.shareInstance getUrl:[NSString stringWithFormat:@"%@/%@",MessageDetail,self.messageId] params:@{} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        
    } failure:^(NSString * _Nonnull errorMsg) {
        
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
