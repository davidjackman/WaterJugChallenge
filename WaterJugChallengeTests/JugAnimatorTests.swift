//
//  JugAnimatorTests.swift
//  WaterJugChallengeTests
//
//  Created by David Jackman on 4/29/19.
//  Copyright © 2019 David Jackman. All rights reserved.
//

import XCTest
@testable import WaterJugChallenge

class JugAnimatorTests: XCTestCase {

    func testAnimatorBounds() {
        let controller = JugController(x: 8, y: 5, z: 3, solved: true)
        let animator   = JugViewModel(controller: controller)
        
        var modelChanged = false
        
        NotificationCenter.default.addObserver(forName: JugViewModel.ViewModelChanged, object: nil, queue: OperationQueue.main) { (note) in
            modelChanged = true
        }
        
        let ja = JugAnimator(viewModel: animator)
        XCTAssertTrue(ja.next())
        XCTAssertTrue(modelChanged)

        modelChanged = false
        XCTAssertTrue(ja.next())
        XCTAssertTrue(modelChanged)
        
        modelChanged = false
        XCTAssertFalse(ja.next())
        XCTAssertFalse(modelChanged)
        
        modelChanged = false
        XCTAssertTrue(ja.previous())
        XCTAssertTrue(modelChanged)
        
        modelChanged = false
        XCTAssertTrue(ja.previous())
        XCTAssertTrue(modelChanged)
        
        modelChanged = false
        XCTAssertFalse(ja.previous())
        XCTAssertFalse(modelChanged)
    }

}
