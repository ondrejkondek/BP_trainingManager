//
//  TimeTests.swift
//  TrainingManagerTests
//
//  Created by Ondrej Kondek on 10/04/2021.
//

import XCTest

class TimeTests: XCTestCase {
    
    func testTimeGetTimeFromSeconds(){
        let time = Time().getTimeFromSeconds(180, minretval: "seconds")
        
        XCTAssertEqual(time, "0h:3m:0s")
    }
    
    func testTimeGetTimeFromSeconds2(){
        let time = Time().getTimeFromSeconds(225, minretval: "seconds")
        
        XCTAssertEqual(time, "0h:3m:45s")
    }
    
    func testTimeGetTimeFromSeconds3(){
        let time = Time().getTimeFromSeconds(3605, minretval: "seconds")
        
        XCTAssertEqual(time, "1h:0m:5s")
    }
    
    func testTimeGetTimeFromSeconds4(){
        let time = Time().getTimeFromSeconds(190, minretval: "minutes")
        
        XCTAssertEqual(time, "3m")
    }
    
    func testTimeGetTimeFromSeconds5(){
        let time = Time().getTimeFromSeconds(7298, minretval: "minutes")
        
        XCTAssertEqual(time, "2h:1m")
    }
    
    func testTimeSecToHoursMinSec(){
        let time = Time().secToHoursMinSec(seconds: 3710)
        
        XCTAssertEqual(time.hours, 1)
        XCTAssertEqual(time.minutes, 1)
        XCTAssertEqual(time.seconds, 50)
    }
}

