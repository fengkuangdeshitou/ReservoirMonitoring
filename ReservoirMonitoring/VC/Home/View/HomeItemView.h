//
//  HomeItemView.h
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomeItemView : UIView

@property(nonatomic,strong)UILabel * titleLabel;
@property(nonatomic,strong)UILabel * descLabel;
@property(nonatomic,strong)UIButton * statusButton;
@property(nonatomic,assign)BOOL isFlip;

@end

NS_ASSUME_NONNULL_END
