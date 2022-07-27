//
//  WeatherTableViewCell.h
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/5/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WeatherTableViewCell : UITableViewCell

@property(nonatomic,strong) NSArray * model;
@property(nonatomic,weak)IBOutlet UIImageView * icon;

@end

NS_ASSUME_NONNULL_END
