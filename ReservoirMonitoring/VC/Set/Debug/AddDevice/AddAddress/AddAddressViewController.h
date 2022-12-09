//
//  AddAddressViewController.h
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/5/6.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AddAddressViewController : BaseViewController

@property(nonatomic,strong) NSString * sgSn;
@property(nonatomic,strong) NSString * name;
@property(nonatomic,strong) NSString * addressIds;
@property(nonatomic,strong) NSString * devId;
@property(nonatomic,strong) NSString * snItems;
@property(nonatomic,strong) NSString * inverteSN;
@property(nonatomic,strong) NSString * batterySN;
@property(nonatomic,strong) NSString * userEmail;
@property(nonatomic,strong) NSString * countrieID;
@property(nonatomic,strong) NSString * provinceID;
@property(nonatomic,strong) NSString * countrieString;
@property(nonatomic,strong) NSString * provinceString;
@property(nonatomic,strong) NSArray * dataArray;

@end

NS_ASSUME_NONNULL_END
