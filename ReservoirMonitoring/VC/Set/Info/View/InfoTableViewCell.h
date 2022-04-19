//
//  InfoTableViewCell.h
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface InfoTableViewCell : UITableViewCell

@property(nonatomic,weak)IBOutlet UITextField * textfield;
@property(nonatomic,weak)IBOutlet UIImageView * icon;

@end

NS_ASSUME_NONNULL_END
