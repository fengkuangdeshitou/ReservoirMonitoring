//
//  SelectItemAlertView.h
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/5/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SelectItemAlertView : UIView

+ (void)showSelectItemAlertViewWithDataArray:(NSArray<NSString *> *)dataArray
                              tableviewFrame:(CGRect)tableviewFrame
                                  completion:(void (^)(NSString * value))completion;

@end

NS_ASSUME_NONNULL_END
