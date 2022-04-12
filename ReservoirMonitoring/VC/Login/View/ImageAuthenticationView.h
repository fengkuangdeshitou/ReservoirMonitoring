//
//  ImageAuthenticationView.h
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ImageAuthenticationViewDelegate <NSObject>

- (void)onAuthemticationSuccess;

@end

@interface ImageAuthenticationView : UIView

+ (void)showImageAuthemticationWithDelegate:(id<ImageAuthenticationViewDelegate>)delegage;

@end

NS_ASSUME_NONNULL_END
