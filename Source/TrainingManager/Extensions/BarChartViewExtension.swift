//
//  BarChartViewExtension.swift
//  TrainingManager
//
//  Created by Ondrej Kondek on 05/03/2021.
//

import Foundation
import Charts

// MARK: Functions for setting and customizing barChartView
extension BarChartView {
    
    func customizeBarChart(){
        
        self.backgroundColor = UIColor.clear
        self.doubleTapToZoomEnabled = false
        self.dragEnabled = false
        self.highlightPerTapEnabled = false
        self.drawBarShadowEnabled = false
        self.drawValueAboveBarEnabled = false
        self.drawValueAboveBarEnabled = false
        
        let x = self.xAxis
        x.labelPosition = .bottom
        x.drawAxisLineEnabled = false
        x.granularity = 1
        x.drawGridLinesEnabled = false

        let rightY = self.rightAxis
        rightY.drawLabelsEnabled = false
        rightY.drawAxisLineEnabled = false
        rightY.axisMinimum = 0
        rightY.drawGridLinesEnabled = true
        rightY.granularity = 1
        
        let leftY = self.leftAxis
        leftY.drawAxisLineEnabled = false
        leftY.axisMinimum = 0
        leftY.drawGridLinesEnabled = false
        leftY.granularity = 1
    }
    
    /// Update the content of a barchart
    /// - Parameter records: data for barchart
    /// - Parameter interval: interval to be shown in graph (how many days)
    /// - Parameter days: number of days
    /// - Returns: string of time trained - sum of all records time
    func updateBarChart(records: [Record], interval: String, days: Int) -> String {
        
        self.setXlabels(interval: interval, labels: self.getLabels(interval: interval))
        
        let organizedData = self.organizeDataToDays(records, days: days)
        let result = self.aggregateData(organizedData)
        let aggregatedData = result.0
        let unit = result.1
        let barChartDataSet = self.prepareDataSetForBarChart(aggregatedData, unit: unit)
        
        let data = BarChartData(dataSet: barChartDataSet)
        
        if interval == "LAST WEEK"{
            data.barWidth = 0.7
        }
        else{
            data.barWidth = 0.8
        }
        
        self.data = data
        self.notifyDataSetChanged()
        
        let string = self.countTimeTrained(aggregatedData: aggregatedData, unit: unit)
        return string
    }
    
    /// Prepare Data set for Grouped barChart
    /// - Parameter meTimeOfFavSport: data - 1st bar
    /// - Parameter meTimeOfAllSports: data - 2nd bar
    /// - Parameter timeOfFavSport: data - 3rd bar
    /// - Parameter timeOfAllSports: data - 4th bar
    /// - Returns: string of time trained - sum of all records time
    func prepareDataSetForGroupBarChart(_ meTimeOfFavSport: Double, _ meTimeOfAllSports: Double, _ timeOfFavSport: Double, _ timeOfAllSports: Double) -> [BarChartDataSet]{
        
        var entries1 = [BarChartDataEntry]()
        var entries2 = [BarChartDataEntry]()
        
        entries2.append(BarChartDataEntry(x: 0.0, y: Double(meTimeOfFavSport)))
        entries2.append(BarChartDataEntry(x: 0.0, y: Double(timeOfFavSport)))
        entries1.append(BarChartDataEntry(x: 1.0, y: Double(meTimeOfAllSports)))
        entries1.append(BarChartDataEntry(x: 1.0, y: Double(timeOfAllSports)))
       
        let chartDataSet1 = BarChartDataSet(entries: entries1, label: "Overall")
        let chartDataSet2 = BarChartDataSet(entries: entries2, label: "Favourite sport")
        
        let dataSets: [BarChartDataSet] = [chartDataSet1, chartDataSet2]
        customizeBarChartDataSet(dataSets: dataSets)
        
        return dataSets
    }
    
    /// Prepare Data set for barChart
    /// - Parameter aggregatedData: data for dataSet
    /// - Parameter unit: 1 for minutes 0 for hours
    /// - Returns: barChartDataSet
    func prepareDataSetForBarChart(_ aggregatedData: [Double], unit: Int) -> BarChartDataSet{
        
        var entries = [BarChartDataEntry]()
        
        for idx in 0...(aggregatedData.count - 1){
            entries.append(BarChartDataEntry(x: Double(idx), y: Double(aggregatedData[idx])))
        }
        
        let set = BarChartDataSet(entries: entries)
        
        self.customizeBarChartDataSet(dataSet: set)
        self.setYlabels(unit: unit)
        
        return set
    }
    
    /// Customize barChartDataSet - setting colors and drawing values
    /// - Parameter dataSet: BarChartDataSet to be customized
    func customizeBarChartDataSet(dataSet: BarChartDataSet) {

        dataSet.colors = [UIColor(red: 128/255, green: 0/255, blue: 0/255, alpha: 1),
                          UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1),
                          UIColor(red: 229/255, green: 207/255, blue: 152/255, alpha: 1),
                          UIColor(red: 65/255, green: 89/255, blue: 135/255, alpha: 1),
                          UIColor(red: 77/255, green: 56/255, blue: 105/255, alpha: 1),
                          UIColor(red: 26/255, green: 77/255, blue: 26/255, alpha: 1),
                          UIColor(red: 86/255, green: 66/255, blue: 61/255, alpha: 1)]
        
        dataSet.drawValuesEnabled = false
    }
    
    /// Customize barChartDataSet for groupBarChart - setting colors and drawing values
    /// - Parameter dataSet: array of BarChartDataSet to be customized
    func customizeBarChartDataSet(dataSets: [BarChartDataSet]) {
        
        var first = true
        for dataSet in dataSets {
            if first {
                dataSet.colors = [UIColor(red: 128/255, green: 0/255, blue: 0/255, alpha: 1)]
                first = false
            }
            else{
                dataSet.colors = [UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1)]
            }
            dataSet.drawValuesEnabled = false
        }
    }
    
    /// Sets a legend for the chart
    func setLegend() {
        
        let legend = self.legend
        legend.enabled = true
        legend.orientation = .horizontal
        legend.drawInside = false
        legend.font = UIFont(name: "Avenir Next", size: 13)!
        legend.formSize = 13
        legend.xEntrySpace = 25
    }
    
    /// Sets the Y labels in barChart
    /// - Parameter unit: if 0 hours, else minutes
    func setYlabels(unit: Int) {
        
        let leftY = self.leftAxis
        if unit == 0 {
            leftY.valueFormatter = ShowHoursValueFormatter()
        }
        else {
            leftY.valueFormatter = ShowMinutesValueFormatter()
        }
    }
    
    /// Sets the X labels in barChart
    /// - Parameter interval: interval giving a number of days in barChart
    /// - Parameter labels: possible static labels
    func setXlabels(interval: String, labels: [String]){
        
        let x = self.xAxis
        
        if interval == "public" {
            let formatter = ShowUsersXAxisValueFormatter()
            formatter.labels = labels
            x.valueFormatter = formatter
            x.centerAxisLabelsEnabled = true
        }
        else if interval == "LAST WEEK" {
            x.valueFormatter = IndexAxisValueFormatter(values: labels)
        }
        else if interval == "LAST MONTH"{
            let formatter = ShowLastMonthValueFormatter(labels: labels)
            formatter.labels = labels
            x.valueFormatter = formatter
        }
        else if interval == "LAST 3 MONTHS" {
            let formatter = ShowLast3MonthsValueFormatter(labels: labels)
            formatter.labels = labels
            x.valueFormatter = formatter
        }
        else if interval == "LAST 6 MONTHS" {
            let formatter = ShowLast6MonthsValueFormatter(labels: labels)
            formatter.labels = labels
            x.valueFormatter = formatter
        }
        else if interval == "LAST YEAR" {
            let formatter = ShowLastYearValueFormatter(labels: labels)
            formatter.labels = labels
            x.valueFormatter = formatter
        }
        
    }
    
    /// Sets static setting for charts - legend, nodataText, ...
    /// - Parameter vc: type of barchart (names based on ViewControllers)
    func setStaticSettings(vc: String) {
        
        if vc == "Stats"{
            self.customizeBarChart()
            self.legend.enabled = false
            self.noDataText = "No User Activity This Week"
        }
        
        if vc == "Public"{
            self.customizeBarChart()
            self.setLegend()
            self.xAxis.labelFont = UIFont(name: "Avenir Next", size: 16)!
        }
    }
}

// MARK: Functions to prepare data for barChartView
extension BarChartView {
    
    /// Given data organized to array of arrays based on days
    /// ex. [[1,2,3],[2,1,3],[2,3,1]] - [1,2,3] is array for today, [2,1,3] for yesterday, etc.
    /// - Parameter rawData: array of records to be organized
    /// - Parameter days: number of days
    /// - Returns: Record array of arrays
    func organizeDataToDays(_ rawData: [Record], days: Int) -> [[Record]]{

        var items = [[Record]]()
        let calendar = Calendar.current
        
        for day in 0..<days {
            items.append([Record]())
            
            for i in 0..<rawData.count {
                
                let recordDate = rawData[Int(i)].date!
                let compRecordDate = calendar.dateComponents([.year, .day, .month], from: recordDate)

                let date = Calendar.current.date(byAdding: .day, value: -(day), to: Date())!
                let compDate = calendar.dateComponents([.year, .day, .month], from: date)
                if (compDate.year == compRecordDate.year) && (compDate.month == compRecordDate.month) && (compDate.day == compRecordDate.day){
                    items[day].append(rawData[i])
                }
            }
        }
        return items
    }
    
    /// Makes a sum of values for each day
    /// - Parameter data: array of arrays returned from organizeDataToDays()
    /// - Returns: tupple of array of sum for each day and unit according to maximum value
    func aggregateData(_ data: [[Record]]) -> ([Double], Int) {
        
        var items = [Double]()
        let days = data.count
        var unit = 1 // minutes
        var i = 0
        
        for idx in (0..<days).reversed() {
            
            items.append(Double())
            
            for record in data[idx] {
                items[i] += Double(record.time)
            }
            
            if items[i] > 80 * 60 {
                unit = 0 // hours
            }
            i += 1
        }
        
        // refactoring according to unit
        var idx = 0
        for item in items {
            if unit == 0 {
                items[idx] = item / 3600
            }
            else {
                items[idx] = item / 60
            }
            idx += 1
        }

        return (items, unit)
    }
}

// MARK: Labels and other helpful functions to work with charts
extension BarChartView {
    
    /// - Parameter interval: interval in which labels should be generated
    /// - Returns: array of strings - dates of certain interval
    func getLabels(interval: String) -> [String]{
        
        var array = [String]()
        
        if interval == "LAST MONTH" {
            for i in 0..<30 {
                let calendar = Calendar.current
                let today = calendar.date(byAdding: .day, value: -i, to: Date())!
                
                let dateFormatterPrint = DateFormatter()
                dateFormatterPrint.dateFormat = "dd MMM"

                let time = dateFormatterPrint.string(from: today)
                
                array.append(time)
                
            }
            return array.reversed()
        }
        else if interval == "LAST WEEK" {
            return Date().getDaysLabels()
        }
        else if interval == "LAST 3 MONTHS" {
            for i in 0..<90 {
                let calendar = Calendar.current
                let today = calendar.date(byAdding: .day, value: -i, to: Date())!
                
                let dateFormatterPrint = DateFormatter()
                dateFormatterPrint.dateFormat = "dd MMM"

                let time = dateFormatterPrint.string(from: today)
                
                array.append(time)
                
            }
            return array.reversed()
        }
        else if interval == "LAST 6 MONTHS" {
            for i in 0..<180 {
                let calendar = Calendar.current
                let today = calendar.date(byAdding: .day, value: -i, to: Date())!
                
                let dateFormatterPrint = DateFormatter()
                dateFormatterPrint.dateFormat = "dd MMM"

                let time = dateFormatterPrint.string(from: today)
                
                array.append(time)
                
            }
            return array.reversed()
        }
        else if interval == "LAST YEAR" {
            for i in 0..<365 {
                let calendar = Calendar.current
                let today = calendar.date(byAdding: .day, value: -i, to: Date())!
                
                let dateFormatterPrint = DateFormatter()
                dateFormatterPrint.dateFormat = "dd MMM"

                let time = dateFormatterPrint.string(from: today)
                
                array.append(time)
                
            }
            return array.reversed()
        }
     
        return []
    }
    
    /// - Parameter aggregatedData: array of values - times trained
    /// - Returns: String - time trained based on aggregated data
    func countTimeTrained(aggregatedData: [Double], unit: Int) -> String {
            
        let sum = aggregatedData.reduce(0, +)
        
        if unit == 0 {
            let hours = Int(sum) / 1
            let minutes = (Double(sum) - Double(hours)) * 60
            return "\(hours) hours and " + String(format: "%.0f", minutes) + " minutes"
        }
        else {
            return String(format: "%.0f", sum) + " minutes"
        }
    }
    
}
