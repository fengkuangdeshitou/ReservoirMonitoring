//
//  ProtocolViewController.m
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/7/6.
//

#import "ProtocolViewController.h"
@import WebKit;

@interface ProtocolViewController ()

@property(nonatomic,strong) NSString * url;
@property(nonatomic,strong) WKWebView * webview;

@end

@implementation ProtocolViewController

- (instancetype)initWithUrl:(NSString *)url
{
    self = [super init];
    if (self) {
        self.url = url;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.webview = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-NavagationHeight)];
    [self.view addSubview:self.webview];
    NSURL * url = [NSURL URLWithString:self.url];
    NSURLRequest * request = [[NSURLRequest alloc] initWithURL:url];
    [self.webview loadRequest:request];
    
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
