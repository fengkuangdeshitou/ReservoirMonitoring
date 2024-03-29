//
//  BalloonMarker.swift
//  ChartsDemo
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import Charts
#if canImport(UIKit)
    import UIKit
#endif

open class BalloonMarker: MarkerImage
{
    @objc open var color: UIColor
    @objc open var arrowSize = CGSize(width: 15, height: 11)
    @objc open var font: UIFont
    @objc open var textColor: UIColor
    @objc open var insets: UIEdgeInsets
    @objc open var minimumSize = CGSize()
    @objc open var scopeType:NSInteger = 1
    @objc open var colorArray:[String] = []
    @objc open var textArray:[String] = []

    fileprivate var label: String?
    fileprivate var _labelSize: CGSize = CGSize()
    fileprivate var _paragraphStyle: NSMutableParagraphStyle?
    fileprivate var _drawAttributes = [NSAttributedString.Key : Any]()
    
    @objc public init(color: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets , scopeType:Int)
    {
        self.color = color
        self.font = font
        self.textColor = textColor
        self.insets = insets
        self.scopeType = scopeType
        
        _paragraphStyle = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
        _paragraphStyle?.alignment = .left
        super.init()
    }
    
    open override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint
    {
        var offset = self.offset
        var size = self.size

        if size.width == 0.0 && image != nil
        {
            size.width = image!.size.width
        }
        if size.height == 0.0 && image != nil
        {
            size.height = image!.size.height
        }

        let width = size.width
        let height = size.height
        let padding: CGFloat = 8.0

        var origin = point
        origin.x -= width / 2
        origin.y -= height

        if origin.x + offset.x < 0.0
        {
            offset.x = -origin.x + padding
        }
        else if let chart = chartView,
            origin.x + width + offset.x > chart.bounds.size.width
        {
            offset.x = chart.bounds.size.width - origin.x - width - padding
        }

        if origin.y + offset.y < 0
        {
            offset.y = height + padding;
        }
        else if let chart = chartView,
            origin.y + height + offset.y > chart.bounds.size.height
        {
            offset.y = chart.bounds.size.height - origin.y - height - padding
        }

        return offset
    }
    
    open override func draw(context: CGContext, point: CGPoint)
    {
        guard let label = label else { return }
        
        let offset = self.offsetForDrawing(atPoint: point)
        let size = self.size
        
        var rect = CGRect(
            origin: CGPoint(
                x: point.x + offset.x,
                y: point.y + offset.y),
            size: size)
        rect.origin.x -= size.width / 2.0
        rect.origin.y -= size.height
        
        context.saveGState()

        context.setFillColor(color.cgColor)

        if offset.y > 0
        {
//            context.beginPath()
//            let path = UIBezierPath(roundedRect: rect, cornerRadius: 6)
//            context.addPath(path.cgPath)
//            context.move(to: CGPoint(
//                x: rect.origin.x,
//                y: rect.origin.y + arrowSize.height))
//            context.addLine(to: CGPoint(
//                x: rect.origin.x + (rect.size.width - arrowSize.width) / 2.0,
//                y: rect.origin.y + arrowSize.height))
//            //arrow vertex
//            context.addLine(to: CGPoint(
//                x: point.x,
//                y: point.y))
//            context.addLine(to: CGPoint(
//                x: rect.origin.x + (rect.size.width + arrowSize.width) / 2.0,
//                y: rect.origin.y + arrowSize.height))
//            context.addLine(to: CGPoint(
//                x: rect.origin.x + rect.size.width,
//                y: rect.origin.y + arrowSize.height))
//            context.addLine(to: CGPoint(
//                x: rect.origin.x + rect.size.width,
//                y: rect.origin.y + rect.size.height))
//            context.addLine(to: CGPoint(
//                x: rect.origin.x,
//                y: rect.origin.y + rect.size.height))
//            context.addLine(to: CGPoint(
//                x: rect.origin.x,
//                y: rect.origin.y + arrowSize.height))
//            context.fillPath()
        }
        else
        {
//            context.beginPath()
//            let path = UIBezierPath(roundedRect: rect, cornerRadius: 6)
//            context.addPath(path.cgPath)
//            context.move(to: CGPoint(
//                x: rect.origin.x,
//                y: rect.origin.y))
//            context.addLine(to: CGPoint(
//                x: rect.origin.x + rect.size.width,
//                y: rect.origin.y))
//            context.addLine(to: CGPoint(
//                x: rect.origin.x + rect.size.width,
//                y: rect.origin.y + rect.size.height - arrowSize.height))
//            context.addLine(to: CGPoint(
//                x: rect.origin.x + (rect.size.width + arrowSize.width) / 2.0,
//                y: rect.origin.y + rect.size.height - arrowSize.height))
//            //arrow vertex
//            context.addLine(to: CGPoint(
//                x: point.x,
//                y: point.y))
//            context.addLine(to: CGPoint(
//                x: rect.origin.x + (rect.size.width - arrowSize.width) / 2.0,
//                y: rect.origin.y + rect.size.height - arrowSize.height))
//            context.addLine(to: CGPoint(
//                x: rect.origin.x,
//                y: rect.origin.y + rect.size.height - arrowSize.height))
//            context.addLine(to: CGPoint(
//                x: rect.origin.x,
//                y: rect.origin.y))
//            context.fillPath()
        }
        
        if offset.y > 0 {
            rect.origin.y += self.insets.top + arrowSize.height
        } else {
            rect.origin.y += self.insets.top
        }
        
        rect.size.height -= self.insets.top + self.insets.bottom
        
        if (rect.origin.y + rect.size.height > (chartView?.frame.size.height)!){
            rect.origin.y = (chartView?.frame.size.height)! - rect.size.height - 40
        }

        context.beginPath()
        let path = UIBezierPath(roundedRect: CGRect(x: rect.origin.x, y: rect.origin.y-10, width: rect.size.width, height: rect.size.height+20), cornerRadius: 6)
        context.addPath(path.cgPath)
        context.fillPath()
        
        UIGraphicsPushContext(context)
        
        label.draw(in: rect, withAttributes: _drawAttributes)
        
        UIGraphicsPopContext()
        
        context.restoreGState()
        
        for (index,value) in colorArray.enumerated() {
            let bezierPath = UIBezierPath(ovalIn: CGRect(x: rect.origin.x + 8, y: rect.origin.y + 18.5 + CGFloat(Double(index)*14.5), width: 6, height: 6))
            UIColor(hexString: value) .setFill()
            bezierPath.fill()
        }
        
    }
    
    open override func refreshContent(entry: ChartDataEntry, highlight: Highlight)
    {
        let formatter = self.chartView?.xAxis.valueFormatter as! IndexAxisValueFormatter
        let time = formatter.stringForValue(entry.x, axis: self.chartView?.xAxis)
        let key = self.scopeType == 1 ? "Time：" : self.scopeType == 2 ? "Day：" : "Month：";
        var text = "      \(key)" + time + "\n"

        if self.scopeType == 1 {
            for (idx,value) in textArray.enumerated(){
                guard let dataSet = self.chartView?.data?.dataSets[idx] as? LineChartDataSet else { return }
                guard let entries = dataSet.entriesForXValue(entry.x).first else { return }
                text += ("      " + value + "：" + String(format:"%.2f",entries.y) + "kW")
                if (idx != textArray.count - 1) {
                    text += "\n"
                }
            }
            setLabel(text)
        }else{
            for (idx,value) in textArray.enumerated(){
                guard let dataSet = self.chartView?.data?.dataSets[idx] as? LineChartDataSet else { return }
                guard let entries = dataSet.entriesForXValue(entry.x).first else { return }
                text += ("      " + value + "：" + String(format:"%.2f",entries.y) + "kWh")
                if (idx != textArray.count - 1) {
                    text += "\n"
                }
            }
            setLabel(text)
//            setLabel(String("      \(key)" + time + "\n" + "      Data:" + String(format:"%.2f",entry.y) + "kWh"))
        }
    }
    
    @objc open func setLabel(_ newLabel: String)
    {
        label = newLabel
        
        _drawAttributes.removeAll()
        _drawAttributes[.font] = self.font
        _drawAttributes[.paragraphStyle] = _paragraphStyle
        _drawAttributes[.foregroundColor] = self.textColor
        
        _labelSize = label?.size(withAttributes: _drawAttributes) ?? CGSize.zero
        
        var size = CGSize()
        size.width = _labelSize.width + self.insets.left + self.insets.right
        size.height = _labelSize.height + self.insets.top + self.insets.bottom
        size.width = max(minimumSize.width, size.width)
        size.height = max(minimumSize.height, size.height)
        self.size = size
    }
}
