//
//  DataCollectionViewCell.h
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DataCollectionViewCell : UICollectionViewCell

@property(nonatomic,weak)IBOutlet UIImageView * icon;
@property(nonatomic,weak)IBOutlet UILabel * titleLabel;
@property(nonatomic,weak)IBOutlet UILabel * descLabel;

@end

NS_ASSUME_NONNULL_END
