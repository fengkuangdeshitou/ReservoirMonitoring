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
                        completion:(void(^)(NSString * value))completion;

@end

NS_ASSUME_NONNULL_END
