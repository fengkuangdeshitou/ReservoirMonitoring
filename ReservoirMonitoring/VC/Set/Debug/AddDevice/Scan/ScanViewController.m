//
//  ScanViewController.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/19.
//

#import "ScanViewController.h"
#import "ScanView.h"
@import AVFoundation;

@interface ScanViewController ()<AVCaptureMetadataOutputObjectsDelegate>

@property (strong, nonatomic) AVCaptureDevice * device; //捕获设备&#xff0c;默认后置摄像头
@property (strong, nonatomic) AVCaptureDeviceInput * input; //输入设备
@property (strong, nonatomic) AVCaptureMetadataOutput * output;//输出设备&#xff0c;需要指定他的输出类型及扫描范围
@property (strong, nonatomic) AVCaptureSession * session; //AVFoundation框架捕获类的中心枢纽&#xff0c;协调输入输出设备以获得数据
@property (strong, nonatomic) AVCaptureVideoPreviewLayer * previewLayer;//展示捕获图像的图层&#xff0c;是CALayer的子类

@end

@implementation ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //配置二维码扫描
    [self configBasicDevice];
    //开始启动
    [self.session startRunning];
}

- (void)configBasicDevice{
//默认使用后置摄像头进行扫描,使用AVMediaTypeVideo表示视频
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //设备输入 初始化
    self.input = [[AVCaptureDeviceInput alloc]initWithDevice:self.device error:nil];
    //设备输出 初始化&#xff0c;并设置代理和回调&#xff0c;当设备扫描到数据时通过该代理输出队列&#xff0c;一般输出队列都设置为主队列&#xff0c;也是设置了回调方法执行所在的队列环境
    self.output = [[AVCaptureMetadataOutput alloc]init];
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //会话 初始化&#xff0c;通过 会话 连接设备的 输入 输出&#xff0c;并设置采样质量为 高
    self.session = [[AVCaptureSession alloc]init];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    //会话添加设备的 输入 输出&#xff0c;建立连接
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    if ([self.session canAddOutput:self.output]) {
        [self.session addOutput:self.output];
    }
    //指定设备的识别类型 这里只指定二维码识别这一种类型 AVMetadataObjectTypeQRCode
    //指定识别类型这一步一定要在输出添加到会话之后&#xff0c;否则设备的课识别类型会为空&#xff0c;程序会出现崩溃
    [self.output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    //设置扫描信息的识别区域&#xff0c;本文设置正中央的一块正方形区域&#xff0c;该区域宽度是scanRegion_W
    //这里考虑了导航栏的高度&#xff0c;所以计算有点麻烦&#xff0c;识别区域越小识别效率越高&#xff0c;所以不设置整个屏幕
    //预览层 初始化&#xff0c;self.session负责驱动input进行信息的采集&#xff0c;layer负责把图像渲染显示
    //预览层的区域设置为整个屏幕&#xff0c;这样可以方便我们进行移动二维码到扫描区域,在上面我们已经对我们的扫描区域进行了相应的设置
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
    self.previewLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.previewLayer];
    //扫描框 和扫描线的布局和设置&#xff0c;模拟正在扫描的过程&#xff0c;这一块加不加不影响我们的效果&#xff0c;只是起一个直观的作用
    ScanView *scanview = [[ScanView alloc] initWithFrame:CGRectMake(0, (SCREEN_HEIGHT-NavagationHeight)/2-SCREEN_WIDTH/2, SCREEN_WIDTH, SCREEN_WIDTH)];
    [self.view addSubview:scanview];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
//后置摄像头扫描到二维码的信息
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    [self.session stopRunning];   //停止扫描
    if ([metadataObjects count] >= 1) {
        //数组中包含的都是AVMetadataMachineReadableCodeObject 类型的对象&#xff0c;该对象中包含解码后的数据
        AVMetadataMachineReadableCodeObject *qrObject = [metadataObjects lastObject];
        //拿到扫描内容在这里进行个性化处理
        NSString *result = qrObject.stringValue;
        //解析数据进行处理并实现相应的逻辑
        NSLog(@"result=%@",result);
        if (self.scanCode) {
            self.scanCode(result);
        }
        [self.navigationController popViewControllerAnimated:true];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
