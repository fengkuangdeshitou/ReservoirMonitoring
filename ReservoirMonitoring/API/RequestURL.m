//
//  RequestURL.m
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/5/24.
//

#import "RequestURL.h"

@implementation RequestURL

#ifdef DEBUG
NSString * const Host = @"https://epcube-monitoring.com/app-api";
#else
NSString * const Host = @"https://epcube-monitoring.com/app-api";
#endif

NSString * const EmailCode = @"/open/common/getEmailCode";

NSString * const CommonRegister = @"/open/common/register";

NSString * const Login = @"/open/common/login";

NSString * const ResetPwd = @"/open/common/resetPwd";

NSString * const UserInfo = @"/user/user/base";

NSString * const EditUserInfo = @"/user/user/editUserInfo";

NSString * const UploadImg = @"/open/common/uploadImg/123";

NSString * const HelpList = @"/help/helpList";

NSString * const HelpDetail = @"/help/helpDetail";

NSString * const ScanSgsn = @"/device/scanSgsn";

NSString * const DeviceBindAddressInfo = @"/device/deviceBindAddressInfo";

NSString * const TimeZoneList = @"/common/locationCountryZone/getTimeZoneList";

NSString * const BindDevice = @"/device/bindDevice";

NSString * const DeviceList = @"/device/deviceList";

NSString * const HomeDeviceInfo = @"/device/homeDeviceInfo";

NSString * const CurrentDeviceInfo = @"/device/currentDeviceInfo";

NSString * const DeviceInfoToId = @"/device/getDeviceInfoToId";

NSString * const SwitchMode = @"/device/switchMode";

NSString * const GetSwitchMode = @"/device/getSwitchMode";

NSString * const SwitchDevice = @"/device/switchDevice";

NSString * const QueryDataElectricity = @"/device/queryDataElectricityV2";

NSString * const QueryDataGraph = @"/device/queryDataGraphV2";

NSString * const Agreement = @"https://epcube-monitoring.com/uploadPath/Terms%20of%20Use%20&%20Service%20290622.pdf";

NSString * const Privacy = @"https://epcube-monitoring.com/uploadPath/EP%20Privacy%20Statement%20290622.pdf";

NSString * const QueryFirmwareInfo = @"/user/user/queryFirmwareInfo";

NSString * const CommitAotuUpdateVersion = @"/user/user/commitAotuUpdateVersion";

NSString * const CheckFirmarkVersion = @"/device/checkFirmarkVersion";

NSString * const Upgrade = @"/device/upgrade";

NSString * const SaveDebugConfig = @"/device/saveDebugConfig";

NSString * const Weather = @"/weatherApi/weather/getWeather";

NSString * const AlertFaultList = @"/device/getAlertFaultList";

NSString * const DeviceInfoWeather = @"/device/homeDeviceInfoWeather";

NSString * const ClearTouMode = @"/device/clearTouMode";

NSString * const ProtocolLink = @"/open/common/protocolLink";

NSString * const NetWorkInfo = @"/device/netWorkInfo";

NSString * const CheckEmailCode = @"/open/common/checkEmailCode";

NSString * const CheckSn = @"/device/checkSn";

NSString * const LogOff = @"/user/user/logOff";

NSString * const VisitorsLogin = @"/open/common/visitorsLogin";

NSString * const CountryCode = @"/common/countryCode/list";

NSString * const SubmitInstall = @"/installLog/submit";

NSString * const BatchUpload = @"/open/common/batchUploadImg";

NSString * const MessageTypeInfo = @"/message/messageTypeInfo";

NSString * const QueryInstallLogInfo = @"/installLog/queryInstallLogInfo";

NSString * const MessageList = @"/message/messageList";

NSString * const ReadAll = @"/message/readAll";

NSString * const Read = @"/message/read";

NSString * const MessageDetail = @"/message/message";

@end

