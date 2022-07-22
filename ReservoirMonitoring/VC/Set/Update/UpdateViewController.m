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
@property(nonatomic,strong) NSDictionary * result;

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
    if (RMHelper.getUserType && RMHelper.getLoadDataForBluetooth) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            [BleManager.shareInstance readWithCMDString:@"503" count:5 finish:^(NSArray * _Nonnull array) {
                dispatch_semaphore_signal(semaphore);
                NSString * version = [array componentsJoinedByString:@""];
                self.version.text = [@"Firmware version:".localized stringByAppendingString:version];
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            [BleManager.shareInstance readWithCMDString:@"628" count:1 finish:^(NSArray * _Nonnull array) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.update.selected = [array.firstObject boolValue];
                    if (self.update.selected) {
                        [self updateAction];
                    }
                });
            }];
        });
        
    }else{
        [self getDeviceListCompletion:^{
            [self getDeviceInfoWithDevId:self.devId];
        }];
    }
}

- (void)getDeviceListCompletion:(void(^)(void))completion{
    [Request.shareInstance getUrl:DeviceList params:@{} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        NSArray * modelArray = [DevideModel mj_objectArrayWithKeyValuesArray:result[@"data"]];
        NSArray<DevideModel*> * array = [modelArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"lastConnect = %@",@"1"]];
        if (array.count > 0) {
            DevideModel * model = array.firstObject;
            self.devId = model.deviceId;
        }
        completion();
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
    if (RMHelper.getUserType && RMHelper.getLoadDataForBluetooth) {
        NSString * value = self.update.selected ? @"1" : @"0";
        [BleManager.shareInstance writeWithCMDString:@"628" string:value finish:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                sender.selected = !sender.selected;
            });
        }];
    }else{
        if (!self.devId) {
            [self getDeviceListCompletion:^{
                [self commitAotuUpdateVersiom];
            }];
        }else{
            [self commitAotuUpdateVersiom];
        }
    }
}

- (void)commitAotuUpdateVersiom{
    [Request.shareInstance postUrl:CommitAotuUpdateVersion params:@{@"aotuUpdateFirmware":self.update.selected?@"1":@"0",@"devId":self.devId} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        BOOL value = [result[@"data"] boolValue];
        if (value) {
            self.update.selected = !self.update.selected;
        }else{
            [RMHelper showToast:result[@"message"] toView:self.view];
        }
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
}
    
- (IBAction)updateAction{
    if (!self.devId) {
        [self getDeviceListCompletion:^{
            [self checkFirmarkVersion];
        }];
    }else{
        [self checkFirmarkVersion];
    }
}

- (void)checkFirmarkVersion{
    [Request.shareInstance getUrl:CheckFirmarkVersion params:@{@"devId":self.devId} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        int hasNewVersion = [result[@"data"][@"hasNewVersion"] intValue];
        self.result = result[@"data"];
        [GlobelDescAlertView showAlertViewWithTitle:@"Check for updates" desc:result[@"data"][@"tips"] btnTitle:hasNewVersion==1?nil:@"Update" completion:^{
            if (hasNewVersion!=1) {
                [self updateDevice];
            }
        }];
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
}

- (void)updateDevice{
    [Request.shareInstance getUrl:Upgrade
                           params:@{
                                    @"devId":self.devId,
                                    @"currentVerNum":self.result[@"currentVerNum"],
                                    @"upgradeTaskId":self.result[@"upgradeTaskId"],
                                    @"newVerNum":self.result[@"newVerNum"]}
                         progress:^(float progress) {
            
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
