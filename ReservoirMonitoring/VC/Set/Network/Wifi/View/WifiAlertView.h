//
//  WifiAlertView.h
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/5/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WifiAlertView : UIView

+ (void)showWifiAlertViewWithTitle:(NSString *)title
                      showWifiName:(BOOL)showWifiName
                        completion:(void(^)(NSString * wifiName,NSString * password))completion;

@end

NS_ASSUME_NONNULL_END
