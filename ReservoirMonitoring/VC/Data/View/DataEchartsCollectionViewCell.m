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

@property(nonatomic,weak)IBOutlet UIView * titleView;
@property(nonatomic,weak)IBOutlet UIView * echarts;
@property(nonatomic,weak)IBOutlet UILabel * energyTitle;

@property(nonatomic,weak)IBOutlet UILabel * independence;
@property(nonatomic,weak)IBOutlet UILabel * power;
@property(nonatomic,weak)IBOutlet UILabel * reducing;
@property(nonatomic,weak)IBOutlet UILabel * trees;
@property(nonatomic,weak)IBOutlet UILabel * coal;
@property(nonatomic,weak)IBOutlet UIView * toGridView;

@property(nonatomic,weak)IBOutlet UILabel * current;
@property(nonatomic,strong) NSArray * titleArray;
@property(nonatomic,strong) NSArray * normal;
@property(nonatomic,strong) NSArray * highlight;
@property(nonatomic,strong) BalloonMarker *marker;
@property(nonatomic,assign) NSInteger selectFlag;

@end

@implementation DataEchartsCollectionViewCell

- (IBAction)timeAction:(id)sender{
    if (self.time == 0) {
        [GlobelDescAlertView showAlertViewWithTitle:@"Description".localized desc:@"Self reliable rating = (battery energy consumption/ total energy consumption ) %, daily rating stands for the performance of last 24h" btnTitle:nil completion:nil];
    }else if (self.time == 1){
        [GlobelDescAlertView showAlertViewWithTitle:@"Description".localized desc:@"Self reliable rating = (battery energy consumption/ total energy consumption ) %, monthly rating stands for the performance of last month." btnTitle:nil completion:nil];
    }else if (self.time == 2){
        [GlobelDescAlertView showAlertViewWithTitle:@"Description".localized desc:@"Self reliable rating = (battery energy consumption/ total energy consumption ) %, annual rating stands for the performance of last year." btnTitle:nil completion:nil];
    }else{
        [GlobelDescAlertView showAlertViewWithTitle:@"Description".localized desc:@"Self reliable rating = (battery energy consumption/ total energy consumption ) %, total rating stands for the performance since installation." btnTitle:nil completion:nil];
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
        _lineEchartsView.legend.enabled = false;
        [_lineEchartsView animateWithXAxisDuration:1];
        [_lineEchartsView setExtraOffsetsWithLeft:10 top:0 right:10 bottom:0];
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
        xAxis.avoidFirstLastClippingEnabled = true;
        
        ChartYAxis *leftAxis = _lineEchartsView.leftAxis;// 获取左边 Y 轴
        leftAxis.inverted = NO; // 是否将 Y 轴进行上下翻转
        leftAxis.axisLineWidth = 0;// 设置 Y 轴线宽
        leftAxis.axisLineColor = [UIColor colorWithHexString:@"#999999"];// 设置 Y 轴颜色
        leftAxis.labelPosition = YAxisLabelPositionOutsideChart;// label 文字位置 YAxisLabelPositionInsideChart:在里面，YAxisLabelPositionOutsideChart:在外面
        leftAxis.labelTextColor = [UIColor whiteColor]; // label 文字颜色
        leftAxis.labelFont = [UIFont systemFontOfSize:10.0f]; // 不强制绘制指定数量的 label
        leftAxis.forceLabelsEnabled = NO; // 不强制绘制指定数量的 label
        leftAxis.gridAntialiasEnabled = YES;// 网格线开启抗锯齿
        _lineEchartsView.chartDescription.enabled = NO;// 设置折线图描述
        _lineEchartsView.legend.enabled = NO; // 设置折线图图例
    //    ChartLimitLine *line = [[ChartLimitLine alloc] initWithLimit:150.0 label:@"Upper Limit"];
    //    line.lineWidth = 4.0;
    //    line.lineDashLengths = @[@5.f, @5.f];
    //    line.labelPosition = ChartLimitLabelPositionTopRight;
    //    line.valueFont = [UIFont systemFontOfSize:10.0];
        
    //    ChartYAxis *leftAxis = self.echartsView.leftAxis;
    //    [leftAxis removeAllLimitLines];
    //    [leftAxis addLimitLine:line];
    //    leftAxis.axisMaximum = 200.0;
    //    leftAxis.axisMinimum = -50.0;
    //    leftAxis.gridLineDashLengths = @[@5.f, @5.f];
    //    leftAxis.drawZeroLineEnabled = false;
    //    leftAxis.drawLabelsEnabled = false;
    //    leftAxis.drawLimitLinesBehindDataEnabled = false;
        
        _lineEchartsView.rightAxis.enabled = false;
        
        self.marker = [[BalloonMarker alloc]
                                 initWithColor:[UIColor colorWithHexString:COLOR_MAIN_COLOR]
                                 font:[UIFont systemFontOfSize:12.0]
                                 textColor:UIColor.whiteColor
                                 insets:UIEdgeInsetsMake(8.0, 8.0, 8.0, 0.0)
                                 scopeType:self.scopeType];
        self.marker.chartView = _lineEchartsView;
        self.marker.arrowSize = CGSizeMake(0, 0);
        _lineEchartsView.marker = self.marker;
        _lineEchartsView.legend.form = ChartLegendFormLine;
        [_lineEchartsView setScaleMinima:1 scaleY:1];
    }
    return _lineEchartsView;
}

- (void)setScopeType:(NSInteger)scopeType{
    _scopeType = scopeType;
    self.marker.scopeType = scopeType;
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
        _barEchartsView.legend.enabled = false;
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
                                      initWithColor: [UIColor clearColor]
                                      font: [UIFont systemFontOfSize:12.0]
                                      textColor: UIColor.whiteColor
                                      insets: UIEdgeInsetsMake(0, 0, 10, 0)
                                      ];
        marker.chartView = _barEchartsView;
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
    self.titleArray = @[@"Grid".localized,@"Solar".localized,@"Generator".localized,@"EV",@"Non-backup".localized,@"Backup loads".localized];
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
        button.imageView.contentMode = UIViewContentModeScaleAspectFit;
        button.tag = i+10;
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.titleView addSubview:button];
    }
    [self buttonClick:[self viewWithTag:10]];
    
    [self.echarts addSubview:self.lineEchartsView];
    [self.echarts addSubview:self.barEchartsView];
}

- (void)setBackUpType:(NSString *)backUpType{
    _backUpType = backUpType;
    if (backUpType.intValue == 1) {
        for (UIView * view in self.titleView.subviews) {
            if ([view isKindOfClass:[UIButton class]]) {
                [view removeFromSuperview];
            }
        }
        self.titleArray = @[@"Grid".localized,@"Solar".localized,@"Generator".localized,@"EV",@"Backup loads".localized];
        self.normal = @[@"data_normal_0",@"data_normal_1",@"data_normal_2",@"data_normal_3",@"data_normal_5"];
        self.highlight = @[@"data_select_0",@"data_select_1",@"data_select_2",@"data_select_3",@"data_select_5"];
        CGFloat width = (SCREEN_WIDTH-30)/self.normal.count;
        for (int i=0; i<self.normal.count; i++) {
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake((width-0.5)*i, 3, width, 24);
            [button setImage:[UIImage imageNamed:self.normal[i]] forState:UIControlStateNormal];
            button.imageView.contentMode = UIViewContentModeScaleAspectFit;
            button.tag = i+10;
            [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.titleView addSubview:button];
        }
        [self buttonClick:[self viewWithTag:10]];
    }
}

- (void)setDataArray:(NSArray *)dataArray{
    _dataArray = dataArray;
    [self formatEcharsArrayForIndex:self.selectFlag];
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
            [yArray addObject:[NSString stringWithFormat:@"%@",scopeType == 1 ? item[@"nonBackUpPower"] : item[@"nonBackUpElectricity"]]];
        }else if (index == 5) {
            [yArray addObject:[NSString stringWithFormat:@"%@",scopeType == 1 ? item[@"backUpPower"] : item[@"backUpElectricity"]]];
        }
    }
//    self.xArray = @[@"1",@"2",@"3",@"4"];
//    self.yArray = @[@"33",@"29",@"58",@"30",];
    if (scopeType == 0) {
        self.lineEchartsView.hidden = true;
        self.barEchartsView.hidden = false;
        if (self.selectFlag == 0) {
            self.toGridView.hidden = false;
            self.current.text = @"From Gird";
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
            dataSetMin = dataSetMin >= 0 ? 0 : dataSetMin*2;
            dataSetMax = dataSetMax == 0 ? 1.4 : dataSetMax + (fabs(dataSetMax) + fabs(dataSetMin)) * 0.4;
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
            self.toGridView.hidden = true;
            self.current.text = self.titleArray[self.selectFlag];
            NSMutableArray *array = [NSMutableArray array];
            for (int i = 0; i < xArray.count; i++) {
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
            dataSetMin = dataSetMin >= 0 ? 0 : dataSetMin*2;
            dataSetMax = dataSetMax == 0 ? 1.4 : dataSetMax + (fabs(dataSetMax) + fabs(dataSetMin)) * 0.4;
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
            self.current.text = self.titleArray[self.selectFlag];
            self.toGridView.hidden = true;
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
            dataSetMin = dataSetMin >= 0 ? 0 : dataSetMin*2;
            dataSetMax = dataSetMax == 0 ? 1.4 : dataSetMax + (fabs(dataSetMax) + fabs(dataSetMin)) * 0.4;
            self.lineEchartsView.leftAxis.axisMaximum = dataSetMax;
            self.lineEchartsView.leftAxis.axisMinimum = dataSetMin;
            LineChartData *data = [[LineChartData alloc] initWithDataSets:@[set]];
            self.lineEchartsView.data = xArray.count == 0 ? nil : data;
            [self.lineEchartsView notifyDataSetChanged];
            [self.lineEchartsView.data notifyDataChanged];
        }else{
            self.toGridView.hidden = false;
            self.current.text = @"From Gird";
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
            }
            dataSetMin = dataSetMin >= 0 ? 0 : dataSetMin*2;
            dataSetMax = dataSetMax == 0 ? 1.4 : dataSetMax + (fabs(dataSetMax) + fabs(dataSetMin)) * 0.4;
            self.lineEchartsView.leftAxis.axisMaximum = dataSetMax;
            self.lineEchartsView.leftAxis.axisMinimum = dataSetMin;
            LineChartData *data = [[LineChartData alloc] initWithDataSets:sets];
            self.lineEchartsView.data = xArray.count == 0 ? nil : data;
            [self.lineEchartsView notifyDataSetChanged];
            [self.lineEchartsView.data notifyDataChanged];
        }
    }
}

//- (PYOption *)getRideDetailLineOptionWithTimeArray:(NSArray *)dataArray
//                                        valueArray:(NSArray *)valueArray
//                                         scopeType:(NSInteger)scopeType{
//    PYOption * option = [[PYOption alloc] init];
//    option.calculable = NO;
//    option.color = @[@"#F7B500"];
//    PYGrid * grid = [[PYGrid alloc] init];
//    grid.x = @(34);
//    grid.y = @(23);
//    grid.x2 = @(15);
//    grid.y2 = @(40);
//    option.grid = grid;
//    PYTooltip *tooltip = [[PYTooltip alloc] init];
//    //触发类型，默认数据触发
//    tooltip.trigger = PYTooltipTriggerItem;
//    //背景色
//    tooltip.backgroundColor = [[PYColor alloc] initWithColor:[UIColor colorWithHexString:@"#FEFFFF"]];
//    //竖线宽度
//    tooltip.axisPointer.lineStyle.width = @0;
//    //提示框,文字样式设置
//    tooltip.textStyle = [[PYTextStyle alloc] init];
//    tooltip.textStyle.fontSize = @12;
//    tooltip.textStyle.color = [[PYColor alloc] initWithColor:[UIColor colorWithHexString:@"#686B6D"]];
////    tooltip.formatter = @"(function(params){ var res = params[0].name; for (var i = 0, l = params.length; i < l; i++) {res += '<br/>' + params[i].seriesName + ' : ' + params[i].value;}; return res})";
//    tooltip.formatter = @"(function(params){ var res = params.value; return '<br/>' + 'Distance:' + res + 'km'})";
//    //添加到图标选择中
//    option.tooltip = tooltip;
//    PYAxis * xAxis = [[PYAxis alloc] init];
//    xAxis.type = PYAxisTypeCategory;
//    xAxis.boundaryGap = @(NO);
//    xAxis.splitLine.lineStyle.color = [[PYColor alloc] initWithColor:UIColor.clearColor];
//    xAxis.axisLine.lineStyle.color = [[PYColor alloc] initWithColor:UIColor.clearColor];
//    xAxis.data = [[NSMutableArray alloc] initWithArray:dataArray.count == 0 ? @[@1,@2,@3,@4,@5,@6,@7] : dataArray];
//    option.xAxis = [[NSMutableArray alloc] initWithObjects:xAxis, nil ];
//    PYAxis * yaxis = [[PYAxis alloc] init];
//    yaxis.type = PYAxisTypeValue;
//    yaxis.splitNumber = @6;
//    yaxis.splitArea.areaStyle.color = [[PYColor alloc] initWithColor:UIColor.clearColor];
//    yaxis.axisLine.lineStyle.color = [[PYColor alloc] initWithColor:UIColor.clearColor];
//    yaxis.splitLine.lineStyle.color = [[PYColor alloc] initWithColor:[UIColor colorWithHexString:@"#333333"]];
//    option.yAxis = [[NSMutableArray alloc] initWithObjects:yaxis, nil];
//    NSMutableArray * seriesArray = [[NSMutableArray alloc] init];
//    PYCartesianSeries * series = [[PYCartesianSeries alloc] init];
//    if (scopeType == 0) {
//        series.type = PYSeriesTypeBar;
//        series.barWidth = @10;
////        series.barCategoryGap = @"10";
//    }else{
//        series.type = PYSeriesTypeLine;
//        series.smooth = true;
//        series.symbolSize = @2;
//    }
//    PYItemStyle * style = [[PYItemStyle alloc] init];
//    PYItemStyleProp * prop = [[PYItemStyleProp alloc] init];
//    prop.borderColor = [PYColor colorWithHexString:COLOR_MAIN_COLOR];
//    style.normal = prop;
//    series.itemStyle = style;
//    series.data = valueArray.count == 0 ? @[@"-",@"-",@"-",@"-",@"-",@"-",@"-"] : valueArray;
//    [seriesArray addObject:series];
//    option.series = seriesArray;
    
    
    
//    PYOption * option = [[PYOption alloc] init];
//    //是否启用拖拽重计算特性，默认关闭
//    option.calculable = NO;
//    //折线颜色
//    option.color = @[COLOR_MAIN_COLOR];
//    //图标背景色
//    option.backgroundColor = [[PYColor alloc] initWithColor:[UIColor whiteColor]];
//
//    //提示框
//    PYTooltip *tooltip = [[PYTooltip alloc] init];
//    //触发类型，默认数据触发
//    tooltip.trigger = PYTooltipTriggerItem;
//    //背景色
//    tooltip.backgroundColor = [[PYColor alloc] initWithColor:[UIColor colorWithHexString:@"#FEFFFF"]];
//    //竖线宽度
//    tooltip.axisPointer.lineStyle.width = @0;
//    //提示框,文字样式设置
//    tooltip.textStyle = [[PYTextStyle alloc] init];
//    tooltip.textStyle.fontSize = @12;
//    tooltip.textStyle.color = [[PYColor alloc] initWithColor:[UIColor colorWithHexString:@"#686B6D"]];
////    tooltip.formatter = @"(function(params){ var res = params[0].name; for (var i = 0, l = params.length; i < l; i++) {res += '<br/>' + params[i].seriesName + ' : ' + params[i].value;}; return res})";
//    tooltip.formatter = @"(function(params){ var res = params.value; return '<br/>' + 'Distance:' + res + 'km'})";
//    //添加到图标选择中
//    option.tooltip = tooltip;
//
//    /* 直角坐标系内绘图网格 */
//    PYGrid * grid = [[PYGrid alloc] init];
//    /*
//        x:网格图左上角顶点距坐标系背景左侧的距离
//        y:网格图左上角顶点距坐标系背景上侧的距离
//        x2:网格图右下角顶点距坐标系背景右侧的距离
//        y2:网格图右下角距坐标系背景下侧的距离
//    */
//    grid.x = @(40);
//    grid.x2 = @(20);
//    grid.borderWidth = @(0);
//    //添加到图标选择中
//    option.grid = grid;
//
//    /* x轴设置 */
//    PYAxis * xAxis = [[PYAxis alloc] init];
//    //横轴默认为类目型(就是坐标系自己设置,坐标系中仅有这些指定类目坐标)
//    xAxis.type = PYAxisTypeCategory;
//    //起始和结束俩端空白
//    xAxis.boundaryGap = @(NO);
//    //分隔线
//    xAxis.splitArea.show = NO;
//    //分割线颜色
//    xAxis.splitLine.lineStyle.color = [[PYColor alloc] initWithColor:UIColor.clearColor];
//    //坐标轴线
//    xAxis.axisLine.show = YES;
//    //坐标轴线颜色
//    xAxis.axisLine.lineStyle.color = [[PYColor alloc] initWithColor:[UIColor colorWithHexString:@"#FF0000"]];
//    //X轴坐标数据
//    xAxis.data = [[NSMutableArray alloc] initWithArray:dataArray];
//    //坐标轴小标记
//    xAxis.axisTick = [[PYAxisTick alloc] init];
//    xAxis.axisTick.show = NO;
//    //添加到图标选择中
//    option.xAxis = [[NSMutableArray alloc] initWithObjects:xAxis, nil ];
//
//    /* Y轴设置 */
//    PYAxis *yAxis = [[PYAxis alloc] init];
//    //纵轴默认为数值型(就是坐标系统自动生成，坐标轴内包含数值区间内容全部坐标) ,改为@"category "会有问题
//    yAxis.type = PYAxisTypeValue;
//    //y轴分隔段数，默认不修改为5
//    yAxis.splitNumber = @5;
//    //起始和结束俩端空白
////    yAxis.boundaryGap = @(YES);
//    //分隔线
//    yAxis.splitArea.show = NO;
//    //坐标轴线
//    yAxis.axisLine.show = YES;
//    yAxis.axisLine.lineStyle.color = [[PYColor alloc] initWithColor:[UIColor colorWithHexString:@"#FF0000"]];
//    //分割线类型
////    yAxis.splitLine.lineStyle.type = @"dashed"; //'solid' | 'dotted' | 'dashed' 虚线类型
//    //单位设置
//    yAxis.axisLabel = [[PYAxisLabel alloc] init];
//    yAxis.axisLabel.formatter = @"{value}";
//    //添加到图标选择中
//    option.yAxis = [[NSMutableArray alloc] initWithObjects:yAxis, nil];
//
//    /* 定义坐标点数组 */
//    NSMutableArray *seriesArr = [NSMutableArray array];
//    /* 折线设置 */
//    PYCartesianSeries *series = [[PYCartesianSeries alloc] init];
//    series.name = @"Distance:";
//    //类型为折线
//    series.type = PYSeriesTypeLine;
//    series.symbol = PYSymbolEmptyCircle;
//    //坐标点大小
//    series.symbolSize = @4;
//    series.symbolRotate = @2;
//    //坐标点样式，设置连线的宽度
//    series.itemStyle = [[PYItemStyle alloc] init];
//    series.itemStyle.normal = [[PYItemStyleProp alloc] init];
//    series.itemStyle.normal.lineStyle = [[PYLineStyle alloc] init];
//    series.itemStyle.normal.lineStyle.width = @(5);
//    series.itemStyle.normal.lineStyle.color = [[PYColor alloc] initWithColor:[UIColor colorWithHexString:COLOR_MAIN_COLOR]];
//    series.itemStyle.normal.areaStyle = [[PYAreaStyle alloc] init];
//    series.itemStyle.normal.areaStyle.color = @"(function (){var zrColor = zrender.tool.color;return zrColor.getLinearGradient(0, 140, 0, 280,[[0, 'rgba(86,177,156,0.4)'],[1, 'rgba(255,255,255,0.1)']])})()";
//    //添加坐标点 y轴数据 (如果某一点无数据，可以传@"-",断开连线 如: @[@"1000",@"-", @"7571"])
//    series.data = valueArray;
//    [seriesArr addObject:series];
//    [option setSeries:seriesArr];
//    return option;
//}

- (void)buttonClick:(UIButton *)btn{
    self.selectFlag = btn.tag-10;
    for (int i=0;i<self.normal.count;i++) {
        UIButton * button = [self.titleView viewWithTag:i+10];
        button.backgroundColor = UIColor.clearColor;
        [button setImage:[UIImage imageNamed:self.normal[i]] forState:UIControlStateNormal];
    }
    [btn setImage:[UIImage imageNamed:self.highlight[self.selectFlag]] forState:UIControlStateNormal];
    self.current.text = self.titleArray[self.selectFlag];
    [self formatEcharsArrayForIndex:self.selectFlag];
}

@end
