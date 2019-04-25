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
        XCTAssertEqual(JugController.solveFor(x: 1, y: 1, z: 1).first?.description, "Fill x")
        XCTAssertEqual(JugController.solveFor(x: 1, y: 2, z: 2).first?.description, "Fill y")
        XCTAssertEqual(JugController.solveFor(x: 2, y: 3, z: 4).description, "No Solution")
    }
    
    func testMutualPrimes() {
        XCTAssertNil(JugController.solveFor(x: 2, y: 4, z: 1).first, "There should be no solution.")
        XCTAssertEqual(JugController.solveFor(x: 6, y: 3, z: 5).description, "No Solution")
    }
    
    static let NoSolutions: [(x: Int, y: Int, z: Int)] = [
        (0, 2, 0), (0, 2, 0), (2, 0, 0), (-2, 13, 10), (-1, -1, -1), (0, 0, 0)
    ]
    
    func testNoSolutions() {
        WaterJugChallengeTests.NoSolutions.forEach { p in
            let controller = JugController(x: p.x, y: p.y, z: p.z)
            controller.solve()
            XCTAssertNil(controller.steps.first, "There should be no solution.")
        }
    }
    
    static let WithSolutions: [String : (x: Int, y: Int, z: Int)] = [
        "Fill x\nTransfer x, y" : (3, 2, 1),
        "Fill y\nTransfer y, x\nEmpty x\nTransfer y, x\nFill y\nTransfer y, x\nEmpty x\nTransfer y, x\nFill y\nTransfer y, x\nEmpty x\nTransfer y, x\nEmpty x\nTransfer y, x\nFill y\nTransfer y, x" : (5, 7, 3),
        "Fill x\nTransfer x, y\nEmpty y\nTransfer x, y\nFill x\nTransfer x, y\nEmpty y\nTransfer x, y\nFill x\nTransfer x, y\nEmpty y\nTransfer x, y\nEmpty y\nTransfer x, y\nFill x\nTransfer x, y" : (7, 5, 3),
        "Fill y\nTransfer y, x\nEmpty x\nTransfer y, x\nFill y\nTransfer y, x\nEmpty x\nTransfer y, x\nEmpty x\nTransfer y, x\nFill y\nTransfer y, x\nEmpty x\nTransfer y, x\nFill y\nTransfer y, x\nEmpty x\nTransfer y, x\nEmpty x\nTransfer y, x\nFill y\nTransfer y, x\nEmpty x\nTransfer y, x\nEmpty x\nTransfer y, x\nFill y\nTransfer y, x\nEmpty x\nTransfer y, x\nFill y\nTransfer y, x\nEmpty x\nTransfer y, x\nEmpty x\nTransfer y, x\nFill y\nTransfer y, x" : (13, 21, 12),
        "Fill x\nTransfer x, y\nEmpty y\nTransfer x, y\nFill x\nTransfer x, y\nEmpty y\nTransfer x, y\nFill x\nTransfer x, y\nEmpty y\nTransfer x, y\nFill x\nTransfer x, y\nEmpty y\nTransfer x, y\nEmpty y\nTransfer x, y\nFill x\nTransfer x, y\nEmpty y\nTransfer x, y\nFill x\nTransfer x, y\nEmpty y\nTransfer x, y\nFill x\nTransfer x, y\nEmpty y\nTransfer x, y\nFill x\nTransfer x, y\nEmpty y\nTransfer x, y\nEmpty y\nTransfer x, y\nFill x\nTransfer x, y" : (33, 26, 11)
    ]
    
    func testWithSolutions() {
        WaterJugChallengeTests.WithSolutions.forEach { key, value in
            let controller = JugController(x: value.x, y: value.y, z: value.z)
            controller.solve()
            XCTAssertEqual(controller.steps.description, key)
        }
    }
    
}
