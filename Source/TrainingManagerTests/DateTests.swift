//
//  DateTests.swift
//  TrainingManagerTests
//
//  Created by Ondrej Kondek on 10/04/2021.
//

import XCTest

class DateTests: XCTestCase {
    
    func testDateGetXdaysAgoDate(){
        let date = Date().getXdaysAgoDate(daysAgo: 2) // yesterday
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let comp_date = Calendar.current.dateComponents([.year, .day, .month], from: date)
        let comp_yes = Calendar.current.dateComponents([.year, .day, .month], from: yesterday)
        
        XCTAssertEqual(comp_date.year, comp_yes.year)
        XCTAssertEqual(comp_date.month, comp_yes.month)
        XCTAssertEqual(comp_date.day, comp_yes.day)
    }
    
    func testDateGetDayTimes_Start(){
        let date = Date().getDayTimes(start: true, date: Date())
        let comp_date = Calendar.current.dateComponents([.hour, .minute], from: date)
        
        XCTAssertEqual(comp_date.hour, 0)
        XCTAssertEqual(comp_date.minute, 0)
    }
    
    func testDateGetDayTimes_End(){
        let date = Date().getDayTimes(start: false, date: Date())
        let comp_date = Calendar.current.dateComponents([.hour, .minute], from: date)
        
        XCTAssertEqual(comp_date.hour, 23)
        XCTAssertEqual(comp_date.minute, 59)
    }
    
    func testDateIsTodayTrue(){
        let date = Date().isToday()
        
        XCTAssertTrue(date)
    }
    
    func testDateIsTodayFalse(){
        let date = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let res = date.isToday()
        
        XCTAssertFalse(res)
    }
    
    func testDateHowManyDaysAgo(){
        let date = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        let res = date.howManyDaysAgo()
        
        XCTAssertEqual(res, 3)
    }
    
    func testDateHowManyDaysAgoToday(){
        let res = Date().howManyDaysAgo()
        
        XCTAssertEqual(res, 0)
    }
    
    func testDateGetDate(){
        let date = Date().getDate(year: 2012, month: 10, day: 10)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd:MM:yyyy HH:mm"
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        let date2 = formatter.date(from: "10:10:2012 00:00")
        
        XCTAssertEqual(date, date2)
    }
    
    func testDateSecondsDifference_1() {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd:MM:yyyy HH:mm"
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        
        let date1 = formatter.date(from: "20:5:2020 00:00")!
        let date2 = formatter.date(from: "20:5:2020 00:02")!
        
        let secs = date1.secondsDifference(to: date2)
        
        XCTAssertEqual(secs, 120)
    }
    
    func testDateSecondsDifference_2() {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd:MM:yyyy HH:mm"
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        
        let date1 = formatter.date(from: "20:5:2020 00:00")!
        let date2 = formatter.date(from: "20:5:2020 01:02")!
        
        let secs = date1.secondsDifference(to: date2)
        
        XCTAssertEqual(secs, 3720)
    }
    
    func testDateSecondsDifference_via2days() {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd:MM:yyyy HH:mm"
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        
        let date1 = formatter.date(from: "20:5:2020 00:01")!
        let date2 = formatter.date(from: "19:5:2020 23:59")!
        
        let secs = date1.secondsDifference(to: date2)
        
        XCTAssertEqual(secs, 120)
    }
    
    func testDateSecondsDifference_via2days_2() {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd:MM:yyyy HH:mm"
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        
        let date1 = formatter.date(from: "19:5:2020 23:59")!
        let date2 = formatter.date(from: "20:5:2020 00:01")!
        
        let secs = date1.secondsDifference(to: date2)
        
        XCTAssertEqual(secs, 120)
    }
    
    func testDateSecondsDifference_via3days_2() {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd:MM:yyyy HH:mm"
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        
        let date1 = formatter.date(from: "19:5:2020 23:59")!
        let date2 = formatter.date(from: "21:5:2020 00:01")!
        
        let secs = date1.secondsDifference(to: date2)
        
        XCTAssertEqual(secs, 3600 * 24 + 120)
    }
}
