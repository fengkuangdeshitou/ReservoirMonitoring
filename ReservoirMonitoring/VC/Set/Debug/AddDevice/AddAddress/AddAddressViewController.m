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

@interface AddAddressViewController ()<CLLocationManagerDelegate>

@property(nonatomic,weak)IBOutlet UILabel * address;
@property(nonatomic,weak)IBOutlet UITextField * countries;
@property(nonatomic,weak)IBOutlet UITextField * province;
@property(nonatomic,weak)IBOutlet UITextField * code;
@property(nonatomic,weak)IBOutlet UIButton * time;
@property(nonatomic,weak)IBOutlet UILabel * link;
@property(nonatomic,weak)IBOutlet UITextField * email;
@property(nonatomic,weak)IBOutlet UIButton * confirm;
@property(nonatomic,weak)IBOutlet UILabel * timeZone;
@property(nonatomic,strong) CLLocationManager * manager;

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
            NSLog(@"%@",place.country);
            self.countries.text = place.country;
            self.province.text = place.locality;
            [self getAddressInfo];
        }
    }];
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
    self.email.placeholder = @"Enter Email".localized;
    [self.confirm setTitle:@"Confirm".localized forState:UIControlStateNormal];
    [self.confirm showBorderWithRadius:25];
    
    self.countries.placeholderColor = [UIColor colorWithHexString:COLOR_PLACEHOLDER_COLOR];
    self.province.placeholderColor = [UIColor colorWithHexString:COLOR_PLACEHOLDER_COLOR];
    self.code.placeholderColor = [UIColor colorWithHexString:COLOR_PLACEHOLDER_COLOR];
    self.email.placeholderColor = [UIColor colorWithHexString:COLOR_PLACEHOLDER_COLOR];
    
    [self.manager startUpdatingLocation];
    [self getAddressInfo];
}

- (void)getAddressInfo{
    [Request.shareInstance postUrl:DeviceBindAddressInfo params:@{@"devId":self.devId,@"countryNameEn":self.countries?:@"",@"countryCode":[self.addressIds componentsSeparatedByString:@","].firstObject} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
}

- (IBAction)timeAction:(id)sender{
    TimeZoneViewController * time = [[TimeZoneViewController alloc] init];
    time.selectTimeZone = ^(NSDictionary * _Nonnull item) {
        self.timeZone.text = item[@"zoneId"][1];
    };
    time.countryId = [self.addressIds componentsSeparatedByString:@","].firstObject;
    [self.navigationController pushViewController:time animated:true];
}

- (IBAction)submitAction:(id)sender{
    if (self.timeZone.text.length == 0) {
        [RMHelper showToast:@"Please select time zone" toView:self.view];
        return;
    }
    [Request.shareInstance postUrl:BindDevice params:@{@"sgSn":self.sgSn,@"snItems":self.snItems,@"name":self.name,@"addressIds":self.addressIds,@"timeZone":self.timeZone.text,@"userEmail":self.email.text?:@"",@"mailCode":self.code.text?:@""} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        [RMHelper showToast:@"Add Device Success" toView:self.view];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popToRootViewControllerAnimated:true];
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
