//
//  PeakTimeTableViewCell.h
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/16.
//

#import <UIKit/UIKit.h>
#import "TimeTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface PeakTimeTableViewCell : UITableViewCell

@property(nonatomic,strong) NSMutableArray * dataArray;
@property(nonatomic,weak)IBOutlet UIButton * switchBtn;
@property(nonatomic,weak)IBOutlet UITableView * tableView;
@property(nonatomic,strong) NSArray * touArray;
@property(nonatomic,strong) NSArray * peakTimeArray;
@property(nonatomic,strong) NSArray * superPeakTimeArray;

@end

NS_ASSUME_NONNULL_END
