//
//  BaseViewController+BarButtonItem.h
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/11.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewController (BarButtonItem)

- (void)setLeftBatButtonItemWithImage:(UIImage *)imageName
                                  sel:(nullable SEL)sel;

- (void)setRightBarButtonItemWithTitlt:(NSString *)title
                                  sel:(nullable SEL)sel;

- (void)setRightBarButtonItemWithImage:(UIImage *)image
                                   sel:(nullable SEL)sel;

@end

NS_ASSUME_NONNULL_END
