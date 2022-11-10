//
//  SelectImageCollectionViewCell.h
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/11/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SelectImageCollectionViewCell : UICollectionViewCell

@property(nonatomic,weak)IBOutlet UIView * addView;
@property(nonatomic,weak)IBOutlet UIImageView * icon;
@property(nonatomic,weak)IBOutlet UIButton * deleteBtn;

@end

NS_ASSUME_NONNULL_END
