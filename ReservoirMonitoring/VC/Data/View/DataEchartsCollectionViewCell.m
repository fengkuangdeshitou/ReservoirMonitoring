//
//  DataEchartsCollectionViewCell.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/16.
//

#import "DataEchartsCollectionViewCell.h"
#import "GlobelDescAlertView.h"
@import Charts;
#import "ReservoirMonitoring-Swift.h"

@interface DataEchartsCollectionViewCell ()

@property(nonatomic,strong) LineChartView * lineEchartsView;
@property(nonatomic,strong) BarChartView * barEchartsView;
@property(nonatomic,strong) NSMutableArray * xArray;
@property(nonatomic,strong) NSMutableArray * selectArray;
@property(nonatomic,strong) NSMutableArray * datas;
@property(nonatomic,strong) NSMutableArray * selectTitleArray;
@property(nonatomic,strong) NSMutableArray * selectColorArray;

@property(nonatomic,weak)IBOutlet UIView * titleView;
@property(nonatomic,weak)IBOutlet UIView * echarts;
@property(nonatomic,weak)IBOutlet UILabel * energyTitle;

@property(nonatomic,weak)IBOutlet UILabel * independence;
@property(nonatomic,weak)IBOutlet UILabel * power;
@property(nonatomic,weak)IBOutlet UILabel * reducing;
@property(nonatomic,weak)IBOutlet UILabel * trees;
@property(nonatomic,weak)IBOutlet UILabel * coal;

@property(nonatomic,strong) NSArray * titleArray;
@property(nonatomic,strong) NSArray * normal;
@property(nonatomic,strong) NSArray * highlight;
@property(nonatomic,strong) BalloonMarker *marker;
@property(nonatomic,assign) NSInteger selectFlag;

@end

@implementation DataEchartsCollectionViewCell

- (IBAction)timeAction:(id)sender{
    if (self.time == 0) {
        [GlobelDescAlertView showAlertViewWithTitle:@"Description".localized desc:@"EP CUBE contribution ratio = (battery energy consumption/ total energy consumption ) %, daily rating stands for the performance of last 24h" btnTitle:nil completion:nil];
    }else if (self.time == 1){
        [GlobelDescAlertView showAlertViewWithTitle:@"Description".localized desc:@"EP CUBE contribution ratio = (battery energy consumption/ total energy consumption ) %, monthly rating stands for the performance of last month." btnTitle:nil completion:nil];
    }else if (self.time == 2){
        [GlobelDescAlertView showAlertViewWithTitle:@"Description".localized desc:@"EP CUBE contribution ratio = (battery energy consumption/ total energy consumption ) %, annual rating stands for the performance of last year." btnTitle:nil completion:nil];
    }else{
        [GlobelDescAlertView showAlertViewWithTitle:@"Description".localized desc:@"EP CUBE contribution ratio = (battery energy consumption/ total energy consumption ) %, total rating stands for the performance since installation." btnTitle:nil completion:nil];
    }
    
}

- (LineChartView *)lineEchartsView{
    if (!_lineEchartsView) {
        _lineEchartsView = [[LineChartView alloc] initWithFrame:CGRectMake(0, 15, SCREEN_WIDTH, 200)];
        _lineEchartsView.chartDescription.enabled = false;
        _lineEchartsView.doubleTapToZoomEnabled = NO;
        _lineEchartsView.noDataText = @"No chart data";
        _lineEchartsView.noDataTextColor = [UIColor colorWithHexString:@"#F7B500"];
        _lineEchartsView.noDataTextAlignment = NSTextAlignmentCenter;
        _lineEchartsView.pinchZoomEnabled = true;
        _lineEchartsView.scaleYEnabled = false;
        _lineEchartsView.drawGridBackgroundEnabled = true;
        _lineEchartsView.highlightPerDragEnabled = true;
        _lineEchartsView.gridBackgroundColor = UIColor.clearColor;
        _lineEchartsView.drawBordersEnabled = true;
        _lineEchartsView.borderLineWidth = 0;
        _lineEchartsView.borderColor = [UIColor colorWithHexString:@"#999999"];
        _lineEchartsView.legend.enabled = true;
        _lineEchartsView.legend.verticalAlignment = ChartLegendVerticalAlignmentTop;
        _lineEchartsView.legend.form = ChartLegendFormLine;
        _lineEchartsView.legend.formSize = 10;
        _lineEchartsView.legend.formLineWidth = 4;
        _lineEchartsView.legend.textColor = [UIColor colorWithHexString:COLOR_MAIN_COLOR];
        [_lineEchartsView animateWithXAxisDuration:1];
        [_lineEchartsView setExtraOffsetsWithLeft:10 top:0 right:15 bottom:0];
//        _lineEchartsView.minOffset = 0;
        
        ChartXAxis * xAxis = _lineEchartsView.xAxis;
        xAxis.labelPosition = XAxisLabelPositionBottom;
        xAxis.labelFont = [UIFont systemFontOfSize:10];
        xAxis.labelTextColor = UIColor.whiteColor;
        xAxis.labelTextColor = [UIColor whiteColor];
        xAxis.axisLineColor = [UIColor colorWithHexString:@"#999999"];
        xAxis.gridColor = [UIColor clearColor];
        xAxis.drawAxisLineEnabled = false;
        xAxis.drawGridLinesEnabled = true;
        xAxis.granularityEnabled = true;
//        xAxis.centerAxisLabelsEnabled = true;
        xAxis.yOffset = 10;
        xAxis.decimals = 1;
//        xAxis.avoidFirstLastClippingEnabled = true;
        
        ChartYAxis *leftAxis = _lineEchartsView.leftAxis;// 获取左边 Y 轴
        leftAxis.inverted = NO; // 是否将 Y 轴进行上下翻转
        leftAxis.axisLineWidth = 0;// 设置 Y 轴线宽
        leftAxis.axisLineColor = [UIColor colorWithHexString:@"#999999"];// 设置 Y 轴颜色
        leftAxis.labelPosition = YAxisLabelPositionOutsideChart;
        leftAxis.labelTextColor = [UIColor whiteColor];
        leftAxis.labelFont = [UIFont systemFontOfSize:10.0f];
        leftAxis.labelCount = 6;
//        [leftAxis setLabelCount:6 force:true];
//        leftAxis.forceLabelsEnabled = YES; // 不强制绘制指定数量的 label
        leftAxis.gridAntialiasEnabled = YES;// 网格线开启抗锯齿
        _lineEchartsView.chartDescription.enabled = NO;// 设置折线图描述
        _lineEchartsView.rightAxis.enabled = false;
        
        BalloonMarker * marker = [[BalloonMarker alloc]
                                 initWithColor:[[UIColor colorWithHexString:@"#2d2e30"] colorWithAlphaComponent:0.96]
                                 font:[UIFont systemFontOfSize:12.0]
                                 textColor:UIColor.whiteColor
                                 insets:UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0)
                                 scopeType:self.scopeType];
        marker.chartView = _lineEchartsView;
        marker.arrowSize = CGSizeMake(0, 0);
        _lineEchartsView.marker = marker;
        _lineEchartsView.legend.form = ChartLegendFormLine;
        [_lineEchartsView setScaleMinima:1 scaleY:1];
    }
    return _lineEchartsView;
}

- (void)setScopeType:(NSInteger)scopeType{
    _scopeType = scopeType;
    ((BalloonMarker*)self.lineEchartsView.marker).scopeType = scopeType;
    ((XYMarkerView*)self.barEchartsView.marker).scopeType = scopeType;
}

- (BarChartView *)barEchartsView{
    if (!_barEchartsView) {
        _barEchartsView = [[BarChartView alloc] initWithFrame:CGRectMake(0, 5, SCREEN_WIDTH, 210)];
        _barEchartsView.drawBordersEnabled = true;
        _barEchartsView.borderLineWidth = 0;
        _barEchartsView.drawGridBackgroundEnabled = NO;
        _barEchartsView.gridBackgroundColor = [UIColor clearColor];
        _barEchartsView.noDataText = @"No chart data";
        _barEchartsView.noDataTextColor = [UIColor colorWithHexString:@"#F7B500"];
        _barEchartsView.noDataTextAlignment = NSTextAlignmentCenter;
        _barEchartsView.chartDescription.enabled = NO;
        _barEchartsView.legend.enabled = true;
        _barEchartsView.legend.verticalAlignment = ChartLegendVerticalAlignmentTop;
        _barEchartsView.legend.form = ChartLegendFormLine;
        _barEchartsView.legend.formSize = 10;
        _barEchartsView.legend.formLineWidth = 4;
        _barEchartsView.legend.textColor = [UIColor colorWithHexString:COLOR_MAIN_COLOR];
        _barEchartsView.doubleTapToZoomEnabled = false;
        _barEchartsView.scaleXEnabled = false;
        _barEchartsView.scaleYEnabled = false;
        _barEchartsView.autoScaleMinMaxEnabled = true;
        _barEchartsView.highlightPerTapEnabled = true;
        _barEchartsView.highlightPerDragEnabled = true;
        _barEchartsView.pinchZoomEnabled = NO;  //手势捏合
        _barEchartsView.dragEnabled = YES;
        _barEchartsView.dragDecelerationFrictionCoef = 0.5;  //0 1 惯性
//        _barEchartsView.fitBars = true;
        _barEchartsView.chartDescription.enabled = NO;// 设置折线图描述
        _barEchartsView.drawValueAboveBarEnabled = YES;
//        _barEchartsView.extraBottomOffset = 5;
        [_barEchartsView setExtraOffsetsWithLeft:10 top:0 right:10 bottom:5];
        
        ChartXAxis * xAxis = _barEchartsView.xAxis;
        xAxis.labelPosition = XAxisLabelPositionBottom;
        xAxis.labelFont = [UIFont systemFontOfSize:10];
        xAxis.labelTextColor = UIColor.whiteColor;
        xAxis.drawLabelsEnabled = true;
//        xAxis.centerAxisLabelsEnabled = true;
//////        xAxis.axisLineColor = [UIColor colorWithHexString:@"#999999"];
        xAxis.gridColor = [UIColor clearColor];
        xAxis.drawAxisLineEnabled = false;
        xAxis.granularityEnabled = true;
        xAxis.yOffset = 10;
//        xAxis.drawGridLinesEnabled = true;
//        xAxis.labelCount = 6;
        
        ChartYAxis *leftAxis = _barEchartsView.leftAxis;// 获取左边 Y 轴
        leftAxis.inverted = NO; // 是否将 Y 轴进行上下翻转
        leftAxis.axisLineWidth = 0;// 设置 Y 轴线宽
        leftAxis.spaceTop = 0.9;
        leftAxis.axisLineColor = [UIColor colorWithHexString:@"#999999"];// 设置 Y 轴颜色
        leftAxis.labelPosition = YAxisLabelPositionOutsideChart;// label 文字位置
        leftAxis.labelTextColor = [UIColor whiteColor]; // label 文字颜色
        leftAxis.labelFont = [UIFont systemFontOfSize:10.0f]; // 不强制绘制指定数量的 label
        
        _barEchartsView.rightAxis.enabled = false;
        _barEchartsView.hidden = true;
        XYMarkerView *marker = [[XYMarkerView alloc]
                                      initWithColor:[[UIColor colorWithHexString:@"#2d2e30"] colorWithAlphaComponent:0.96]
                                      font: [UIFont systemFontOfSize:12.0]
                                      textColor: UIColor.whiteColor
                                      insets: UIEdgeInsetsMake(8, 8, 8, 8)
                                      ];
        marker.chartView = _barEchartsView;
        marker.arrowSize = CGSizeMake(0, 0);
        marker.minimumSize = CGSizeMake(40.f, 20.f);
        _barEchartsView.marker = marker;
    }
    
    return _barEchartsView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectFlag = 0;
    self.energyTitle.text = @"Energy curve".localized;
    self.independence.text = @"EP CUBE contribution ratio:".localized;
    self.power.text = @"Power outage:".localized;
    self.reducing.text = @"Reducing deforestation:".localized;
    self.trees.text = @"trees".localized;
    self.coal.text = @"Standard coal saved".localized;
    
    [self.echarts addSubview:self.lineEchartsView];
    [self.echarts addSubview:self.barEchartsView];
    
    self.xArray = [[NSMutableArray alloc] init];
    self.datas = [[NSMutableArray alloc] init];
    self.selectArray = [[NSMutableArray alloc] init];
    self.selectTitleArray = [[NSMutableArray alloc] init];
    self.selectColorArray = [[NSMutableArray alloc] init];

}

- (void)setBackUpType:(NSString *)backUpType{
    _backUpType = backUpType;
    for (UIView * view in self.titleView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            [view removeFromSuperview];
        }
    }
    if (backUpType.intValue == 1) {
        self.titleArray = @[@"Grid".localized,@"Solar".localized,@"Generator".localized,@"EV",@"Backup loads".localized];
        self.normal = @[@"data_normal_0",@"data_normal_1",@"data_normal_2",@"data_normal_3",@"data_normal_5"];
        self.highlight = @[@"data_select_0",@"data_select_1",@"data_select_2",@"data_select_3",@"data_select_5"];
    }else{
        self.titleArray = @[@"Grid".localized,@"Solar".localized,@"Generator".localized,@"EV",@"Non-backup".localized,@"Backup loads".localized];
        self.normal = @[@"data_normal_0",@"data_normal_1",@"data_normal_2",@"data_normal_3",@"data_normal_4",@"data_normal_5"];
        self.highlight = @[@"data_select_0",@"data_select_1",@"data_select_2",@"data_select_3",@"data_select_4",@"data_select_5"];
    }
    CGFloat width = (SCREEN_WIDTH-30)/self.normal.count;
    for (int i=0; i<self.normal.count; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake((width-0.5)*i, 3, width, 24);
        [button setImage:[UIImage imageNamed:self.normal[i]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:self.highlight[i]] forState:UIControlStateSelected];
        button.imageView.contentMode = UIViewContentModeScaleAspectFit;
        button.tag = i+10;
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.titleView addSubview:button];
    }
}

- (void)setDataArray:(NSArray *)dataArray{
    _dataArray = dataArray;
    if (dataArray.count > 0){
        [self formatDataArray];
    }
}

- (void)formatDataArray{
    [self.xArray removeAllObjects];
    [self.datas removeAllObjects];
    NSMutableArray * grid= [[NSMutableArray alloc] init];
    NSMutableArray * fromArray = [[NSMutableArray alloc] init];
    NSMutableArray * toArray= [[NSMutableArray alloc] init];
    NSMutableArray * solar= [[NSMutableArray alloc] init];
    NSMutableArray * generator= [[NSMutableArray alloc] init];
    NSMutableArray * ev= [[NSMutableArray alloc] init];
    NSMutableArray * backupLoads= [[NSMutableArray alloc] init];
    NSMutableArray * noBackupLoads= [[NSMutableArray alloc] init];
    NSInteger scopeType = 1;
    for (int i=0; i<self.dataArray.count; i++) {
        NSDictionary * dict = self.dataArray[i];
        NSDictionary * item = dict[@"nodeVo"];
        scopeType = [dict[@"scopeType"] integerValue];
        [self.xArray addObject:[NSString stringWithFormat:@"%@",dict[@"nodeName"]]];
        if (scopeType == 1) {
            [grid addObject:[NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@",item[@"gridPower"]]]];
        }else{
            [fromArray addObject:[NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@",item[@"gridElectricityFrom"]]]];
            [toArray addObject:[NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@",item[@"gridElectricityTo"]]]];
        }
        [solar addObject:[NSString stringWithFormat:@"%@",scopeType == 1 ? item[@"solarPower"] : item[@"solarElectricity"]]];
        [generator addObject:[NSString stringWithFormat:@"%@",scopeType == 1 ? item[@"generatorPower"] : item[@"generatorElectricity"]]];
        [ev addObject:[NSString stringWithFormat:@"%@",scopeType == 1 ? item[@"evPower"] : item[@"evElectricity"]]];
        if (self.backUpType.intValue == 1) {

        }else{
            [noBackupLoads addObject:[NSString stringWithFormat:@"%@",scopeType == 1 ? item[@"nonBackUpPower"] : item[@"nonBackUpElectricity"]]];
        }
        [backupLoads addObject:[NSString stringWithFormat:@"%@",scopeType == 1 ? item[@"backUpPower"] : item[@"backUpElectricity"]]];
    }
    if (self.scopeType == 1) {
        [self.datas addObject:grid];
    }else{
        [self.datas addObject:@[fromArray,toArray]];
    }
    [self.datas addObject:solar];
    [self.datas addObject:generator];
    [self.datas addObject:ev];
    if (self.backUpType.intValue == 1) {

    }else{
        [self.datas addObject:noBackupLoads];
    }
    [self.datas addObject:backupLoads];
    UIButton * btn = [self.titleView viewWithTag:10];
    [self buttonClick:btn];
}

- (void)formatEcharsArrayForIndex:(NSInteger)index{
    NSMutableArray * xArray = [[NSMutableArray alloc] init];
    NSMutableArray * yArray = [[NSMutableArray alloc] init];
    NSMutableArray * fromArray = [[NSMutableArray alloc] init];
    NSMutableArray * toArray= [[NSMutableArray alloc] init];
    NSInteger scopeType = 1;
    for (int i=0; i<self.dataArray.count; i++) {
        NSDictionary * dict = self.dataArray[i];
        NSDictionary * item = dict[@"nodeVo"];
        scopeType = [dict[@"scopeType"] integerValue];
        [xArray addObject:[NSString stringWithFormat:@"%@",dict[@"nodeName"]]];
        if (index == 0) {
            if (scopeType == 1) {
                [yArray addObject:[NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@",item[@"gridPower"]]]];
            }else{
                [fromArray addObject:[NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@",item[@"gridElectricityFrom"]]]];
                [toArray addObject:[NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@",item[@"gridElectricityTo"]]]];
            }
        }else if (index == 1) {
            [yArray addObject:[NSString stringWithFormat:@"%@",scopeType == 1 ? item[@"solarPower"] : item[@"solarElectricity"]]];
        }else if (index == 2) {
            [yArray addObject:[NSString stringWithFormat:@"%@",scopeType == 1 ? item[@"generatorPower"] : item[@"generatorElectricity"]]];
        }else if (index == 3) {
            [yArray addObject:[NSString stringWithFormat:@"%@",scopeType == 1 ? item[@"evPower"] : item[@"evElectricity"]]];
        }else if (index == 4) {
            if (self.backUpType.intValue == 1) {
                [yArray addObject:[NSString stringWithFormat:@"%@",scopeType == 1 ? item[@"backUpPower"] : item[@"backUpElectricity"]]];
            }else{
                [yArray addObject:[NSString stringWithFormat:@"%@",scopeType == 1 ? item[@"nonBackUpPower"] : item[@"nonBackUpElectricity"]]];
            }
        }else if (index == 5) {
            [yArray addObject:[NSString stringWithFormat:@"%@",scopeType == 1 ? item[@"backUpPower"] : item[@"backUpElectricity"]]];
        }
    }
//    xArray = @[@"1",@"2",@"3",@"4",@"5",@"6"];
//    yArray = @[@"-0.0",@"-0.0",@"-0.0",@"-0.0",@"-0.0",@"-10.6"];
    if (scopeType == 0) {
        self.lineEchartsView.hidden = true;
        self.barEchartsView.hidden = false;
        if (self.selectFlag == 0) {
            double dataSetMax = 0;
            double dataSetMin = 0;
            NSArray * datas = @[fromArray,toArray];
            NSMutableArray<BarChartDataSet*> *dataSets = [[NSMutableArray alloc] init];
            for (int i = 0; i < datas.count; i++) {
                NSMutableArray<BarChartDataEntry*> *yValues = [[NSMutableArray alloc] init];
                NSArray * data = datas[i];
                for (int j=0; j<data.count; j++) {
                    dataSetMax = MAX([data[j] doubleValue], dataSetMax);
                    dataSetMin = MIN([data[j] doubleValue], dataSetMin);
                    BarChartDataEntry * entry = [[BarChartDataEntry alloc] initWithX:j y:[data[j] doubleValue]];
                    [yValues addObject:entry];
                }

                BarChartDataSet * set = [[BarChartDataSet alloc] initWithEntries:yValues label:[NSString stringWithFormat:@"第%d个图例",i]];
                [set setColors:@[[UIColor colorWithHexString:i == 0 ? @"#F7B500" : COLOR_MAIN_COLOR]]];
                set.valueColors = @[UIColor.clearColor];
                set.highlightColor = UIColor.clearColor;
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                ChartDefaultValueFormatter *formatter = [[ChartDefaultValueFormatter alloc] initWithFormatter:numberFormatter];
                [set setValueFormatter:formatter];
                [dataSets addObject:set];
            }
            if (dataSetMin == dataSetMax) {
                dataSetMin = 0;
                dataSetMax = 1.4;
            }else{
                dataSetMax = dataSetMax <= 0 ? 0 : dataSetMax + (fabs(dataSetMax) + fabs(dataSetMin)) * 0.4;
                dataSetMin = dataSetMin >= 0 ? 0 : dataSetMin - (fabs(dataSetMax) + fabs(dataSetMin)) * 0.4;
            }
            self.barEchartsView.leftAxis.axisMaximum = dataSetMax;
            self.barEchartsView.leftAxis.axisMinimum = dataSetMin;
            BarChartData * data = [[BarChartData alloc] initWithDataSets:dataSets];
            data.barWidth = 0.4;
            [data groupBarsFromX:-0.5 groupSpace:0.12 barSpace:0.04];
            self.barEchartsView.xAxis.valueFormatter = [[ChartIndexAxisValueFormatter alloc] initWithValues:xArray];
            self.barEchartsView.data = xArray.count == 0 ? nil : data;
            [self.barEchartsView setScaleMinima:1 scaleY:0];
            [self.barEchartsView setVisibleXRangeMinimum:6];
            [self.barEchartsView notifyDataSetChanged];
            [self.barEchartsView.data notifyDataChanged];
        }else{
            double dataSetMax = 0;
            double dataSetMin = 0;
            NSMutableArray *array = [NSMutableArray array];
            for (int i = 0; i < xArray.count; i++) {
                dataSetMax = MAX([yArray[i] doubleValue], dataSetMax);
                dataSetMin = MIN([yArray[i] doubleValue], dataSetMin);
                BarChartDataEntry *entry = [[BarChartDataEntry alloc] initWithX:i y:[yArray[i] doubleValue]];
                [array addObject:entry];
            }
            //set
            BarChartDataSet *set = [[BarChartDataSet alloc] initWithEntries:array label:@""];
            [set setColors:@[[UIColor colorWithHexString:@"#F7B500"]]];
            //显示柱图值并格式化
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            ChartDefaultValueFormatter *formatter = [[ChartDefaultValueFormatter alloc] initWithFormatter:numberFormatter];
            [set setValueFormatter:formatter];
            set.highlightColor = UIColor.clearColor;
            self.barEchartsView.xAxis.valueFormatter = [[ChartIndexAxisValueFormatter alloc] initWithValues:xArray];
            if (dataSetMin == dataSetMax) {
                dataSetMin = 0;
                dataSetMax = 1.4;
            }else{
                dataSetMax = dataSetMax <= 0 ? 0 : dataSetMax + (fabs(dataSetMax) + fabs(dataSetMin)) * 0.4;
                dataSetMin = dataSetMin >= 0 ? 0 : dataSetMin - (fabs(dataSetMax) + fabs(dataSetMin)) * 0.4;
            }
            NSLog(@"dataSetMax=%f,%f",dataSetMax,dataSetMin);
            self.barEchartsView.leftAxis.axisMaximum = dataSetMax;
            self.barEchartsView.leftAxis.axisMinimum = dataSetMin;
            BarChartData *data = [[BarChartData alloc] initWithDataSet:set];
            self.barEchartsView.data = xArray.count == 0 ? nil : data;
            [self.barEchartsView setScaleMinima:1 scaleY:0];
            [self.barEchartsView setVisibleXRangeMinimum:6];
            [self.barEchartsView notifyDataSetChanged];
            [self.barEchartsView.data notifyDataChanged];
        }
    }else{
        self.lineEchartsView.hidden = false;
        self.barEchartsView.hidden = true;
        double dataSetMax = 0;
        double dataSetMin = 0;
        if (scopeType == 1 || (scopeType != 1 && self.selectFlag != 0)) {
            self.lineEchartsView.xAxis.valueFormatter = [[ChartIndexAxisValueFormatter alloc] initWithValues:xArray];
            NSMutableArray<ChartDataEntry*> * array = [[NSMutableArray alloc] init];
            for (int i=0; i<yArray.count; i++) {
                double index = (double)i;
                double value = [yArray[i] doubleValue];
                dataSetMax = MAX(value, dataSetMax);
                dataSetMin = MIN(value, dataSetMin);
                ChartDataEntry * entry = [[ChartDataEntry alloc] initWithX:index y:value];
                [array addObject:entry];
            }
            LineChartDataSet * set = [[LineChartDataSet alloc] initWithEntries:array label:@""];
            set.axisDependency = AxisDependencyLeft;
            set.valueTextColor = UIColor.clearColor;
            set.lineWidth = 1;
            set.circleRadius = 0;
            set.circleHoleRadius = 0;
            set.cubicIntensity = 0.2;
            set.drawFilledEnabled = true;
            set.fillColor = [UIColor colorWithHexString:@"#F7B500"];
            set.fillAlpha = 0.3;
            [set setColor:[UIColor colorWithHexString:@"#F7B500"]];
            set.mode = LineChartModeHorizontalBezier;
            set.drawValuesEnabled = true;
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            ChartDefaultValueFormatter *formatter = [[ChartDefaultValueFormatter alloc] initWithFormatter:numberFormatter];
            [set setValueFormatter:formatter];
            if (dataSetMin == dataSetMax) {
                dataSetMin = 0;
                dataSetMax = 1.4;
            }else{
                dataSetMax = dataSetMax <= 0 ? 0 : dataSetMax + (fabs(dataSetMax) + fabs(dataSetMin)) * 0.4;
                dataSetMin = dataSetMin >= 0 ? 0 : dataSetMin - (fabs(dataSetMax) + fabs(dataSetMin)) * 0.4;
            }
            self.lineEchartsView.leftAxis.axisMaximum = dataSetMax;
            self.lineEchartsView.leftAxis.axisMinimum = dataSetMin;
            LineChartData *data = [[LineChartData alloc] initWithDataSets:@[set]];
            self.lineEchartsView.data = xArray.count == 0 ? nil : data;
            [self.lineEchartsView notifyDataSetChanged];
            [self.lineEchartsView.data notifyDataChanged];
        }else{
            self.lineEchartsView.xAxis.valueFormatter = [[ChartIndexAxisValueFormatter alloc] initWithValues:xArray];
            NSArray * datas = @[fromArray,toArray];
            NSMutableArray * sets = [[NSMutableArray alloc] init];
            for (int i=0; i<datas.count; i++) {
                NSArray * data = datas[i];
                NSMutableArray<ChartDataEntry*> * array = [[NSMutableArray alloc] init];
                for (int j=0; j<data.count; j++) {
                    double index = (double)j;
                    double value = [data[j] doubleValue];
                    dataSetMax = MAX(value, dataSetMax);
                    dataSetMin = MIN(value, dataSetMin);
                    ChartDataEntry * entry = [[ChartDataEntry alloc] initWithX:index y:value];
                    [array addObject:entry];
                }
                LineChartDataSet * set = [[LineChartDataSet alloc] initWithEntries:array label:@""];
                set.axisDependency = AxisDependencyLeft;
                set.valueTextColor = UIColor.clearColor;
                set.lineWidth = 2;
                set.circleRadius = 0;
                set.circleHoleRadius = 0;
                set.cubicIntensity = 0.2;
                set.drawFilledEnabled = true;
                set.fillColor = [UIColor colorWithHexString:i==0?@"#F7B500":COLOR_MAIN_COLOR];
                set.fillAlpha = 0.3;
                [set setColor:[UIColor colorWithHexString:i==0?@"#F7B500":COLOR_MAIN_COLOR]];
                set.mode = LineChartModeHorizontalBezier;
                set.drawValuesEnabled = true;
                [sets addObject:set];
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                ChartDefaultValueFormatter *formatter = [[ChartDefaultValueFormatter alloc] initWithFormatter:numberFormatter];
                [set setValueFormatter:formatter];
            }
            if (dataSetMin == dataSetMax) {
                dataSetMin = 0;
                dataSetMax = 1.4;
            }else{
                dataSetMax = dataSetMax <= 0 ? 0 : dataSetMax + (fabs(dataSetMax) + fabs(dataSetMin)) * 0.4;
                dataSetMin = dataSetMin >= 0 ? 0 : dataSetMin - (fabs(dataSetMax) + fabs(dataSetMin)) * 0.4;
            }
            self.lineEchartsView.leftAxis.axisMaximum = dataSetMax;
            self.lineEchartsView.leftAxis.axisMinimum = dataSetMin;
            LineChartData *data = [[LineChartData alloc] initWithDataSets:sets];
            self.lineEchartsView.data = xArray.count == 0 ? nil : data;
            [self.lineEchartsView notifyDataSetChanged];
            [self.lineEchartsView.data notifyDataChanged];
        }
    }
}

- (void)buttonClick:(UIButton *)btn{
    if (btn.selected){
        if (btn.tag == 10 && self.selectTitleArray.count == 2 && self.scopeType != 1){
            return;
        }
        if (self.selectTitleArray.count == 1){
            return;
        }
    }
    btn.selected = !btn.selected;
    if (self.datas.count == 0){
        return;
    }
    [self.selectArray removeAllObjects];
    [self.selectTitleArray removeAllObjects];
    [self.selectColorArray removeAllObjects];
    
    for (int i=0;i<self.normal.count;i++) {
        UIButton * button = [self.titleView viewWithTag:i+10];
        if (button.selected == true){
            if (button.tag == 10){
                if (self.scopeType == 1) {
                    [self.selectArray addObject:self.datas[i]];
                    [self.selectTitleArray addObjectsFromArray:@[@"Gird"]];
                    [self.selectColorArray addObjectsFromArray:@[@"#0075ff"]];
                }else{
                    [self.selectArray addObjectsFromArray:self.datas[i]];
                    [self.selectTitleArray addObjectsFromArray:@[@"From Gird",@"To Gird"]];
                    [self.selectColorArray addObjectsFromArray:@[@"#0075ff",@"#ff9f69"]];
                }
            }else if (button.tag == 11) {
                [self.selectTitleArray addObject:self.titleArray[i]];
                [self.selectColorArray addObject:@"#5cc49f"];
                [self.selectArray addObject:self.datas[i]];
            }else if (button.tag == 12) {
                [self.selectTitleArray addObject:self.titleArray[i]];
                [self.selectColorArray addObject:@"#6c47ff"];
                [self.selectArray addObject:self.datas[i]];
            }else if (button.tag == 13) {
                [self.selectTitleArray addObject:self.titleArray[i]];
                [self.selectColorArray addObject:@"#cf5195"];
                [self.selectArray addObject:self.datas[i]];
            }else if (button.tag == 14) {
                [self.selectTitleArray addObject:self.titleArray[i]];
                if (self.backUpType.intValue == 1) {
                    [self.selectColorArray addObject:@"#ab1500"];
                }else{
                    [self.selectColorArray addObject:@"#fe5a5a"];
                }
                [self.selectArray addObject:self.datas[i]];
            }else if (button.tag == 15) {
                [self.selectTitleArray addObject:self.titleArray[i]];
                [self.selectColorArray addObject:@"#ab1500"];
                [self.selectArray addObject:self.datas[i]];
            }
        }
    }
    ((BalloonMarker *)self.lineEchartsView.marker).textArray = self.selectTitleArray;
    ((BalloonMarker *)self.lineEchartsView.marker).colorArray = self.selectColorArray;
    ((XYMarkerView *)self.barEchartsView.marker).textArray = self.selectTitleArray;
    ((XYMarkerView *)self.barEchartsView.marker).colorArray = self.selectColorArray;
    [self loadChartsData];
}

- (void)loadChartsData{
    if (self.scopeType == 0){
        self.lineEchartsView.hidden = true;
        self.barEchartsView.hidden = false;
        double dataSetMax = 0;
        double dataSetMin = 0;
        NSArray * datas = self.selectArray;
        NSMutableArray<BarChartDataSet*> *dataSets = [[NSMutableArray alloc] init];
        for (int i = 0; i < datas.count; i++) {
            NSMutableArray<BarChartDataEntry*> *yValues = [[NSMutableArray alloc] init];
            NSArray * data = datas[i];
            for (int j=0; j<data.count; j++) {
                dataSetMax = MAX([data[j] doubleValue], dataSetMax);
                dataSetMin = MIN([data[j] doubleValue], dataSetMin);
                BarChartDataEntry * entry = [[BarChartDataEntry alloc] initWithX:j y:[data[j] doubleValue]];
                [yValues addObject:entry];
            }

            BarChartDataSet * set = [[BarChartDataSet alloc] initWithEntries:yValues label:self.selectTitleArray[i]];
            [set setColors:@[[UIColor colorWithHexString:self.selectColorArray[i]]]];
            set.valueColors = @[UIColor.clearColor];
            set.highlightColor = UIColor.clearColor;
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            ChartDefaultValueFormatter *formatter = [[ChartDefaultValueFormatter alloc] initWithFormatter:numberFormatter];
            [set setValueFormatter:formatter];
            [dataSets addObject:set];
        }
        if (dataSetMin == dataSetMax) {
            dataSetMin = 0;
            dataSetMax = 1.4;
        }else{
            dataSetMax = dataSetMax <= 0 ? 0 : dataSetMax + (fabs(dataSetMax) + fabs(dataSetMin)) * 0.4;
            dataSetMin = dataSetMin >= 0 ? 0 : dataSetMin - (fabs(dataSetMax) + fabs(dataSetMin)) * 0.4;
        }
        self.barEchartsView.leftAxis.axisMaximum = dataSetMax;
        self.barEchartsView.leftAxis.axisMinimum = dataSetMin;
        BarChartData * data = [[BarChartData alloc] initWithDataSets:dataSets];
        data.barWidth = [self barWidth];
        [data groupBarsFromX:-0.5 groupSpace:0.12 barSpace:0.04];
        self.barEchartsView.xAxis.valueFormatter = [[ChartIndexAxisValueFormatter alloc] initWithValues:self.xArray];
        self.barEchartsView.data = self.xArray.count == 0 ? nil : data;
        [self.barEchartsView setScaleMinima:1 scaleY:0];
        [self.barEchartsView setVisibleXRangeMinimum:6];
        [self.barEchartsView notifyDataSetChanged];
        [self.barEchartsView.data notifyDataChanged];
    }else{
        self.lineEchartsView.hidden = false;
        self.barEchartsView.hidden = true;
        double dataSetMax = 0;
        double dataSetMin = 0;
        self.lineEchartsView.xAxis.valueFormatter = [[ChartIndexAxisValueFormatter alloc] initWithValues:self.xArray];
        NSArray * datas = self.selectArray;
        NSMutableArray * sets = [[NSMutableArray alloc] init];
        for (int i=0; i<datas.count; i++) {
            NSArray * data = datas[i];
            NSMutableArray<ChartDataEntry*> * array = [[NSMutableArray alloc] init];
            for (int j=0; j<data.count; j++) {
                double index = (double)j;
                double value = [data[j] doubleValue];
                dataSetMax = MAX(value, dataSetMax);
                dataSetMin = MIN(value, dataSetMin);
                ChartDataEntry * entry = [[ChartDataEntry alloc] initWithX:index y:value];
                [array addObject:entry];
            }
            LineChartDataSet * set = [[LineChartDataSet alloc] initWithEntries:array label:self.selectTitleArray[i]];
            set.axisDependency = AxisDependencyLeft;
            set.valueTextColor = UIColor.clearColor;
            set.lineWidth = 2;
            set.circleRadius = 0;
            set.circleHoleRadius = 0;
            set.cubicIntensity = 0.2;
            set.drawFilledEnabled = true;
            set.fillColor = [UIColor colorWithHexString:self.selectColorArray[i]];
            set.fillAlpha = 0.3;
            [set setColor:[UIColor colorWithHexString:self.selectColorArray[i]]];
            set.mode = LineChartModeHorizontalBezier;
            set.drawValuesEnabled = true;
            [sets addObject:set];
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            ChartDefaultValueFormatter *formatter = [[ChartDefaultValueFormatter alloc] initWithFormatter:numberFormatter];
            [set setValueFormatter:formatter];
        }
        if (dataSetMin == dataSetMax) {
            dataSetMin = 0;
            dataSetMax = 1.4;
        }else{
            dataSetMax = dataSetMax <= 0 ? 0 : dataSetMax + (fabs(dataSetMax) + fabs(dataSetMin)) * 0.4;
            dataSetMin = dataSetMin >= 0 ? 0 : dataSetMin - (fabs(dataSetMax) + fabs(dataSetMin)) * 0.4;
        }
        self.lineEchartsView.leftAxis.axisMaximum = dataSetMax;
        self.lineEchartsView.leftAxis.axisMinimum = dataSetMin;
        LineChartData *data = [[LineChartData alloc] initWithDataSets:sets];
        self.lineEchartsView.data = self.xArray.count == 0 ? nil : data;
        [self.lineEchartsView notifyDataSetChanged];
        [self.lineEchartsView.data notifyDataChanged];
    }
}

- (double)barWidth{
    double width = 0.4;
    if (self.selectArray.count == 1){
        width = 0.8;
    }else if (self.selectArray.count == 2){
        width = 0.4;
    }else if (self.selectArray.count == 3){
        width = 0.254;
    }else if (self.selectArray.count == 4){
        width = 0.181;
    }else if (self.selectArray.count == 5){
        width = 0.137;
    }else if (self.selectArray.count == 6){
        width = 0.107;
    }else if (self.selectArray.count == 7){
        width = 0.1;
    }
    return width;
}

@end
