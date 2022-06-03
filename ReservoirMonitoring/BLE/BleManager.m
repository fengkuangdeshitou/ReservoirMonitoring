//
//  BleManager.m
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/5/18.
//

#import "BleManager.h"

@interface BleManager ()<CBCentralManagerDelegate,CBPeripheralDelegate>

@property(nonatomic,strong) CBCentralManager * centralManager;
@property(nonatomic,strong) CBPeripheral * peripheral;
@property(nonatomic,strong) CBCharacteristic *readCharacteristic;
@property(nonatomic,strong) CBCharacteristic *writecCharacteristic;
@property(nonatomic,strong) NSMutableData * blueData;
@property(nonatomic,copy)void(^finish)(NSArray * array);
@property(nonatomic,copy)void(^writeFinish)(void);

@end

@implementation BleManager

NSString * const  UUID_CONTROL_SERVICE =           @"EE6D7170-88C6-11E8-B444-060400EF5315";
NSString * const  UUID_READ_CHARACTERISTICS =      @"EE6D7172-88C6-11E8-B444-060400EF5315";
NSString * const  UUID_WRITE_CHARACTERISTICS =     @"EE6D7171-88C6-11E8-B444-060400EF5315";

static BleManager * _manager = nil;

+ (instancetype)shareInstance{
    if (_manager == nil) {
        _manager = [[BleManager alloc] init];
        _manager.isAutoConnect = true;
    }
    return _manager;
}

- (CBCentralManager *)centralManager{
    if (!_centralManager) {
        dispatch_queue_t centralQueue = dispatch_queue_create("centralQueue",DISPATCH_QUEUE_SERIAL);
        NSDictionary *options =@{CBCentralManagerOptionShowPowerAlertKey:@YES,CBCentralManagerOptionRestoreIdentifierKey:@"unique identifier"};
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:centralQueue options:options];
    }
    return _centralManager;
}

- (void)startScanning{
    NSDictionary *option = @{CBCentralManagerScanOptionAllowDuplicatesKey:[NSNumber numberWithBool:NO],CBCentralManagerOptionShowPowerAlertKey:@YES};
    [self.centralManager scanForPeripheralsWithServices:nil options:option];
}

- (void)stopScan{
    [self.centralManager stopScan];
}

- (void)readValueWithCMD:(Byte)cmd{
    Byte byte[3] = {0x52,0x01,cmd};
    long value = [self CRC16Table:byte len:sizeof(byte)];
    Byte CRCByte[4] = {};
    CRCByte[0] = (Byte) ((value>>24) & 0xFF);
    CRCByte[1] = (Byte) ((value>>16) & 0xFF);
    CRCByte[2] = (Byte) ((value>>8) & 0xFF);
    CRCByte[3] = (Byte) (value & 0xFF);
    Byte readByte[] = {0x52,0x01,cmd,CRCByte[3],CRCByte[2],0x45};
    NSData * data = [[NSData alloc] initWithBytes:readByte length:sizeof(readByte)];
    [self.peripheral writeValue:data forCharacteristic:self.readCharacteristic type:CBCharacteristicWriteWithoutResponse];
}

- (void)readWithCMDString:(NSString *)string count:(int)count finish:(void (^)(NSArray * array))finish{
    self.finish = finish;
    [NSUserDefaults.standardUserDefaults setValue:string forKey:BLE_CMD];
    long value = [self convertHexToDecimal:string];
    Byte * byte = [self longToByte:value];
    Byte stringByte[2] = {byte[3],byte[2]};
    
    Byte crcByte[6] = {0x64,0x03,stringByte[1],stringByte[0],0x00,count};
    long crcValue = [self CRC16Table:crcByte len:sizeof(crcByte)];
    Byte * crc = [self longToByte:crcValue];
    
    Byte readByte[] = {0x64,0x03,stringByte[1],stringByte[0],0x00,count,crc[3],crc[2]};
    NSData * readData = [[NSData alloc] initWithBytes:readByte length:sizeof(readByte)];
    NSString * readString = [self convertDataToHexStr:readData];
    NSDictionary * dictionary = @{@"RawModbus":readString};
    NSData * dictData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingFragmentsAllowed error:nil];
    if (!self.writecCharacteristic) {
        return;
    }
    [self.peripheral writeValue:dictData forCharacteristic:self.writecCharacteristic type:CBCharacteristicWriteWithoutResponse];
}

- (Byte*)longToByte:(long)value{
    Byte byte[4] = {};
    byte[0] =(Byte) ((value>>24) & 0xFF);
    byte[1] =(Byte) ((value>>16) & 0xFF);
    byte[2] =(Byte) ((value>>8) & 0xFF);
    byte[3] =(Byte) (value & 0xFF);
    return byte;
}

- (Byte *)longTo2Byte:(long)value{
    Byte byte[2] = {};
    byte[0] = (Byte) (value & 0xFF);
    byte[1] = (Byte) ((value>>8) & 0xFF);
    return (Byte *)byte;
}

/// 16进制字符串转10进制数字
- (unsigned long long)convertHexToDecimal:(NSString *)hexStr {
    unsigned long long decimal = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexStr];
    [scanner scanHexLongLong:&decimal];
    return decimal;
}

- (void)writeWithCMDString:(NSString *)string array:(NSArray *)array finish:(nonnull void (^)(void))finish{
    self.writeFinish = finish;
    long value = [self convertHexToDecimal:string];
    Byte * byte = [self longToByte:value];
    Byte stringByte[2] = {byte[3],byte[2]};
    
    long hexCount = [self convertHexToDecimal:[NSString stringWithFormat:@"%ld",array.count]];
    Byte * countByte = [self longToByte:hexCount];
    Byte countByte2[2] = {countByte[3],countByte[2]};
    
    long length = array.count*2+7;
    Byte crcByte[length];
    crcByte[0] = 0x64;
    crcByte[1] = 0x10;
    crcByte[2] = stringByte[1];
    crcByte[3] = stringByte[0];
    crcByte[4] = countByte2[1];
    crcByte[5] = countByte2[0];
    crcByte[6] = array.count*2;
    for (int i=0; i<array.count; i++) {
        NSString * str = array[i];
        int a = str.intValue;
        Byte * longByte = [self longTo2Byte:a];
        Byte HByte = longByte[1];
        Byte LByte = longByte[0];
        for (int j=0; j<2; j++) {
            crcByte[i*2+7+j] = j == 0 ? HByte : LByte;
        }
    }
    Byte writeByte[length+2];
    for (int i=0; i<length; i++) {
        writeByte[i] = crcByte[i];
    }
    long crcValue = [self CRC16Table:crcByte len:sizeof(crcByte)];
    Byte * crc = [self longTo2Byte:crcValue];
    Byte crcHByte = crc[1];
    Byte crcLbyte = crc[0];

    writeByte[length] = crcLbyte;
    writeByte[length+1] = crcHByte;
    
    NSData * data = [[NSData alloc] initWithBytes:writeByte length:sizeof(writeByte)];
    NSString * readString = [self convertDataToHexStr:data];
    NSDictionary * dictionary = @{@"RawModbus":readString};
    NSData * dictData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingFragmentsAllowed error:nil];
    if (!self.writecCharacteristic) {
        return;
    }
    [self.peripheral writeValue:dictData forCharacteristic:self.writecCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (void)writeWithCMDString:(NSString *)string string:(NSString *)value{
    long hexValue = [self convertHexToDecimal:string];
    Byte * byte = [self longToByte:hexValue];
    Byte stringByte[2] = {byte[3],byte[2]};
    
    long hexValue2 = [self convertHexToDecimal:value];
    Byte * longByte = [self longToByte:hexValue2];
    Byte stringByte2[2] = {longByte[3],longByte[2]};
    
    Byte crcByte[6] = {0x64,0x06,stringByte[1],stringByte[0],stringByte2[1],stringByte2[0]};
    long crcValue = [self CRC16Table:crcByte len:sizeof(crcByte)];
    Byte * crc = [self longToByte:crcValue];
    
    Byte readByte[] = {0x64,0x06,stringByte[1],stringByte[0],stringByte2[1],stringByte2[0],crc[3],crc[2]};
    NSData * readData = [[NSData alloc] initWithBytes:readByte length:sizeof(readByte)];
    NSString * readString = [self convertDataToHexStr:readData];
    NSDictionary * dictionary = @{@"RawModbus":readString};
    NSData * dictData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingFragmentsAllowed error:nil];
    [self.peripheral writeValue:dictData forCharacteristic:self.writecCharacteristic type:CBCharacteristicWriteWithoutResponse];
    
}

/// int 转byte
- (Byte)getByteWithInt:(int)value{
    return (Byte)0xff&value;
}

- (void)writeValueWithCMD:(Byte)cmd value:(Byte)valueByte{
    Byte byte[5] = {0x57,0x03,cmd,0x01,valueByte};
    long value = [self CRC16Table:byte len:sizeof(byte)];
    Byte CRCByte[4] = {};
    CRCByte[0] = (Byte) ((value>>24) & 0xFF);
    CRCByte[1] = (Byte) ((value>>16) & 0xFF);
    CRCByte[2] = (Byte) ((value>>8) & 0xFF);
    CRCByte[3] = (Byte) (value & 0xFF);
    Byte readByte[] = {0x57,0x03,cmd,0x01,valueByte,CRCByte[3],CRCByte[2],0x45};
    NSData * data = [[NSData alloc] initWithBytes:readByte length:sizeof(readByte)];
    [self.peripheral writeValue:data forCharacteristic:self.readCharacteristic type:CBCharacteristicWriteWithResponse];
}

//第一种高低位的crc16校验
static unsigned char auchCRCHi[] = {
    0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0,
    0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41,
    0x00, 0xC1, 0x81, 0x40, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0,
    0x80, 0x41, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40,
    0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1,
    0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0, 0x80, 0x41,
    0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1,
    0x81, 0x40, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41,
    0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0,
    0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x00, 0xC1, 0x81, 0x40,
    0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1,
    0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40,
    0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0,
    0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x00, 0xC1, 0x81, 0x40,
    0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0,
    0x80, 0x41, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40,
    0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0,
    0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41,
    0x00, 0xC1, 0x81, 0x40, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0,
    0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41,
    0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0,
    0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x00, 0xC1, 0x81, 0x40,
    0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1,
    0x81, 0x40, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41,
    0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0,
    0x80, 0x41, 0x00, 0xC1, 0x81, 0x40
};
//低位字节表
/* Table of CRC values for low–order byte */
static unsigned char auchCRCLo[] = {
    0x00, 0xC0, 0xC1, 0x01, 0xC3, 0x03, 0x02, 0xC2, 0xC6, 0x06,
    0x07, 0xC7, 0x05, 0xC5, 0xC4, 0x04, 0xCC, 0x0C, 0x0D, 0xCD,
    0x0F, 0xCF, 0xCE, 0x0E, 0x0A, 0xCA, 0xCB, 0x0B, 0xC9, 0x09,
    0x08, 0xC8, 0xD8, 0x18, 0x19, 0xD9, 0x1B, 0xDB, 0xDA, 0x1A,
    0x1E, 0xDE, 0xDF, 0x1F, 0xDD, 0x1D, 0x1C, 0xDC, 0x14, 0xD4,
    0xD5, 0x15, 0xD7, 0x17, 0x16, 0xD6, 0xD2, 0x12, 0x13, 0xD3,
    0x11, 0xD1, 0xD0, 0x10, 0xF0, 0x30, 0x31, 0xF1, 0x33, 0xF3,
    0xF2, 0x32, 0x36, 0xF6, 0xF7, 0x37, 0xF5, 0x35, 0x34, 0xF4,
    0x3C, 0xFC, 0xFD, 0x3D, 0xFF, 0x3F, 0x3E, 0xFE, 0xFA, 0x3A,
    0x3B, 0xFB, 0x39, 0xF9, 0xF8, 0x38, 0x28, 0xE8, 0xE9, 0x29,
    0xEB, 0x2B, 0x2A, 0xEA, 0xEE, 0x2E, 0x2F, 0xEF, 0x2D, 0xED,
    0xEC, 0x2C, 0xE4, 0x24, 0x25, 0xE5, 0x27, 0xE7, 0xE6, 0x26,
    0x22, 0xE2, 0xE3, 0x23, 0xE1, 0x21, 0x20, 0xE0, 0xA0, 0x60,
    0x61, 0xA1, 0x63, 0xA3, 0xA2, 0x62, 0x66, 0xA6, 0xA7, 0x67,
    0xA5, 0x65, 0x64, 0xA4, 0x6C, 0xAC, 0xAD, 0x6D, 0xAF, 0x6F,
    0x6E, 0xAE, 0xAA, 0x6A, 0x6B, 0xAB, 0x69, 0xA9, 0xA8, 0x68,
    0x78, 0xB8, 0xB9, 0x79, 0xBB, 0x7B, 0x7A, 0xBA, 0xBE, 0x7E,
    0x7F, 0xBF, 0x7D, 0xBD, 0xBC, 0x7C, 0xB4, 0x74, 0x75, 0xB5,
    0x77, 0xB7, 0xB6, 0x76, 0x72, 0xB2, 0xB3, 0x73, 0xB1, 0x71,
    0x70, 0xB0, 0x50, 0x90, 0x91, 0x51, 0x93, 0x53, 0x52, 0x92,
    0x96, 0x56, 0x57, 0x97, 0x55, 0x95, 0x94, 0x54, 0x9C, 0x5C,
    0x5D, 0x9D, 0x5F, 0x9F, 0x9E, 0x5E, 0x5A, 0x9A, 0x9B, 0x5B,
    0x99, 0x59, 0x58, 0x98, 0x88, 0x48, 0x49, 0x89, 0x4B, 0x8B,
    0x8A, 0x4A, 0x4E, 0x8E, 0x8F, 0x4F, 0x8D, 0x4D, 0x4C, 0x8C,
    0x44, 0x84, 0x85, 0x45, 0x87, 0x47, 0x46, 0x86, 0x82, 0x42,
    0x43, 0x83, 0x41, 0x81, 0x80, 0x40
};

- (long)CRC16Table:(uint8_t *)puchMsg len:(uint8_t)leng
{
    uint8_t uchCRCHi = 0xFF;
    uint8_t uchCRCLo = 0xFF;
    uint8_t uIndex;
    while ( leng-- ) {
        uIndex = uchCRCLo ^ *puchMsg++ ; /* ??CRC */
        uchCRCLo = uchCRCHi ^ auchCRCHi[uIndex] ;
        uchCRCHi = auchCRCLo[uIndex] ;
    }
    return ( uchCRCHi << 8 | uchCRCLo ) ;
}

/// 连接外设
/// @param peripheral 外设
- (void)connectPeripheral:(CBPeripheral *)peripheral{
    [self.centralManager connectPeripheral:peripheral options:nil];
    peripheral.delegate = self;
    self.peripheral = peripheral;
}

/// 断开连接
- (void)disconnectPeripheral{
    if (self.peripheral != nil) {
        [self.centralManager cancelPeripheralConnection:self.peripheral];
        self.peripheral = nil;
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    if (self.delegate && [self.delegate respondsToSelector:@selector(bluetoothDidUpdateState:)]) {
        [self.delegate bluetoothDidUpdateState:central];
    }
    switch (central.state) {
        case CBManagerStateUnknown:
            NSLog(@"未知状态");
            break;
        case CBManagerStateResetting:
            NSLog(@"重启状态");
            break;
        case CBManagerStateUnsupported:
            NSLog(@"不支持");
            break;
        case CBManagerStateUnauthorized:
            NSLog(@"未授权");
            break;
        case CBManagerStatePoweredOff:
            NSLog(@"蓝牙未开启");
            break;
        case CBManagerStatePoweredOn:{
            NSLog(@"蓝牙已开启");
            NSArray * array = [self.centralManager retrieveConnectedPeripheralsWithServices:@[[CBUUID UUIDWithString:UUID_CONTROL_SERVICE]]];
            if (array.count > 0) {
                [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    CBPeripheral * peripheral = obj;
                    if (peripheral.state == CBPeripheralStateConnected && [peripheral.name isEqualToString:@"FASSAGE"]) {
                        if (self.delegate && [self.delegate respondsToSelector:@selector(bluetoothDidConnectPeripheral:)]) {
                            [self.delegate bluetoothDidConnectPeripheral:peripheral];
                        }
                        self.peripheral = peripheral;
                        self.peripheral.delegate = self;
                        [self.peripheral discoverServices:nil];
                    }else{
                        [self disconnectPeripheral];
                        [self startScanning];
                    }
                }];
            }else{
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self startScanning];
//                });
            }
        }
            break;
        default:
            break;
    }
}

/// 发现外设回调
/// @param central central
/// @param peripheral 外设类
/// @param advertisementData 广播值 一般携带设备名，serviceUUIDs等信息
/// @param RSSI RSSI绝对值越大，表示信号越差，设备离的越远。如果想装换成百分比强度，（RSSI+100）/100
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    if (!peripheral.name) {
        return;
    }
    NSLog(@"name=%@,%@",peripheral.name,RSSI);
    if (self.isAutoConnect) {
        if([peripheral.name hasPrefix:@"Moonflow"]){
            self.peripheral = peripheral;
            self.peripheral.delegate = self;
            //发起连接的命令
            [self.centralManager connectPeripheral:self.peripheral options:nil];
        }
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(bluetoothdidDiscoverPeripheral:RSSI:)]) {
        [self.delegate bluetoothdidDiscoverPeripheral:peripheral RSSI:RSSI];
    }
}

/// 蓝牙于后台被杀掉时，重连之后会首先调用此方法，可以获取蓝牙恢复时的各种状态
- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *,id> *)dict{
    NSLog(@"已连接外设=%@",dict);
    NSArray * peripheralArray = dict[@"kCBRestoredPeripherals"];
    for (CBPeripheral * peripheral in peripheralArray) {
        if (peripheral.state == CBPeripheralStateConnected) {
            for (CBService * service in peripheral.services) {
                NSLog(@"UUIDString=%@",service.UUID.UUIDString);
                if ([service.UUID.UUIDString isEqualToString:UUID_CONTROL_SERVICE]) {
                    self.peripheral = peripheral;
                    self.peripheral.delegate = self;
                    //发现特定服务的特征值
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self.peripheral discoverCharacteristics:nil forService:service];
                        if (self.delegate && [self.delegate respondsToSelector:@selector(bluetoothDidConnectPeripheral:)]) {
                            [self.delegate bluetoothDidConnectPeripheral:peripheral];
                        }
                    });
                    return;
                }
            }
        }else{
            [self disconnectPeripheral];
            [self startScanning];
        }
    }
}

/// 连接成功的回调
/// @param central 蓝牙管理
/// @param peripheral 外设
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    _isConnented = true;
    [self.centralManager stopScan];
    self.peripheral = peripheral;
    //连接成功之后寻找服务，传nil会寻找所有服务
    [peripheral discoverServices:nil];
}

/// 连接失败的回调
/// @param central 蓝牙管理
/// @param peripheral 外设
/// @param error 错误
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    NSLog(@"连接失败%s",__func__);
}

/// 连接断开
/// @param central 蓝牙管理
/// @param peripheral 外设
/// @param error 错误
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    NSLog(@"连接断开%s",__func__);
    _isConnented = false;
    if (self.delegate && [self.delegate respondsToSelector:@selector(bluetoothDidDisconnectPeripheral:)]) {
        [self.delegate bluetoothDidDisconnectPeripheral:peripheral];
    }
    if (self.peripheral) {
        [self.centralManager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES}];
        peripheral.delegate = self;
        self.peripheral = peripheral;
    }
}

// 发现服务的回调
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    for (CBService *service in peripheral.services) {
        NSLog(@"serviceUUID:%@", service.UUID.UUIDString);
        if ([service.UUID.UUIDString isEqualToString:UUID_CONTROL_SERVICE]) {
            //发现特定服务的特征值
            [self.peripheral discoverCharacteristics:nil forService:service];
            break;
        }
    }
}

//peripheral代理方法2
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error{
    for (CBService *service in peripheral.services) {
        NSLog(@"222Discovered service %@",service.UUID.UUIDString);
    }
    //这个方法并不会被调用，而且如果不实现peripheral代理方法1会报下面的错误
//API MISUSE: Discovering services for peripheral while delegate is either nil or does not implement peripheral:didDiscoverServices:
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    for (CBService *service in peripheral.services) {
        NSLog(@"service-----%@,%@",service.UUID.UUIDString,service.characteristics);
        for (CBCharacteristic * characteristic in service.characteristics) {
            if ([characteristic.UUID.UUIDString isEqualToString:UUID_WRITE_CHARACTERISTICS]) {
                NSData *data = characteristic.value;
                NSString *response = [self valueStringWithResponse:data];
                NSLog(@"aaaa写入蓝牙回复：%@,%@",response,data);
            }else if([characteristic.UUID.UUIDString isEqualToString:UUID_READ_CHARACTERISTICS]){
                NSData *data = characteristic.value;
                NSString *response = [self valueStringWithResponse:data];
                NSLog(@"aaaa读取蓝牙回复：%@,%@",response,data);
                NSString * code = [self valueStringWithCode:data];
                NSString * command = [self valueStringWithResponse:data];
                NSString * model = @"";
                if (code.intValue == 84) {
                    model = [self getTimeString:data];
                }else{
                    model = [self valueStringWithModel:data];
                }
//                if (self.delegate && [self.delegate respondsToSelector:@selector(bluetoothDidReceivedMessageWithCode:command:model:)]) {
//                    [self.delegate bluetoothDidReceivedMessageWithCode:code command:command model:model];
//                }
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray<CBService *> *)invalidatedServices{
    
}

//发现characteristics，由发现服务调用（上一步），获取读和写的characteristics
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        return;
    }
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"===%@,%lu",characteristic.UUID.UUIDString,(unsigned long)characteristic.properties);
        //有时读写的操作是由一个characteristic完成
        if ([characteristic.UUID.UUIDString isEqualToString:UUID_WRITE_CHARACTERISTICS]) {
            self.writecCharacteristic = characteristic;
            [self.peripheral setNotifyValue:YES forCharacteristic:self.writecCharacteristic];
        }else if ([characteristic.UUID.UUIDString isEqualToString:UUID_READ_CHARACTERISTICS]) {
            self.readCharacteristic = characteristic;
            [self.peripheral setNotifyValue:YES forCharacteristic:self.readCharacteristic];
        }
        //当发现characteristic有descriptor,回调didDiscoverDescriptorsForCharacteristic
//        [peripheral discoverDescriptorsForCharacteristic:characteristic];
    }
    
//    BluetoothData.shareInstance.model.isConnect = YES;
//    BluetoothData.shareInstance.model.lanyaName = self.peripheral.name;
//    [self readValueWithCMD:0x07];
    [self stopScan];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(bluetoothDidConnectPeripheral:)]) {
            [self.delegate bluetoothDidConnectPeripheral:peripheral];
        }
    });
}

//数据接收
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if([characteristic.UUID.UUIDString isEqualToString:UUID_READ_CHARACTERISTICS]){
        //获取订阅特征回复的数据
        NSData *data = characteristic.value;
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//        NSString *response = [self valueStringWithResponse:data];
        /// 成功
        NSLog(@"读取蓝牙回复：%@",dict);
        if ([dict objectForKey:@"RawModbus"]) {
            NSString * string = dict[@"RawModbus"];
            if (string.length < 4) {
                return;
            }
            NSString * cmd = [NSUserDefaults.standardUserDefaults objectForKey:BLE_CMD];
            
            NSString * style = [string substringWithRange:NSMakeRange(2, 2)];
            if (style.intValue == 3) {
                NSString * countHex = [string substringWithRange:NSMakeRange(4, 2)];
                int count = [[self decimalStringFromHexString:countHex] intValue];
                NSString * countValue = [string substringWithRange:NSMakeRange(6, count*2)];

                NSMutableArray * array = [[NSMutableArray alloc] init];
                for (int i=0; i<countValue.length; i+=4) {
                    int value = 0;
                    NSString * str = [countValue substringWithRange:NSMakeRange(i, 4)];
                    for(int j=0;j<str.length;j+=2){
                        NSString * hexString = [str substringWithRange:NSMakeRange(j, 2)];
                        value += [[self decimalStringFromHexString:hexString] intValue];
                    }
                    [array addObject:[NSString stringWithFormat:@"%d",value]];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.delegate && [self.delegate respondsToSelector:@selector(bluetoothDidReceivedCMD:array:)]) {
                        [self.delegate bluetoothDidReceivedCMD:cmd array:array];
                    }
                    if (self.finish) {
                        self.finish(array);
                    }
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.delegate && [self.delegate respondsToSelector:@selector(bluetoothDidReceivedCMD:array:)]) {
                        [self.delegate bluetoothDidReceivedCMD:cmd array:@[]];
                    }
                    if (self.finish) {
                        self.finish(@[]);
                    }
                });
            }
        }
        
        /// 失败
//        {
//            code = 2;
//        }
        
    } else if ([characteristic.UUID.UUIDString isEqualToString:UUID_WRITE_CHARACTERISTICS]){
        NSData *data = characteristic.value;
//        NSLog(@"蓝牙写入广播数据：%@,length=%lu",data,(unsigned long)data.length);
        [self appendBlueData:data];
    }
}

- (void)appendBlueData:(NSData *)data{
    NSData * header = [data subdataWithRange:NSMakeRange(0, 1)];
    NSData * headerData = [[NSData alloc] initWithBytes:header.bytes length:header.length];
    NSString * cmd = [self convertDataToHexStr:headerData];
    if ([cmd isEqualToString:@"52"]) {
        if (self.blueData != nil) {
            [self getCMDAndVulueWithData:self.blueData];
        }
        self.blueData = [[NSMutableData alloc] init];
        [self.blueData appendData:data];
        return;
    }
        
    if (![cmd isEqualToString:@"52"] && self.blueData != nil) {
        [self.blueData appendData:data];
    }
}

- (void)getCMDAndVulueWithData:(NSData *)data{
    NSData * data1 = [data subdataWithRange:NSMakeRange(2, data.length-5)];
    NSData * contentData = [[NSData alloc] initWithBytes:data1.bytes length:data1.length];
    [self segmentationCMDAndValueWithData:contentData];
}

- (void)segmentationCMDAndValueWithData:(NSData *)data{
    if (data.length == 0) {
        return;
    }
    NSData * header = [data subdataWithRange:NSMakeRange(0, 1)];
    NSData * headerData = [[NSData alloc] initWithBytes:header.bytes length:header.length];
    NSString * cmd = [self convertDataToHexStr:headerData];

    NSData * data1 = [data subdataWithRange:NSMakeRange(header.length, data.length-1)];

    NSData * count = [data1 subdataWithRange:NSMakeRange(0, 1)];
    NSData * countData = [[NSData alloc] initWithBytes:count.bytes length:count.length];
    NSString * hexCountString = [self convertDataToHexStr:countData];
    NSString * countValue = [NSString stringWithFormat:@"%lu",strtoul(hexCountString.UTF8String, 0, 16)];

    NSData * data2 = [data1 subdataWithRange:NSMakeRange(count.length, data.length-1-count.length)];

    if ([countValue intValue] > data2.length) {
        return;
    }
    
    NSData * value = [data2 subdataWithRange:NSMakeRange(0, [countValue intValue])];
    NSData * valueData = [[NSData alloc] initWithBytes:value.bytes length:value.length];
    NSString * valueString = [self convertDataToHexStr:valueData];
    
//    NSLog(@"cmd=%@,countValue=%@,content=%@",cmd,countValue,valueString);
    [self  setModelDataWithCMD:cmd value:valueString data:valueData];
    NSData * newData = [data2 subdataWithRange:NSMakeRange([countValue intValue], data.length-1-[countValue intValue]-count.length)];
    if (newData.length > 0) {
        [self segmentationCMDAndValueWithData:newData];
    }
}

- (void)setModelDataWithCMD:(NSString *)cmd value:(NSString *)value data:(NSData *)data{
//    BluetoothData * bluetoothData = BluetoothData.shareInstance;
//    // 当前时速
//    if ([cmd isEqualToString:@"11"]) {
//        CGFloat speed = [[self getTimeString:data] floatValue]/10;
//        bluetoothData.model.speed = [NSString stringWithFormat:@"%.0f",speed];
//    }
//    //平均时速
//    if ([cmd isEqualToString:@"13"]) {
//        CGFloat averageSpeed = [[self getTimeString:data] floatValue]/10;
//        bluetoothData.model.averageSpeed = [NSString stringWithFormat:@"%.1f",averageSpeed];
//    }
//    //本次骑行公里数
//    if ([cmd isEqualToString:@"14"]) {
//        CGFloat distance = [[self getTimeString:data] floatValue]/10;
//        bluetoothData.model.distance = [NSString stringWithFormat:@"%.1f",distance];
//    }
//    //本次骑行时常
//    if ([cmd isEqualToString:@"15"]) {
//        CGFloat duration = [[self getTimeString:data] floatValue]/10;
//        bluetoothData.model.duration = [NSString stringWithFormat:@"%.0f",duration];
//    }
//    if ([cmd isEqualToString:@"1a"]) {
//        NSInteger battery = [[self getTimeString:data] integerValue];
//        bluetoothData.model.battery = battery;
//    }
//    if ([cmd isEqualToString:@"00"]) {
//        BOOL isConnect = [value boolValue];
//        bluetoothData.model.isConnect = isConnect;
//    }
//    if ([cmd isEqualToString:@"01"]) {
//        NSData * nameData = [self dataWithHexString:value];
//        NSString * productName = [[NSString alloc] initWithData:nameData encoding:NSUTF8StringEncoding];
//        bluetoothData.model.productName = productName;
//    }
//    if ([cmd isEqualToString:@"07"]) {
//        NSData * deviceFactoryCodeData = [self dataWithHexString:value];
//        NSString * deviceFactoryCode = [[NSString alloc] initWithData:deviceFactoryCodeData encoding:NSUTF8StringEncoding];
//        bluetoothData.model.deviceFactoryCode = deviceFactoryCode;
//    }
//    if ([cmd isEqualToString:@"16"]) {
//        NSInteger remain = [[self getTimeString:data] integerValue];
//        bluetoothData.model.remain = remain >= 65534 ? 0 : (remain * 1.7);
//    }
////    NSLog(@"dic=%@",[bluetoothData.model mj_JSONObject]);
//    if (self.isRecordingData) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSDictionary * rideCacheData = [NSUserDefaults.standardUserDefaults objectForKey:@"RideCacheData"];
//            if (rideCacheData) {
//                NSDictionary * item = [self createDataItem];
//                if ([item[@"time"] longLongValue] - [rideCacheData[@"time"] longLongValue] > 10) {
//                    [NSUserDefaults.standardUserDefaults setValue:item forKey:@"RideCacheData"];
//                    [self uploadRideCacheData];
//                }
//            }else{
//                [NSUserDefaults.standardUserDefaults setValue:[self createDataItem] forKey:@"RideCacheData"];
//            }
//        });
//    }
}

- (NSDictionary *)createDataItem{
    NSDate * data = [NSDate date];
    NSString * time = [NSString stringWithFormat:@"%.0f",[data timeIntervalSince1970]];
//    BluetoothData * bluetoothData = BluetoothData.shareInstance;
//    return @{@"time":time,@"distance":bluetoothData.model.distance?:@"",@"speed":bluetoothData.model.speed?:@"0",@"duration":bluetoothData.model.duration?:@"",@"id":bluetoothData.model.cycleId?:@"",@"calorie":@"0",@"carbon":@"0"};
    return @{};
}

- (void)uploadRideCacheData{
//    [NetworkWorker networkPost:[NetworkUrlGetter getSynchCycleUrl] params:[NSUserDefaults.standardUserDefaults objectForKey:@"RideCacheData"] success:^(NSDictionary *result) {
//
//    } failure:^(NSString *errorMessage) {
//
//    }];
}

#pragma mark-----将十六进制数据转换成NSData
- (NSData*)dataWithHexString:(NSString*)str{
    
    if (!str || [str length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    return hexData;
    
}

- (NSString *)formarWithData:(NSData *)data rang:(NSRange)rang{
    
    if (!data || [data length] == 0) {
        return @"";
    }
    
    NSData *tailData = [data subdataWithRange:rang];
    NSData * valueData = [[NSData alloc] initWithBytes:tailData.bytes length:1];
    return [self convertDataToHexStr:valueData];
    
}

#pragma mark - 中心读取外设实时数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (characteristic.isNotifying) {
        if([characteristic.UUID.UUIDString isEqualToString:UUID_READ_CHARACTERISTICS]){
            NSLog(@"读取订阅成功");
//            [self.peripheral readValueForCharacteristic:self.readCharacteristic];
        } else if ([characteristic.UUID.UUIDString isEqualToString:UUID_WRITE_CHARACTERISTICS]){
            NSLog(@"写入订阅成功");
//            [self.peripheral readValueForCharacteristic:self.writecCharacteristic];
        }
    } else {
        //这里出错 一般是连接断开了
        NSLog(@"取消订阅");
        NSLog(@"Notification stopped data=%@,%lu",characteristic,(unsigned long)characteristic.value);
//        [self.centralManager cancelPeripheralConnection:peripheral];
    }
}

//是否写入成功的代理
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        NSLog(@"===写入错误：%@",error);
    }else{
        NSLog(@"===写入成功=%@",characteristic.value);
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self.writeFinish){
                self.writeFinish();
            }
        });
    }
}

- (NSString *)valueStringWithCode:(NSData *)data {
    
    if (!data || [data length] == 0) {
        return @"";
    }
    
    NSData *tailData = [data subdataWithRange:NSMakeRange(2, 1)];
    NSData * valueData = [[NSData alloc] initWithBytes:tailData.bytes length:1];
    return [self convertDataToHexStr:valueData];
    
}

/*
 *   把返回命令里的传递值拿出来
 */
- (NSString *)valueStringWithResponse:(NSData *)data {
    
    if (!data || [data length] == 0) {
        return @"";
    }

    NSData *tailData = [data subdataWithRange:NSMakeRange(2, [data length]-2)];
    NSData * valueData = [[NSData alloc] initWithBytes:tailData.bytes length:tailData.length];
    NSLog(@"%@,%@",[NSJSONSerialization JSONObjectWithData:valueData options:NSJSONReadingAllowFragments error:nil],[[NSString alloc] initWithData:valueData encoding:NSUTF8StringEncoding]);
    return [self convertDataToHexStr:valueData];
    
}

- (NSString *)valueStringWithModel:(NSData *)data {
    
    if (!data || [data length] == 0) {
        return @"";
    }
    
    NSData *tailData = [data subdataWithRange:NSMakeRange(4, 1)];
    NSData * valueData = [[NSData alloc] initWithBytes:tailData.bytes length:1];
    return [self convertDataToHexStr:valueData];
    
}

- (NSString *)getTimeString:(NSData *)data {
    
    if (!data || [data length] == 0) {
        return @"";
    }
    
    
    NSData *tailData = [data subdataWithRange:NSMakeRange(0, 1)];
    NSData * valueData = [[NSData alloc] initWithBytes:tailData.bytes length:1];
    NSString *hexString = [self convertDataToHexStr:valueData];
    
    NSString *hexString1 = @"";
    if (data.length > 1) {
        NSData *tailData1 = [data subdataWithRange:NSMakeRange(1, 1)];
        NSData * valueData1 = [[NSData alloc] initWithBytes:tailData1.bytes length:1];
        hexString1 = [self convertDataToHexStr:valueData1];
    }
    
    NSString * hex = [NSString stringWithFormat:@"%@%@",hexString1,hexString];
    return [self decimalStringFromHexString:hex];
    
}


- (NSString *)decimalStringFromHexString:(NSString *)string{
    NSString * decimalStr = [NSString stringWithFormat:@"%lu",strtoul([string UTF8String],0,16)];
    return decimalStr;
}

- (NSString *)convertDataToHexStr:(NSData *)data{
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    
    return string;
}

- (void)dealloc{
    NSLog(@"%s",__func__);
}

@end
