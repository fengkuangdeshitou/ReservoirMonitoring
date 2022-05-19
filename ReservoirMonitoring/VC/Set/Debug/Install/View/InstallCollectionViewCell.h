//
//  InstallCollectionViewCell.h
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/5/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface InstallCollectionViewCell : UICollectionViewCell

@property(nonatomic,weak)IBOutlet UIView * leftLine;
@property(nonatomic,weak)IBOutlet UIView * rightLine;
@property(nonatomic,weak)IBOutlet UILabel * indexLabel;
@property(nonatomic,weak)IBOutlet UILabel * titleLabel;

@end

NS_ASSUME_NONNULL_END
