//
//  RecordInfo.swift
//  TrainingManager
//
//  Created by Ondrej Kondek on 06/03/2021.
//

import Foundation

struct Time {
    
    var hours: Int!
    var minutes: Int!
    var seconds: Int!
}

struct RecordInfo {
    
    var time: Time!
    var date: Date!
    var location: String!
    var notes: String!
}
