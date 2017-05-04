//
//  TimeTester.swift
//  Numerical2
//
//  Created by Andrew Clark on 3/05/2017.
//  Copyright © 2017 Very Tiny Machines. All rights reserved.
//

import UIKit

class TimeTester {
    
    static let shared = TimeTester()
    fileprivate init() {}
    
    var startTime:Int64 = 0
    
    func startTimeTester() {
        startTime = self.currentTimeMillis()
    }
    
    func printTime(string: String) {
        let readyTime = self.currentTimeMillis()
        let readyTimeDelta = readyTime - startTime
        //print("\(string) - \(readyTimeDelta)")
    }
    
    func currentTimeMillis() -> Int64 {
        let nowDouble = Date().timeIntervalSince1970
        return Int64(nowDouble*1000)
    }
    
}
