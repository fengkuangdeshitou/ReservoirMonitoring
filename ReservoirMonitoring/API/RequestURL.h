//
//  RequestURL.h
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/5/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RequestURL : NSObject

extern NSString * const Host;

extern NSString * const EmailCode;

extern NSString * const CommonRegister;

extern NSString * const Login;

extern NSString * const ResetPwd;

extern NSString * const UserInfo;

extern NSString * const EditUserInfo;

extern NSString * const UploadImg;

extern NSString * const HelpList;

extern NSString * const HelpDetail;

extern NSString * const ScanSgsn;

extern NSString * const DeviceBindAddressInfo;

extern NSString * const TimeZoneList;

extern NSString * const BindDevice;

extern NSString * const DeviceList;

extern NSString * const HomeDeviceInfo;

extern NSString * const CurrentDeviceInfo;

extern NSString * const DeviceInfoToId;

extern NSString * const SwitchMode;

extern NSString * const GetSwitchMode;

extern NSString * const SwitchDevice;

extern NSString * const QueryDataElectricity;

extern NSString * const QueryDataGraph;

extern NSString * const Agreement;

extern NSString * const Privacy;

extern NSString * const QueryFirmwareInfo;

extern NSString * const CommitAotuUpdateVersion;

extern NSString * const CheckFirmarkVersion;

extern NSString * const Upgrade;

extern NSString * const SaveDebugConfig;

extern NSString * const Weather;

extern NSString * const AlertFaultList;

extern NSString * const DeviceInfoWeather;


@end

NS_ASSUME_NONNULL_END
