//
//  DebugCollectionViewCell.h
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DebugCollectionViewCell : UICollectionViewCell

@property(nonatomic,weak)IBOutlet UIImageView * icon;
@property(nonatomic,weak)IBOutlet UILabel * titleLabel;

@end

NS_ASSUME_NONNULL_END
