//
//  DataEchartsCollectionViewCell.h
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DataEchartsCollectionViewCell : UICollectionViewCell

@property(nonatomic,assign) NSInteger time;
@property(nonatomic,weak)IBOutlet UILabel * selfHelpRate;
@property(nonatomic,weak)IBOutlet UILabel * treeNum;
@property(nonatomic,weak)IBOutlet UILabel * coalValue;
@property(nonatomic,assign) NSArray * dataArray;
@property(nonatomic,assign) NSInteger scopeType;

@end

NS_ASSUME_NONNULL_END
