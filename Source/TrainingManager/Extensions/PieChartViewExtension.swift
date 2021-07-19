//
//  PieChartViewExtension.swift
//  TrainingManager
//
//  Created by Ondrej Kondek on 23/03/2021.
//

import Foundation
import Charts

// MARK: Functions for setting and customizing pieChartView
extension PieChartView {

    /// Sets static setting for pieChart - legend, hole radius, labels...
    func setStaticSettings() {
    
        self.holeRadiusPercent = 0
        self.transparentCircleColor = UIColor.clear
        self.highlightPerTapEnabled = false
        self.setLegend()
                
        self.drawEntryLabelsEnabled = false
    }
    
    /// Update the content of a pieChart
    /// - Parameter records: data for pieChart
    func updatePieChart(records: [Record]){
        
        let aggregatedData = self.aggregateData(records: records)
        let sports = aggregatedData.0
        let times = aggregatedData.1
        
        let dataSet = self.prepareDataSetForPieChart(elements: sports, values: times)
        self.customizePieChartDataSet(dataSet: dataSet)
   
        let pieChartData = PieChartData(dataSet: dataSet)

        let formatter = ShowPercentageValueFormatter(sum: times.reduce(0, +))
        pieChartData.setValueFormatter(formatter)
        
        self.data = pieChartData
        self.notifyDataSetChanged()
    }
    
    /// Customize pieChartDataSet - setting colors
    /// - Parameter dataSet: PieChartDataSet to be customized
    func customizePieChartDataSet(dataSet: PieChartDataSet) {

        dataSet.colors = [UIColor(red: 128/255, green: 0/255, blue: 0/255, alpha: 1),
                          UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1),
                          UIColor(red: 229/255, green: 207/255, blue: 152/255, alpha: 1),
                          UIColor(red: 65/255, green: 89/255, blue: 135/255, alpha: 1),
                          UIColor(red: 77/255, green: 56/255, blue: 105/255, alpha: 1),
                          UIColor(red: 26/255, green: 77/255, blue: 26/255, alpha: 1),
                          UIColor(red: 86/255, green: 66/255, blue: 61/255, alpha: 1)]
    }
    
    /// Prepare Data set for pieChart
    /// - Parameter elements: sports to be shown in pieChart - labels
    /// - Parameter values: time for each sport stored in elements
    func prepareDataSetForPieChart(elements: [Int], values: [Int]) -> PieChartDataSet{
        
        var dataEntries: [ChartDataEntry] = []
        let labels = self.getLabels(elements)
        
        for i in elements.indices {
        
            let dataEntry = PieChartDataEntry(value: Double(values[i]), label: labels[i], data: elements[i] as AnyObject)
            dataEntries.append(dataEntry)
        }

        let dataSet = PieChartDataSet(entries: dataEntries, label: nil)
        
        return dataSet
    }
    
    /// Makes a sum of values for each day
    /// - Parameter records: data to be aggregated
    /// - Returns: tuple of array of Int with sports and array of Int with values (time) for each sport
    func aggregateData(records: [Record]) -> ([Int], [Int]){
        
        var activitySums: [Int: Int] = [:]
        
        for record in records {
            let value = activitySums[Int(record.sport)] ?? 0
            activitySums[Int(record.sport)] = value + Int(record.time)
        }
        
        let sports = Array(activitySums.keys)
        let times = Array(activitySums.values)
        
        return (sports, times)
    }
    
    /// Sets a legend for the chart
    func setLegend() {
        let legend = self.legend
        legend.enabled = true
        legend.orientation = .horizontal
        legend.drawInside = false
        legend.font = UIFont(name: "Avenir Next", size: 13)!
    }
    
    /// Gets labels for pieChart
    /// - Parameter sports: IDs of sports from which the labels will be created
    /// - Returns: Array of String with sport names
    func getLabels(_ sports: [Int]) -> [String]{
        
        var array = [String]()
        for sport in sports {
            let label = SportType.sportsArray[sport].idName
            array.append(label ?? "")
        }
        return array
    }

}
