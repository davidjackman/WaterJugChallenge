//
//  WaterJugController.swift
//  WaterJugChallenge
//
//  Created by David Jackman on 4/22/19.
//  Copyright © 2019 David Jackman. All rights reserved.
//

import Foundation

struct Jug {
    let capacity: Int
    var contents: Int = 0
    
    init(_ capacity: Int, contents: Int = 0) {
        self.capacity = capacity
        self.contents = contents
    }
    
    var isFull: Bool {
        return contents == capacity
    }
    
    var isEmpty: Bool {
        return contents == 0
    }
    
}

typealias Solution = [JugStep]

extension Solution {
    
    var description: String {
        guard self.count > 0 else { return "No Solution" }
        return self.map { $0.description }.joined(separator: "\n")
    }
    
}

struct JugState {
    var x: Jug
    var y: Jug
    
    init(x: Jug, y: Jug) {
        self.x = x
        self.y = y
    }
    
    func jug(for index: JugIndex) -> Jug {
        switch index {
        case .x:
            return x
        case .y:
            return y
        }
    }
    
    var largest: JugIndex {
        return x.capacity >= y.capacity ? .x : .y
    }
    
    var smallest: JugIndex {
        return x.capacity < y.capacity ? .x : .y
    }
    
    func next(forward: Bool = true) -> JugStep {
        let from = forward ? largest : smallest
        let fromJug = jug(for: from)
        let to = forward ? smallest : largest
        let toJug = jug(for: to)
        
        switch (fromJug.contents, toJug.contents) {
        case (0, 0):
            return .fill(from)
            
        case (let i, _) where i == fromJug.capacity:
            return .transfer((from, to))
            
        case (_, let j) where j == toJug.capacity:
            return .empty(to)
            
        case (_, 0):
            return .transfer((from, to))
            
        case (0, _):
            return .fill(from)
            
        default:
            return .transfer((from, to))
        }
    }
    
    func output() {
        print("x: \(x.contents)/\(x.capacity) y: \(y.contents)/\(y.capacity)")
    }
}

enum JugIndex {
    case x
    case y
}

enum JugStep {
    
    case fill(JugIndex)
    case empty(JugIndex)
    case transfer((from: JugIndex, to: JugIndex))
    
}

extension JugStep {
    
    var description: String {
        switch self {
            
        case .fill(let i):
            return "Fill \(i)"
            
        case .empty(let i):
            return "Empty \(i)"
            
        case .transfer(let fromTo):
            return "Transfer \(fromTo.from), \(fromTo.to)"
            
        }
    }
    
}

class JugController {
    var state: JugState
    let z: Int
    
    var forwardSteps = Solution()
    var forwardStates = [JugState]()
    var backSteps = Solution()
    var backStates = [JugState]()

    var bestSteps: Solution {
        if backSteps.count > 0 && backSteps.count < forwardSteps.count {
            return backSteps
        }
        return forwardSteps
    }
    
    var bestStates: [JugState] {
        if backStates.count > 0 && backStates.count < forwardStates.count {
            return backStates
        }
        return forwardStates
    }
        
    init(x: Int, y: Int, z: Int) {
        self.state = JugState(x: Jug(x), y: Jug(y))
        self.z = z
    }
    
    func jug(at index: JugIndex) -> Jug {
        switch index {
        case .x:
            return state.x
        case .y:
            return state.y
        }
    }
    
    func fill(at index: JugIndex, forward: Bool = true) {
        print("Filling \(index)")
        state.output()
        
        switch index {
        case .x:
            state = JugState(x: Jug(state.x.capacity, contents: state.x.capacity), y: Jug(state.y.capacity, contents: state.y.contents))
            
        case .y:
            state = JugState(x: Jug(state.x.capacity, contents: state.x.contents), y: Jug(state.y.capacity, contents: state.y.capacity))
            
        }
        
        state.output()

        if forward {
            forwardSteps.append(.fill(index))
            forwardStates.append(state)
        } else {
            backSteps.append(.fill(index))
            backStates.append(state)
        }
    }
    
    func empty(at index: JugIndex, forward: Bool = true) {
        print("Emptying \(index)")
        state.output()
        
        switch index {
        case .x:
            state = JugState(x: Jug(state.x.capacity, contents: 0), y: state.y)
            
        case .y:
            state = JugState(x: state.x, y: Jug(state.y.capacity, contents: 0))
        }
        
        state.output()

        if forward {
            forwardSteps.append(.empty(index))
            forwardStates.append(state)
        } else {
            backSteps.append(.empty(index))
            backStates.append(state)
        }
    }
    
    func transfer(_ from: JugIndex, _ to: JugIndex, forward: Bool = true) {
        print("Transfering \(from), \(to)")
        state.output()

        let f = jug(at: from)
        let t = jug(at: to)
        
        if t.isFull { return }
        if f.isEmpty { return }
        
        let space = t.capacity - t.contents
        
        if space >= f.contents {
            switch from {
            case .x:
                state = JugState(x: Jug(state.x.capacity, contents: 0),
                                 y: Jug(state.y.capacity, contents: state.y.contents + state.x.contents))

            case .y:
                state = JugState(x: Jug(state.x.capacity, contents: state.x.contents + state.y.contents),
                                 y: Jug(state.y.capacity, contents: 0))
            }
        } else {
            switch from {
            case .x:
                let fromContents = state.x.contents - space
                state = JugState(x: Jug(state.x.capacity, contents: fromContents),
                                 y: Jug(state.y.capacity, contents: state.y.capacity))
                
            case .y:
                let fromContents = state.y.contents - space
                state = JugState(x: Jug(state.x.capacity, contents: state.x.capacity),
                                 y: Jug(state.y.capacity, contents: fromContents))
            }
        }

        state.output()

        if forward {
            forwardSteps.append(.transfer((from, to)))
            forwardStates.append(state)
        } else {
            backSteps.append(.transfer((from, to)))
            backStates.append(state)
        }
    }
    
    func canSolve(for n: Int) -> Bool {
        return state.x.capacity > 0
            && state.y.capacity > 0
            && n > 0
            && (state.x.capacity >= n || state.y.capacity >= n)
            && state.x.capacity.primeFactors.isDisjoint(with: state.y.capacity.primeFactors)
    }
    
    func solve() {
        print("Solving for x: \(state.x.capacity) y: \(state.y.capacity) z: \(z)")
        if state.x.capacity == z && z >= 0 {
            fill(at: .x)
            return
        } else if state.y.capacity == z && z >= 0 {
            fill(at: .y)
            return
        } else {
            guard canSolve(for: z) else { return }
            [true, false].forEach { (forward) in
                print(forward ? "FORWARD:\n=======" : "BACKWARD\n=========")
                self.state = JugState(x: Jug(state.x.capacity), y: Jug(state.y.capacity))
                while !has(amount: z) {
                    
                    switch state.next(forward: forward) {
                        
                    case .fill(let i):
                        fill(at: i, forward: forward)
                        
                    case .empty(let i):
                        empty(at: i, forward: forward)
                        
                    case .transfer(let n):
                        transfer(n.from, n.to, forward: forward)
                        
                    }
                }
            }
        }
        
        print("Forward Steps: \(forwardSteps.count)  BackwardSteps: \(backSteps.count)")
        
//        if backSteps.count > 0 && backSteps.count < forwardSteps.count {
//            forwardSteps = backSteps
//            forwardStates = backStates
//        }
    }
    
    func has(amount: Int) -> Bool {
        return [state.x.contents, state.y.contents].contains(amount)
    }
        
}

extension Int {
    
    var primeFactors: Set<Int> {
        guard self > 0 else { return [] }
        
        var result = Set<Int>()
        
        var n = self
        while n % 2 == 0, n > 1 {
            n /= 2
            result.insert(2)
        }
        
        let root = Int(sqrt(Double(n)))
        if root > 3 {
            for i in 3...root {
                while n % i == 0, n > i {
                    result.insert(i)
                    n /= i
                }
            }
        }
        
        if n > 2 { result.insert(n) }
        
        return result
    }
    
    var isPrime: Bool {
        if self <= 3 { return self > 1 }
        else if self % 2 == 0 || self % 3 == 0 { return false }
        
        var i = 5
        
        while i * i <= self {
            if self % i == 0 || self % (i + 2) == 0 { return false }
            i += 6
        }
        return true
    }
    
}
