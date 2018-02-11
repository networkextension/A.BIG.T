//
//  ChartsCell.swift
//  Surf
//
//  Created by abigt on 2017/6/29.
//  Copyright © 2017年 abigt. All rights reserved.
//

import UIKit
import Charts
import SFSocket
import XRuler

class ChartsView:UIView,ChartViewDelegate  {
    @IBOutlet  var chatView:LineChartView?
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func awakeFromNib(){
        if let c = chatView {
           // c.delegate = self
            
            c.chartDescription?.enabled = false
            c.dragEnabled = true
            c.setScaleEnabled(true)
            c.drawGridBackgroundEnabled = true
            c.pinchZoomEnabled = true
            c.backgroundColor = UIColor.init(white: 204/255.0, alpha: 1.0)
            
            let  l:Legend = c.legend;
            l.form = .line;
            l.font = UIFont.systemFont(ofSize: 11.0)// [UIFont fontWithName:@"HelveticaNeue-Light" size:11.f];
            l.textColor = UIColor.white;
            l.horizontalAlignment = .left;
            l.verticalAlignment = .bottom;
            l.orientation = .horizontal;
            l.drawInside = false;
            
            let xAxis:XAxis = c.xAxis;
            xAxis.labelFont = UIFont.systemFont(ofSize: 11.0)
            xAxis.labelTextColor = UIColor.white;
            xAxis.drawGridLinesEnabled = false;
            xAxis.drawAxisLineEnabled = false;
            xAxis.axisMaximum = 60
            
            let  leftAxis:YAxis = c.leftAxis;
            leftAxis.labelTextColor = UIColor.cyan
            leftAxis.axisMaximum = 50
            leftAxis.axisMinimum = 0.0;
            leftAxis.drawGridLinesEnabled = true;
            leftAxis.drawZeroLineEnabled = false;
            leftAxis.granularityEnabled = true;
            
//             let rightAxis:YAxis = c.rightAxis;
//            rightAxis.labelTextColor = UIColor.red;
//            rightAxis.axisMaximum = 900.0;
//            rightAxis.axisMinimum = -200.0;
//            rightAxis.drawGridLinesEnabled = false;
//            rightAxis.granularityEnabled = false;
            
//            _sliderX.value = 20.0;
//            _sliderY.value = 30.0;
       //    [self slidersValueChanged:nil];
         //   c.animate(xAxisDuration: 2.5)
            
        }
    }
    func updateFlow(_ flow:NetFlow) {
        let data = flow.flow(.total)
        self.update(data)
    }
    func update(_ data:[Double]){
        
        var yVals1:[ChartDataEntry] = []
        var index :Double = 0
        
        var unit = "KB/s"
        var sbq:Double = 1.0
        let rate = 1.2
         if let max = data.max() {
            
            
            
            
            if max < 1024{
                unit =  "B/s"
                sbq = 1
            }else if max >= 1024 && max < 1024*1024 {
                sbq = 1024.0
                unit =  "KB/s"
            }else if max >= 1024*1024 && max < 1024*1024*1024 {
                //return label + "\(x/1024/1024) MB" + s
                unit = "MB/s"
                sbq = 1024.0*1024.0
            }else {
                //return label + "\(x/1024/1024/1024) GB" + s
                unit =  "GB/s"
                sbq = 1024.0*1024.0*1024
            }
        }
        
        
        for i in data {
            let yy:Double = i / sbq
            
            let y = ChartDataEntry.init(x: index, y: yy)
            yVals1.append(y)
            index += 1
        }
        var set1:LineChartDataSet
        if let cc = chatView {
            
            let  leftAxis:YAxis = cc.leftAxis;
            leftAxis.labelTextColor = UIColor.cyan
            
            if let max = data.max() {
                
                leftAxis.axisMaximum  = max * rate/sbq
                
                
             
            }
            
            if let d = cc.data {
                if d.dataSetCount > 0 {
                    set1 = d.dataSets[0] as! LineChartDataSet
                    set1.values = yVals1
                    set1.label = unit
                    cc.data!.notifyDataChanged()
                    cc.notifyDataSetChanged()
                }
            }else {
               
               
                set1 = LineChartDataSet.init(values: yVals1, label: unit)
                set1.axisDependency = .left;
                set1.drawFilledEnabled = true
                set1.mode = .cubicBezier
                set1.drawValuesEnabled = false
                set1.setColor(UIColor.red)
                set1.setCircleColor(UIColor.white)
                set1.lineWidth = 2.0;
                set1.circleRadius = 3.0;
                set1.fillAlpha = 65/255.0;
                set1.drawCirclesEnabled = false
                set1.fillColor = UIColor.brown
                set1.highlightColor = UIColor.yellow
                set1.drawCircleHoleEnabled = false;
                
                let ids:[IChartDataSet] = [set1]
                let ldata:LineChartData = LineChartData.init(dataSets: ids)
                ldata.setValueTextColor(UIColor.white)
                ldata.setValueFont(UIFont.systemFont(ofSize: 9.0))
                cc.data = ldata
            }
        }
    }
}
