//
//  LineAnimatiionView.h
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/7/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    AnimationSourceGrid,
    AnimationSourceSolar,
    AnimationSourceGenerator,
    AnimationSourceEV,
    AnimationSourceNonbackup,
    AnimationSourceBackupLoads
} AnimationSource;

typedef enum : NSUInteger {
    AnimationStartDirectionLeftTop,
    AnimationStartDirectionTop,
    AnimationStartDirectionRightTop,
    AnimationStartDirectionLeftBottom,
    AnimationStartDirectionBottom,
    AnimationStartDirectionRightBottom
} AnimationStartDirection;

@interface LineAnimatiionView : UIView

@property(nonatomic,assign) CFTimeInterval duration;
@property(nonatomic,assign) AnimationStartDirection direction;
@property(nonatomic,assign) AnimationSource source;
@property(nonatomic,assign) BOOL showAnimation;

@end

NS_ASSUME_NONNULL_END
