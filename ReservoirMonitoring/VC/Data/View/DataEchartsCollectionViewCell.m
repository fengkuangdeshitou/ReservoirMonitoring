//
//  DataEchartsCollectionViewCell.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/16.
//

#import "DataEchartsCollectionViewCell.h"
#import "GlobelDescAlertView.h"
@import iOS_Echarts;

@interface DataEchartsCollectionViewCell ()

@property(nonatomic,strong) WKEchartsView * echartsView;
@property(nonatomic,weak)IBOutlet UIView * titleView;
@property(nonatomic,weak)IBOutlet UIView * echarts;
@property(nonatomic,weak)IBOutlet UILabel * energyTitle;

@property(nonatomic,weak)IBOutlet UILabel * independence;
@property(nonatomic,weak)IBOutlet UILabel * power;
@property(nonatomic,weak)IBOutlet UILabel * reducing;
@property(nonatomic,weak)IBOutlet UILabel * trees;
@property(nonatomic,weak)IBOutlet UILabel * coal;

@property(nonatomic,weak)IBOutlet UILabel * current;
@property(nonatomic,strong) NSArray * titleArray;
@property(nonatomic,strong) NSArray * normal;
@property(nonatomic,strong) NSArray * highlight;

@end

@implementation DataEchartsCollectionViewCell

- (IBAction)timeAction:(id)sender{
    if (self.time == 0) {
        [GlobelDescAlertView showAlertViewWithTitle:@"Description".localized desc:@"Self reliable rating = (battery energy consumption/ total energy consumption ) %, daily rating stands for the performance of last 24h"];
    }else if (self.time == 1){
        [GlobelDescAlertView showAlertViewWithTitle:@"Description".localized desc:@"Self reliable rating = (battery energy consumption/ total energy consumption ) %, monthly rating stands for the performance of last month."];
    }else if (self.time == 2){
        [GlobelDescAlertView showAlertViewWithTitle:@"Description".localized desc:@"Self reliable rating = (battery energy consumption/ total energy consumption ) %, annual rating stands for the performance of last year."];
    }else{
        [GlobelDescAlertView showAlertViewWithTitle:@"Description".localized desc:@"Self reliable rating = (battery energy consumption/ total energy consumption ) %, total rating stands for the performance since installation."];
    }
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.energyTitle.text = @"Energy curve".localized;
    self.titleArray = @[@"Grid".localized,@"Solar".localized,@"Generator".localized,@"EV",@"Other loads".localized,@"Backup loads".localized];
    self.independence.text = @"Self reliable:".localized;
    self.power.text = @"Power outage:".localized;
    self.reducing.text = @"Reducing deforestation:".localized;
    self.trees.text = @"trees".localized;
    self.coal.text = @"Standard coal saved".localized;
    self.normal = @[@"data_normal_0",@"data_normal_1",@"data_normal_2",@"data_normal_3",@"data_normal_4",@"data_normal_5"];
    self.highlight = @[@"data_select_0",@"data_select_1",@"data_select_2",@"data_select_3",@"data_select_4",@"data_select_5"];
    CGFloat width = (SCREEN_WIDTH-30)/self.normal.count;
    for (int i=0; i<self.normal.count; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake((width-0.5)*i, 3, width, 24);
        [button setImage:[UIImage imageNamed:self.normal[i]] forState:UIControlStateNormal];
        button.tag = i+10;
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.titleView addSubview:button];
    }
    [self buttonClick:[self viewWithTag:10]];
    
    self.echartsView = [[WKEchartsView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 222)];
    [self.echarts addSubview:self.echartsView];
    PYOption * option = [[PYOption alloc] init];
    option.calculable = NO;
    option.color = @[@"#F7B500"];
    PYGrid * grid = [[PYGrid alloc] init];
    grid.x = @(34);
    grid.y = @(23);
    grid.x2 = @(15);
    grid.y2 = @(40);
    option.grid = grid;
    PYAxis * xAxis = [[PYAxis alloc] init];
    xAxis.type = PYAxisTypeCategory;
    xAxis.boundaryGap = @(NO);
    xAxis.splitLine.lineStyle.color = [[PYColor alloc] initWithColor:UIColor.clearColor];
    xAxis.axisLine.lineStyle.color = [[PYColor alloc] initWithColor:UIColor.clearColor];
    xAxis.data = [[NSMutableArray alloc] initWithArray:@[@1,@2,@3,@4,@5,@6,@7,@8,@9,@10,@11,@12]];
    option.xAxis = [[NSMutableArray alloc] initWithObjects:xAxis, nil ];
    PYAxis * yaxis = [[PYAxis alloc] init];
    yaxis.type = PYAxisTypeValue;
    yaxis.splitNumber = @6;
    yaxis.splitArea.areaStyle.color = [[PYColor alloc] initWithColor:UIColor.clearColor];
    yaxis.axisLine.lineStyle.color = [[PYColor alloc] initWithColor:UIColor.clearColor];
    yaxis.splitLine.lineStyle.color = [[PYColor alloc] initWithColor:[UIColor colorWithHexString:@"#333333"]];
    option.yAxis = [[NSMutableArray alloc] initWithObjects:yaxis, nil];
    NSMutableArray * seriesArray = [[NSMutableArray alloc] init];
    PYCartesianSeries * series = [[PYCartesianSeries alloc] init];
    series.type = PYSeriesTypeLine;
    series.smooth = true;
    series.symbolSize = @2;
    PYItemStyle * style = [[PYItemStyle alloc] init];
    PYItemStyleProp * prop = [[PYItemStyleProp alloc] init];
    prop.borderColor = [PYColor colorWithHexString:COLOR_MAIN_COLOR];
    style.normal = prop;
    series.itemStyle = style;
    series.data = @[@0,@10,@25,@55,@88,@130,@90,@68,@45,@26,@14,@0];
    [seriesArray addObject:series];
    option.series = seriesArray;
    [self.echartsView setOption:option];
//    [self.echartsView setOption:[self getRideDetailLineOptionWithTimeArray:@[@1,@2,@3,@4,@5] valueArray:@[@23,@45,@78,@34,@10]]];
    [self.echartsView loadEcharts];
    
}

- (PYOption *)getRideDetailLineOptionWithTimeArray:(NSArray *)dataArray valueArray:(NSArray *)valueArray{
    PYOption * option = [[PYOption alloc] init];
    //是否启用拖拽重计算特性，默认关闭
    option.calculable = NO;
    //折线颜色
    option.color = @[COLOR_MAIN_COLOR];
    //图标背景色
    option.backgroundColor = [[PYColor alloc] initWithColor:[UIColor whiteColor]];
    
    //提示框
    PYTooltip *tooltip = [[PYTooltip alloc] init];
    //触发类型，默认数据触发
    tooltip.trigger = PYTooltipTriggerItem;
    //背景色
    tooltip.backgroundColor = [[PYColor alloc] initWithColor:[UIColor colorWithHexString:@"#FEFFFF"]];
    //竖线宽度
    tooltip.axisPointer.lineStyle.width = @0;
    //提示框,文字样式设置
    tooltip.textStyle = [[PYTextStyle alloc] init];
    tooltip.textStyle.fontSize = @12;
    tooltip.textStyle.color = [[PYColor alloc] initWithColor:[UIColor colorWithHexString:@"#686B6D"]];
//    tooltip.formatter = @"(function(params){ var res = params[0].name; for (var i = 0, l = params.length; i < l; i++) {res += '<br/>' + params[i].seriesName + ' : ' + params[i].value;}; return res})";
    tooltip.formatter = @"(function(params){ var res = params.value; return '<br/>' + 'Distance:' + res + 'km'})";
    //添加到图标选择中
    option.tooltip = tooltip;
    
    /* 直角坐标系内绘图网格 */
    PYGrid * grid = [[PYGrid alloc] init];
    /*
        x:网格图左上角顶点距坐标系背景左侧的距离
        y:网格图左上角顶点距坐标系背景上侧的距离
        x2:网格图右下角顶点距坐标系背景右侧的距离
        y2:网格图右下角距坐标系背景下侧的距离
    */
    grid.x = @(40);
    grid.x2 = @(20);
    grid.borderWidth = @(0);
    //添加到图标选择中
    option.grid = grid;
    
    /* x轴设置 */
    PYAxis * xAxis = [[PYAxis alloc] init];
    //横轴默认为类目型(就是坐标系自己设置,坐标系中仅有这些指定类目坐标)
    xAxis.type = PYAxisTypeCategory;
    //起始和结束俩端空白
    xAxis.boundaryGap = @(NO);
    //分隔线
    xAxis.splitArea.show = NO;
    //分割线颜色
    xAxis.splitLine.lineStyle.color = [[PYColor alloc] initWithColor:UIColor.clearColor];
    //坐标轴线
    xAxis.axisLine.show = YES;
    //坐标轴线颜色
    xAxis.axisLine.lineStyle.color = [[PYColor alloc] initWithColor:[UIColor colorWithHexString:@"#FF0000"]];
    //X轴坐标数据
    xAxis.data = [[NSMutableArray alloc] initWithArray:dataArray];
    //坐标轴小标记
    xAxis.axisTick = [[PYAxisTick alloc] init];
    xAxis.axisTick.show = NO;
    //添加到图标选择中
    option.xAxis = [[NSMutableArray alloc] initWithObjects:xAxis, nil ];
    
    /* Y轴设置 */
    PYAxis *yAxis = [[PYAxis alloc] init];
    //纵轴默认为数值型(就是坐标系统自动生成，坐标轴内包含数值区间内容全部坐标) ,改为@"category "会有问题
    yAxis.type = PYAxisTypeValue;
    //y轴分隔段数，默认不修改为5
    yAxis.splitNumber = @5;
    //起始和结束俩端空白
//    yAxis.boundaryGap = @(YES);
    //分隔线
    yAxis.splitArea.show = NO;
    //坐标轴线
    yAxis.axisLine.show = YES;
    yAxis.axisLine.lineStyle.color = [[PYColor alloc] initWithColor:[UIColor colorWithHexString:@"#FF0000"]];
    //分割线类型
//    yAxis.splitLine.lineStyle.type = @"dashed"; //'solid' | 'dotted' | 'dashed' 虚线类型
    //单位设置
    yAxis.axisLabel = [[PYAxisLabel alloc] init];
    yAxis.axisLabel.formatter = @"{value}";
    //添加到图标选择中
    option.yAxis = [[NSMutableArray alloc] initWithObjects:yAxis, nil];
    
    /* 定义坐标点数组 */
    NSMutableArray *seriesArr = [NSMutableArray array];
    /* 折线设置 */
    PYCartesianSeries *series = [[PYCartesianSeries alloc] init];
    series.name = @"Distance:";
    //类型为折线
    series.type = PYSeriesTypeLine;
    series.symbol = PYSymbolEmptyCircle;
    //坐标点大小
    series.symbolSize = @4;
    series.symbolRotate = @2;
    //坐标点样式，设置连线的宽度
    series.itemStyle = [[PYItemStyle alloc] init];
    series.itemStyle.normal = [[PYItemStyleProp alloc] init];
    series.itemStyle.normal.lineStyle = [[PYLineStyle alloc] init];
    series.itemStyle.normal.lineStyle.width = @(5);
    series.itemStyle.normal.lineStyle.color = [[PYColor alloc] initWithColor:[UIColor colorWithHexString:COLOR_MAIN_COLOR]];
    series.itemStyle.normal.areaStyle = [[PYAreaStyle alloc] init];
    series.itemStyle.normal.areaStyle.color = @"(function (){var zrColor = zrender.tool.color;return zrColor.getLinearGradient(0, 140, 0, 280,[[0, 'rgba(86,177,156,0.4)'],[1, 'rgba(255,255,255,0.1)']])})()";
    //添加坐标点 y轴数据 (如果某一点无数据，可以传@"-",断开连线 如: @[@"1000",@"-", @"7571"])
    series.data = valueArray;
    [seriesArr addObject:series];
    [option setSeries:seriesArr];
    return option;
}

- (void)buttonClick:(UIButton *)btn{
    for (int i=0;i<self.normal.count;i++) {
        UIButton * button = [self.titleView viewWithTag:i+10];
        button.backgroundColor = UIColor.clearColor;
        [button setImage:[UIImage imageNamed:self.normal[i]] forState:UIControlStateNormal];
    }
    [btn setImage:[UIImage imageNamed:self.highlight[btn.tag-10]] forState:UIControlStateNormal];
    self.current.text = self.titleArray[btn.tag-10];
}

@end
