//
//  UpdateViewController.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/18.
//

#import "UpdateViewController.h"
#import "DevideModel.h"
#import "GlobelDescAlertView.h"

@interface UpdateViewController ()

@property(nonatomic,weak)IBOutlet UIButton * update;
@property(nonatomic,weak)IBOutlet UILabel * content;
@property(nonatomic,weak)IBOutlet UILabel * version;
@property(nonatomic,weak)IBOutlet UILabel * ota;
@property(nonatomic,copy) NSString * devId;

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
    [self getDeviceList];
}

- (void)getDeviceList{
    [Request.shareInstance getUrl:DeviceList params:@{} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        NSArray * modelArray = [DevideModel mj_objectArrayWithKeyValuesArray:result[@"data"]];
        NSArray<DevideModel*> * array = [modelArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"lastConnect = %@",@"1"]];
        if (array.count > 0) {
            DevideModel * model = array.firstObject;
            self.devId = model.deviceId;
            [self getDeviceInfoWithDevId:self.devId];
        }
    } failure:^(NSString * _Nonnull errorMsg) {

    }];
}

- (void)getDeviceInfoWithDevId:(NSString *)devId{
    [Request.shareInstance getUrl:QueryFirmwareInfo params:@{@"devId":devId} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        self.update.selected = [result[@"data"][@"aotuUpdateFirmware"] boolValue];
        if (self.update.selected) {
            [self updateAction];
        }
        NSString * version = [NSString stringWithFormat:@"%@",result[@"data"][@"firmwareVersion"]];
        self.version.text = [@"Firmware version:".localized stringByAppendingString:version];
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
}

- (IBAction)autoUpdateAction:(UIButton *)sender{
    [Request.shareInstance postUrl:CommitAotuUpdateVersion params:@{@"aotuUpdateFirmware":sender.selected?@"1":@"0",@"devId":self.devId} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        BOOL value = [result[@"data"] boolValue];
        if (value) {
            sender.selected = !sender.selected;
        }else{
            [RMHelper showToast:result[@"message"] toView:self.view];
        }
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
}

- (IBAction)updateAction{
    [Request.shareInstance getUrl:CheckFirmarkVersion params:@{@"devId":self.devId} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        int hasNewVersion = [result[@"data"][@"hasNewVersion"] intValue];
        [GlobelDescAlertView showAlertViewWithTitle:@"Check for updates" desc:result[@"data"][@"tips"] btnTitle:hasNewVersion==1?nil:@"Update" completion:^{
            if (hasNewVersion!=1) {
                [self updateDevice];
            }
        }];
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
}

- (void)updateDevice{
    [Request.shareInstance getUrl:Upgrade params:@{@"devId":self.devId} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        [RMHelper showToast:result[@"data"][@"tips"] toView:self.view];
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
