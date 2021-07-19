//
//  TrainingManagerTests.swift
//  TrainingManagerTests
//
//  Created by Ondrej Kondek on 09/04/2021.
//

import XCTest

class IntervalTests: XCTestCase {

    func testIntervalNext(){
        let interval = Interval(actualInterval: 3)
        interval.next()
        
        XCTAssertEqual(interval.getInterval().1, 365)
    }
    
    func testIntervalPrevious(){
        let interval = Interval(actualInterval: 3)
        interval.previous()
        
        XCTAssertEqual(interval.getInterval().1, 30)
    }
    
    func testIntervalCheckOverflow(){
        let interval = Interval(actualInterval: 3)
        for _ in 0...10{
            interval.next()
        }
        
        XCTAssertEqual(interval.getInterval().1, 365)
    }
}
