//
//  GlobelDescAlertView.h
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/5/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GlobelDescAlertView : UIView

+ (void)showAlertViewWithTitle:(NSString *)title
                          desc:(NSString *)desc
                      btnTitle:(nullable NSString *)btnTitle
                    completion:(nullable void(^)(void))completion;

@end

NS_ASSUME_NONNULL_END
