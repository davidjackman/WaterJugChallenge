//
//  WaterJugChallengeTests.swift
//  WaterJugChallengeTests
//
//  Created by David Jackman on 4/22/19.
//  Copyright © 2019 David Jackman. All rights reserved.
//

import XCTest
@testable import WaterJugChallenge

class WaterJugChallengeTests: XCTestCase {

    func testBasicCommands() {
        let controller = JugController(x: 3, y: 7, z: 5)
        
        controller.fill(at: .x)
        XCTAssertEqual(controller.state.x.contents, 3)
        
        controller.fill(at: .y)
        XCTAssertEqual(controller.state.y.contents, 7)
        
        controller.empty(at: .x)
        XCTAssertEqual(controller.state.x.contents, 0)
        
        controller.transfer(.y, .x)
        XCTAssertEqual(controller.state.x.contents, 3)
        XCTAssertEqual(controller.state.y.contents, 4)
    }
    
    func testSimpleCase() {
        var controller = JugController(x: 1, y: 1, z: 1)
        controller.solve()
        XCTAssertEqual(controller.bestSolution.first?.step.description, "Fill x")
        
        controller = JugController(x: 0, y: 3, z: 3)
        controller.solve()
        XCTAssertEqual(controller.bestSolution.first?.step.description, "Fill y")
        
        controller = JugController(x: 1, y: 2, z: 2)
        controller.solve()
        XCTAssertEqual(controller.bestSolution.first?.step.description, "Fill y")
        
        controller = JugController(x: 2, y: 3, z: 4)
        controller.solve()
        XCTAssertEqual(controller.bestSolution.description, "No Solution")
    }
    
    func testMutualPrimes() {
        var controller = JugController(x: 2, y: 4, z: 1)
        controller.solve()
         XCTAssertNil(controller.bestSolution.first, "There should be no solution.")
        
        controller = JugController(x: 6, y: 3, z: 5)
        controller.solve()
        XCTAssertEqual(controller.bestSolution.description, "No Solution")
    }
    
    static let NoSolutions: [(x: Int, y: Int, z: Int)] = [
        (-2, 13, 10),
        (-1, -1, -1),
    ]
    
    func testNoSolutions() {
        WaterJugChallengeTests.NoSolutions.forEach { p in
            let controller = JugController(x: p.x, y: p.y, z: p.z)
            controller.solve()
            XCTAssertNil(controller.bestSolution.first, "There should be no solution.")
        }
    }
    
    static let WithSolutions: [String : (x: Int, y: Int, z: Int)] = [
//        "Never Run this data set in the tests. It will crash xcode for obvious reasons" : (Int.max - 17, Int.max, 3),
        "Fill x\nTransfer x, y" : (3, 2, 1),
        "Fill x\nTransfer x, y\nFill x\nTransfer x, y" : (5, 7, 3),
        "Fill y\nTransfer y, x\nFill y\nTransfer y, x" : (7, 5, 3),
        "Fill x\nTransfer x, y\nFill x\nTransfer x, y\nEmpty y\nTransfer x, y\nFill x\nTransfer x, y\nFill x\nTransfer x, y\nEmpty y\nTransfer x, y\nFill x\nTransfer x, y\nEmpty y\nTransfer x, y\nFill x\nTransfer x, y\nFill x\nTransfer x, y\nEmpty y\nTransfer x, y\nFill x\nTransfer x, y\nFill x\nTransfer x, y" : (13, 21, 12),
        "Fill x\nTransfer x, y\nEmpty y\nTransfer x, y\nFill x\nTransfer x, y\nEmpty y\nTransfer x, y\nFill x\nTransfer x, y\nEmpty y\nTransfer x, y\nFill x\nTransfer x, y\nEmpty y\nTransfer x, y\nEmpty y\nTransfer x, y\nFill x\nTransfer x, y\nEmpty y\nTransfer x, y\nFill x\nTransfer x, y\nEmpty y\nTransfer x, y\nFill x\nTransfer x, y\nEmpty y\nTransfer x, y\nFill x\nTransfer x, y\nEmpty y\nTransfer x, y\nEmpty y\nTransfer x, y\nFill x\nTransfer x, y" : (33, 26, 11)
    ]
    
    func testWithSolutions() {
        WaterJugChallengeTests.WithSolutions.forEach { key, value in
            let controller = JugController(x: value.x, y: value.y, z: value.z)
            controller.solve()
            XCTAssertEqual(controller.bestSolution.description, key)
        }
    }
    
}
