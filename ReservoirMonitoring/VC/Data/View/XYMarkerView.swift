//
//  XYMarkerView.swift
//  ChartsDemo
//  Copyright © 2016 dcg. All rights reserved.
//

import Foundation
import Charts
#if canImport(UIKit)
    import UIKit
#endif

open class XYMarkerView: BalloonMarker
{
    fileprivate var yFormatter = NumberFormatter()
    
    @objc public init(color: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets)
    {
        super.init(color: color, font: font, textColor: textColor, insets: insets , scopeType: 0)
        yFormatter.minimumFractionDigits = 1
        yFormatter.maximumFractionDigits = 1
    }
    
    open override func refreshContent(entry: ChartDataEntry, highlight: Highlight)
    {
        let formatter = self.chartView?.xAxis.valueFormatter as! IndexAxisValueFormatter
        let time = formatter.stringForValue(entry.x, axis: self.chartView?.xAxis)
        let key = "Year："
        var text = "      \(key)" + time + "\n"

        for (idx,value) in textArray.enumerated(){
            guard let dataSet = self.chartView?.data?.dataSets[idx] as? BarChartDataSet else { return }
            guard let entries = dataSet.entriesForXValue(Double(time) ?? 0).first else { return }
            print(entries.y)
            text += ("      " + value + "：" + String(format:"%.2f",entries.y) + "kWh")
            if (idx != textArray.count - 1) {
                text += "\n"
            }
        }
//        setLabel(String(format:"%.2f",entry.y)+"kWh")

        setLabel(text)
    }
    
}
