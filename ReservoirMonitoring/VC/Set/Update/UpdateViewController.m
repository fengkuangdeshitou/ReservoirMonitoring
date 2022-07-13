//
//  UpdateViewController.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/18.
//

#import "UpdateViewController.h"

@interface UpdateViewController ()

@property(nonatomic,weak)IBOutlet UIButton * update;
@property(nonatomic,weak)IBOutlet UILabel * content;
@property(nonatomic,weak)IBOutlet UILabel * version;
@property(nonatomic,weak)IBOutlet UILabel * ota;

@end

@implementation UpdateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.ota.text = @"Remote firmware update".localized;
    NSMutableAttributedString * att = [[NSMutableAttributedString alloc] initWithString:@"Opt in/out automatic software update (On: Server is allowed to communicate with device and update firmware automatically; Off: Server is NOT allowed to communicate with the device or update firmware.  )\n".localized];
    NSMutableParagraphStyle * style = [[NSMutableParagraphStyle alloc] init];
    style.firstLineHeadIndent = 20;
    [att addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, att.length)];
    self.content.attributedText = att;
    
    [self.update showBorderWithRadius:25];
    [self.update setTitle:@"Check for updates".localized forState:UIControlStateNormal];
    NSString * version = [NSBundle.mainBundle infoDictionary][@"CFBundleShortVersionString"];
    self.version.text = [@"Firmware version:".localized stringByAppendingString:version];
    
}

- (void)getDeviceInfo{
    [Request.shareInstance getUrl:QueryFirmwareInfo params:@{@"devId":@""} progress:^(float progress) {
            
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
