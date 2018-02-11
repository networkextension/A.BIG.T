//
//  BarChatsCell.swift
//  Surf
//
//  Created by abigt on 2018/1/16.
//  Copyright © 2018年 A.BIG.T. All rights reserved.
//

import UIKit
import Charts
import XRuler
class BarChatsCell: UIView,ChartViewDelegate {
     @IBOutlet weak var chartView:Charts.BarChartView?
 
    override func awakeFromNib(){
        if let chartView = chartView {
            chartView.chartDescription?.enabled = false
            
            chartView.dragEnabled = true
            chartView.setScaleEnabled(true)
            chartView.pinchZoomEnabled = false
            
            // ChartYAxis *leftAxis = chartView.leftAxis;
            
            let xAxis = chartView.xAxis
            xAxis.labelPosition = .bottom
            
            chartView.rightAxis.enabled = false
            
            
            chartView.delegate = self
            
            chartView.drawBarShadowEnabled = false
            chartView.drawValueAboveBarEnabled = false
            
            chartView.maxVisibleCount = 60
            
            
            xAxis.labelPosition = .bottom
            xAxis.labelFont = .systemFont(ofSize: 10)
            xAxis.granularity = 1
            xAxis.labelCount = 7
            //xAxis.valueFormatter = DayAxisValueFormatter(chart: chartView)
            
            let leftAxisFormatter = NumberFormatter()
            leftAxisFormatter.minimumFractionDigits = 0
            leftAxisFormatter.maximumFractionDigits = 1
            leftAxisFormatter.negativeSuffix = " $"
            leftAxisFormatter.positiveSuffix = " $"
            
            let leftAxis = chartView.leftAxis
            leftAxis.labelFont = .systemFont(ofSize: 10)
            leftAxis.labelCount = 8
            leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
            leftAxis.labelPosition = .outsideChart
            leftAxis.spaceTop = 0.15
            leftAxis.axisMinimum = 0 // FIXME: HUH?? this replaces startAtZero = YES
            
            let rightAxis = chartView.rightAxis
            rightAxis.enabled = true
            rightAxis.labelFont = .systemFont(ofSize: 10)
            rightAxis.labelCount = 8
            rightAxis.valueFormatter = leftAxis.valueFormatter
            rightAxis.spaceTop = 0.15
            rightAxis.axisMinimum = 0
            
            let l = chartView.legend
            l.horizontalAlignment = .left
            l.verticalAlignment = .bottom
            l.orientation = .horizontal
            l.drawInside = false
            l.form = .circle
            l.formSize = 9
            l.font = UIFont(name: "HelveticaNeue-Light", size: 11)!
            l.xEntrySpace = 4
            //        chartView.legend = l
            
//            let marker = XYMarkerView(color: UIColor(white: 180/250, alpha: 1),
//                                      font: .systemFont(ofSize: 12),
//                                      textColor: .white,
//                                      insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8),
//                                      xAxisValueFormatter: chartView.xAxis.valueFormatter!)
//            marker.chartView = chartView
//            marker.minimumSize = CGSize(width: 80, height: 40)
//            chartView.marker = marker
            
        
           // slidersValueChanged(nil)
        }
    }
    func updateChartData() {
        
        
        self.setDataCount(60, range: UInt32(1000))
    }
    
    func setDataCount(_ count: Int, range: UInt32) {
        guard let chartView = chartView else {
            return
        }
        let start = 1
        
        let yVals = (start..<start+count+1).map { (i) -> BarChartDataEntry in
            let mult = range + 1
            let val = Double(arc4random_uniform(mult))
            if arc4random_uniform(100) < 25 {
                return BarChartDataEntry(x: Double(i), y: val, icon: UIImage(named: "icon"))
            } else {
                return BarChartDataEntry(x: Double(i), y: val)
            }
        }
        
        var set1: BarChartDataSet! = nil
        if let set = chartView.data?.dataSets.first as? BarChartDataSet {
            set1 = set
            set1.values = yVals
            chartView.data?.notifyDataChanged()
            chartView.notifyDataSetChanged()
        } else {
            set1 = BarChartDataSet(values: yVals, label: "The year 2017")
            set1.colors = ChartColorTemplates.material()
            set1.drawValuesEnabled = false
            
            let data = BarChartData(dataSet: set1)
            data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
            data.barWidth = 0.9
            chartView.data = data
        }
        
        //        chartView.setNeedsDisplay()
    }
    func updateFlow(_ flow:NetFlow) {
        updateChartData()
    }
}
