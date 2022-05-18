//
//  PeripheralModel.h
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/5/18.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface PeripheralModel : NSObject

@property(nonatomic,strong) NSNumber * rssi;
@property(nonatomic,strong) CBPeripheral * peripheral;
@property(nonatomic,assign) BOOL isConnected;

@end

NS_ASSUME_NONNULL_END
