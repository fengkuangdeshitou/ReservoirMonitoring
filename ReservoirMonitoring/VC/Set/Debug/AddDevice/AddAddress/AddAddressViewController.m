//
//  AddAddressViewController.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/5/6.
//

#import "AddAddressViewController.h"
#import "TimeZoneViewController.h"
@import CoreLocation;
@import MapKit;

@interface AddAddressViewController ()<CLLocationManagerDelegate,UITextFieldDelegate>

@property(nonatomic,weak)IBOutlet UILabel * address;
@property(nonatomic,weak)IBOutlet UITextField * countries;
@property(nonatomic,weak)IBOutlet UITextField * province;
@property(nonatomic,weak)IBOutlet UITextField * code;
@property(nonatomic,weak)IBOutlet UIButton * time;
@property(nonatomic,weak)IBOutlet UILabel * link;
@property(nonatomic,weak)IBOutlet UITextField * email;
@property(nonatomic,weak)IBOutlet UIButton * confirm;
@property(nonatomic,weak)IBOutlet UILabel * timeZone;
@property(nonatomic,weak)IBOutlet UIView * emailView;
@property(nonatomic,strong) CLLocationManager * manager;
@property(nonatomic,strong) NSArray * dataArray;
@property(nonatomic,strong) NSString * countrieID;
@property(nonatomic,strong) NSString * provinceID;
@property(nonatomic,strong) NSString * zoneId;

@end

@implementation AddAddressViewController

- (CLLocationManager *)manager{
    if (!_manager) {
        _manager = [[CLLocationManager alloc] init];
    }
    [_manager requestWhenInUseAuthorization];
    _manager.delegate = self;
    return _manager;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    CLLocation * location = locations[0];
    [self.manager stopUpdatingLocation];
    CLGeocoder * coder = [[CLGeocoder alloc] init];
    [coder  reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        for (CLPlacemark * place in placemarks) {
            NSLog(@"%@",place.postalCode);
            for (NSDictionary * item in self.dataArray) {
                NSString * label = item[@"label"];
                if ([label isEqualToString:place.country]) {
                    self.countries.text = item[@"label"];
                    self.countrieID = item[@"value"];
                    NSArray * children = item[@"children"];
                    for (NSDictionary * dic in children) {
                        NSString * subValue = dic[@"label"];
                        if ([subValue isEqualToString:place.administrativeArea]) {
                            self.province.text = dic[@"label"];
                            self.provinceID = item[@"value"];
                        }
                    }
                }
            }
        }
    }];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    TimeZoneViewController * time = [[TimeZoneViewController alloc] init];
    time.listArray = self.dataArray;
    if (textField == self.province) {
        if (!self.countrieID) {
            time.countryId = self.addressIds;
        }else{
            time.countryId = [NSString stringWithFormat:@"%@,%@",self.countrieID,self.provinceID];        }
    }
    time.selectTimeZone = ^(NSDictionary * _Nonnull item) {
        if (textField == self.province) {
            self.province.text = item[@"label"];
            self.provinceID = item[@"value"];
        }else{
            self.countries.text = item[@"label"];
            self.countrieID = item[@"value"];
            self.province.text = @"";
            self.provinceID = @"";
        }
    };
    [self.navigationController pushViewController:time animated:true];
    return false;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.address.text = @"Device location".localized;
    self.countries.placeholder = @"Country".localized;
    self.province.placeholder = @"State".localized;
    self.code.placeholder = @"Zip code".localized;
    [self.time setTitle:@"Time zone".localized forState:UIControlStateNormal];
    self.link.text = @"Link Email".localized;
    self.email.placeholder = @"Please input customer's email".localized;
    [self.confirm setTitle:@"Confirm".localized forState:UIControlStateNormal];
    [self.confirm showBorderWithRadius:25];
    if (self.userEmail){
        self.email.text = self.userEmail;
    }
    self.countries.placeholderColor = [UIColor colorWithHexString:COLOR_PLACEHOLDER_COLOR];
    self.province.placeholderColor = [UIColor colorWithHexString:COLOR_PLACEHOLDER_COLOR];
    self.code.placeholderColor = [UIColor colorWithHexString:COLOR_PLACEHOLDER_COLOR];
    self.email.placeholderColor = [UIColor colorWithHexString:COLOR_PLACEHOLDER_COLOR];
    
    [self getAddressInfo];
    self.emailView.hidden = !RMHelper.getUserType;
}

- (void)getAddressInfo{
    if (self.addressIds.length > 0) {
        [Request.shareInstance postUrl:DeviceBindAddressInfo params:@{@"devId":self.devId,@"countryNameEn":self.countries.text?:@"",@"countryCode":[self.addressIds componentsSeparatedByString:@","].firstObject,} progress:^(float progress) {
                
        } success:^(NSDictionary * _Nonnull result) {
            self.dataArray = result[@"data"][@"list"];
            for (NSDictionary * item in self.dataArray) {
                int value = [item[@"value"] intValue];
                if (value == [[self.addressIds componentsSeparatedByString:@","].firstObject intValue]) {
                    self.countries.text = item[@"label"];
                    self.countrieID = item[@"value"];
                    NSArray * children = item[@"children"];
                    for (NSDictionary * dic in children) {
                        int subValue = [dic[@"value"] intValue];
                        if (subValue == [[self.addressIds componentsSeparatedByString:@","].lastObject intValue]) {
                            self.province.text = dic[@"label"];
                            self.provinceID = item[@"value"];
                        }
                    }
                }
            }
        } failure:^(NSString * _Nonnull errorMsg) {
            
        }];
    }else{
        [Request.shareInstance postUrl:DeviceBindAddressInfo params:@{@"devId":self.devId,@"countryNameEn":@"",@"countryCode":@""} progress:^(float progress) {
                
        } success:^(NSDictionary * _Nonnull result) {
            self.dataArray = result[@"data"][@"list"];
            [self.manager startUpdatingLocation];
        } failure:^(NSString * _Nonnull errorMsg) {
            
        }];
    }
}

- (IBAction)timeAction:(id)sender{
    if (self.addressIds.length == 0 && !self.countrieID) {
        if (self.countries.text.length == 0) {
            [RMHelper showToast:@"please select state" toView:self.view];
            return;
        }
        if (self.province.text.length == 0) {
            [RMHelper showToast:@"please select country" toView:self.view];
            return;
        }
    }
    TimeZoneViewController * time = [[TimeZoneViewController alloc] init];
    time.selectTimeZone = ^(NSDictionary * _Nonnull item) {
        self.timeZone.text = item[@"name"];
        self.zoneId = [item[@"zoneId"] lastObject];
    };
    if (self.countrieID) {
        time.countryId = self.countrieID;
    }else{
        time.countryId = [self.addressIds componentsSeparatedByString:@","].firstObject;
    }
    [self.navigationController pushViewController:time animated:true];
}

- (IBAction)submitAction:(id)sender{
    if (self.countrieID.length == 0) {
        [RMHelper showToast:@"Please select country" toView:self.view];
        return;
    }
    if (self.provinceID.length == 0) {
        [RMHelper showToast:@"Please select state" toView:self.view];
        return;
    }
    if (self.code.text.length == 0) {
        [RMHelper showToast:@"Please input zip code" toView:self.view];
        return;
    }
    if (self.timeZone.text.length == 0) {
        [RMHelper showToast:@"Please select Timezone" toView:self.view];
        return;
    }
    if ([RMHelper getUserType] && self.email.text.length == 0) {
        [RMHelper showToast:@"Please input User Email" toView:self.view];
        return;
    }
    
    [Request.shareInstance postUrl:BindDevice params:@{@"sgSn":self.sgSn,@"snItems":self.snItems,@"name":self.name,@"addressIds":[NSString stringWithFormat:@"%@,%@",self.countrieID,self.provinceID],@"timeZone":self.zoneId,@"userEmail":self.email.text?:@"",@"mailCode":self.code.text?:@""} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        [RMHelper showToast:@"Success" toView:self.view];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:ADD_DEVICE_NOTIFICATION object:nil];
        });
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
