//
//  JugViewModel.swift
//  WaterJugChallenge
//
//  Created by David Jackman on 4/28/19.
//  Copyright © 2019 David Jackman. All rights reserved.
//

import Foundation
import UIKit

class JugViewModel {

    static let ModelChanged = Notification.Name("ModelChanged")

    let controller: JugController
    var stepIndex = -1 {
        didSet {
            guard stepIndex < solution.count else { stepIndex -= 1; return }
            
            NotificationCenter.default.post(name: JugViewModel.ModelChanged, object: self)
        }
    }
    
    var hasMoreSteps: Bool {
        return stepIndex < solution.count - 1
    }
    
    var isAtBeginning: Bool {
        return stepIndex == -1
    }
    
    func advance() {
        stepIndex += 1
    }
    
    func retreat() {
        stepIndex -= 1
    }
    
    func reset() {
        stepIndex = -1
    }
    
    init(controller: JugController) {
        self.controller = controller
    }
    
    fileprivate var solution: JugTransaction.Solution {
        return controller.bestSolution
    }
    
    var solved: Bool {
        return solution.count > 0
    }
    
    var currentState: JugTransaction.State? {
        guard stepIndex >= 0, stepIndex < solution.count else { return nil }
        
        return solution[stepIndex].state
    }
    
    var xLabelText: String {
        if stepIndex == -1 || !solved {
            return solved ? "0/\(solution[0].state.x.capacity)" : "?/?"
        } else {
            guard let jug = currentState?.x else { return "?/?" }
            return "\(jug.contents)/\(jug.capacity)"
        }
    }
    
    var yLabelText: String {
        if stepIndex == -1 {
            return solved ? "0/\(solution[0].state.y.capacity)" : "?/?"
        } else {
            guard let jug = currentState?.y else { return "?/?" }
            return "\(jug.contents)/\(jug.capacity)"
        }
    }
    
    var actionLabelText: String {
        guard stepIndex >= 0 else { return solved ? "Solved!" : "No\nSolution" }
        guard stepIndex < solution.count else { return "Error" }
        switch solution[stepIndex].step {
        case .empty(let i):
            return "Empty \(i)"
            
        case .fill(let i):
            return "Fill \(i)"
            
        case .transfer(let ft):
            return "Transfer \(ft.from) to \(ft.to)"
        }
    }
    
    var stepLabelText: String {
        return "\(stepIndex + 1)/\(solution.count)"
    }
    
    var nextButtonIsEnabled: Bool {
        return solved && stepIndex + 1 < solution.count
    }
    
    var previousButtonInEnabled: Bool {
        return solved && stepIndex >= 0
    }
    
    var autoButtonIsEnabled: Bool {
        return solved
    }
    
    var xScale: CGFloat {
        guard let state = currentState, state.x.capacity > 0 else { return 0.0 }
        return CGFloat(state.x.contents)/CGFloat(state.x.capacity)
    }
    
    func xHeight(for height: CGFloat) -> CGFloat {
        return height * xScale
    }
    
    var yScale: CGFloat {
        guard let state = currentState, state.y.capacity > 0 else { return 0.0 }
        return CGFloat(state.y.contents)/CGFloat(state.y.capacity)
    }
    
    func yHeight(for height: CGFloat) -> CGFloat {
        return height * yScale
    }
}

