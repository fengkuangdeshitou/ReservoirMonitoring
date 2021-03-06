//
//  TimeTableViewCell.h
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TimeTableViewCell : UITableViewCell

@property(nonatomic,weak)IBOutlet UIButton * removeButton;
@property(nonatomic,weak)IBOutlet UITextField * startTime;
@property(nonatomic,weak)IBOutlet UITextField * endTime;
@property(nonatomic,weak)IBOutlet UITextField * electricity;
@property(nonatomic,strong) NSIndexPath * indexPath;
@property(nonatomic,copy) void(^valueChangeCompletion)(NSIndexPath * indexPath,NSString * key,NSString * value);

@end

NS_ASSUME_NONNULL_END
