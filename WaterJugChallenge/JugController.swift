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
    
    var next: JugStep {
        let largestJug = jug(for: largest)
        let smallestJug = jug(for: smallest)
        
        switch (largestJug.contents, smallestJug.contents) {
        case (0, 0):
            return .fill(largest)
            
        case (let i, _) where i == largestJug.capacity:
            return .transfer((largest, smallest))
            
        case (_, let j) where j == smallestJug.capacity:
            return .empty(smallest)
            
        case (_, 0):
            return .transfer((largest, smallest))
            
        case (0, _):
            return .fill(largest)
            
        default:
            return .transfer((largest, smallest))
        }
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
    
    var steps = Solution()
    var states = [JugState]()
    
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
    
    func fill(at index: JugIndex) {
        switch index {
        case .x:
            state = JugState(x: Jug(state.x.capacity, contents: state.x.capacity), y: Jug(state.y.capacity, contents: state.y.contents))
            
        case .y:
            state = JugState(x: Jug(state.x.capacity, contents: state.x.contents), y: Jug(state.y.capacity, contents: state.y.capacity))
        }
        
        steps.append(.fill(index))
        states.append(state)
    }
    
    func empty(at index: JugIndex) {
        switch index {
        case .x:
            state = JugState(x: Jug(state.x.capacity, contents: 0), y: state.y)
            
        case .y:
            state = JugState(x: state.x, y: Jug(state.y.capacity, contents: 0))
        }

        steps.append(.empty(index))
        states.append(state)
    }
    
    func transfer(_ from: JugIndex, _ to: JugIndex) {
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
        steps.append(.transfer((from, to)))
        states.append(state)
    }
    
    func canSolve(for n: Int) -> Bool {
        return state.x.capacity > 0
            && state.y.capacity > 0
            && n > 0
            && (state.x.capacity >= n || state.y.capacity >= n)
            && state.x.capacity.primeFactors.isDisjoint(with: state.y.capacity.primeFactors)
    }
    
    func solve() {
        guard canSolve(for: z) else { return }
        
        if state.x.capacity == z {
            fill(at: .x)
        } else if state.y.capacity == z {
            fill(at: .y)
        } else {
            while !has(amount: z) {
                switch state.next {
                case .fill(let i):
                    fill(at: i)
                    
                case .empty(let i):
                    empty(at: i)
                    
                case .transfer(let n):
                    transfer(n.from, n.to)

                }
                debugPrint()
            }
        }
        
    }
    
    func has(amount: Int) -> Bool {
        return [state.x.contents, state.y.contents].contains(amount)
    }
    
    func debugPrint() {
        print("Controller (\(state.x.contents)/\(state.x.capacity), \(state.y.contents)/\(state.y.capacity))")
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
