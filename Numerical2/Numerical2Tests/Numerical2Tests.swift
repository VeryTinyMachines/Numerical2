//
//  Numerical2Tests.swift
//  Numerical2Tests
//
//  Created by Andrew J Clark on 31/07/2015.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import XCTest

class Numerical2Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
        
        
        XCTAssertEqual(CalculatorBrain().solveString("1+2"), "3")
        XCTAssertEqual(CalculatorBrain().solveString("1-2"), "-1")
        XCTAssertEqual(CalculatorBrain().solveString("1*2"), "2")
        XCTAssertEqual(CalculatorBrain().solveString("1/2"), "0.5")
        XCTAssertEqual(CalculatorBrain().solveString("1^2"), "1")
        
        XCTAssertEqual(CalculatorBrain().solveString("7+25"), "32")
        XCTAssertEqual(CalculatorBrain().solveString("7-25"), "-18")
        XCTAssertEqual(CalculatorBrain().solveString("7*25"), "175")
        XCTAssertEqual(CalculatorBrain().solveString("7/25"), "0.28")
        XCTAssertEqual(CalculatorBrain().solveString("7^25"), "1341068619663964900807")
        
        
        XCTAssertEqual(CalculatorBrain().solveString("((10+20)-(30*40)/50)^6"), "46656")
        XCTAssertEqual(CalculatorBrain().solveString("----10----9---7---5---4---2---1"), "0")
        XCTAssertEqual(CalculatorBrain().solveString("(2^3)^4"), "4096")
        XCTAssertEqual(CalculatorBrain().solveString("10!"), "3628800")
        
        XCTAssertEqual(CalculatorBrain().solveString("20+5%"), "21")
        XCTAssertEqual(CalculatorBrain().solveString("20-5%"), "19")
        XCTAssertEqual(CalculatorBrain().solveString("20*5%"), "1")
        XCTAssertEqual(CalculatorBrain().solveString("20/5%"), "400")
        
        
        
    }
    
}
