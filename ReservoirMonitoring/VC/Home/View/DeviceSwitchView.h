//
//  DeviceSwitchView.h
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/16.
//

#import <UIKit/UIKit.h>
#import "DevideModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DeviceSwitchViewDelegate <NSObject>

- (void)onSwitchDeviceSuccess;

@end

@interface DeviceSwitchView : UIView

+ (void)showDeviceSwitchViewWithDelegate:(id<DeviceSwitchViewDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
