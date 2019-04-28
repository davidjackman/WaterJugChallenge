//
//  JugState.swift
//  WaterJugChallenge
//
//  Created by David Jackman on 4/27/19.
//  Copyright © 2019 David Jackman. All rights reserved.
//

import Foundation
import os.log

struct JugTransaction {
    typealias Solution = [JugTransaction]
    
    struct State {
        enum Index {
            case x
            case y
        }
        
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
        
        var x: Jug
        var y: Jug
        
        init(x: Jug, y: Jug) {
            self.x = x
            self.y = y
        }
        
    }
    
    enum Step {
        case fill(JugTransaction.State.Index)
        case empty(JugTransaction.State.Index)
        case transfer((from: JugTransaction.State.Index, to: JugTransaction.State.Index))

        func output() {
            os_log(.default,
                   log: OSLog(subsystem: "net.davidjackman.WaterJugChallenge",
                              category: "Solution"),
                   "%@", "\(description)")
        }

    }

    let step: Step
    let state: State
    
    var description: String {
        return step.description
    }
    
    func output() {
        os_log(.default,
               log: OSLog(subsystem: "net.davidjackman.WaterJugChallenge",
                          category: "Solution"),
               "%@", description)
    }

}

extension JugTransaction.State {
    
    subscript(index: Index) -> Jug {
        switch index {
        case .x:
            return x
        case .y:
            return y
        }
    }
    
    func jug(for index: Index) -> Jug {
        return self[index]
    }
    
    var largest: Index {
        return x.capacity >= y.capacity ? .x : .y
    }
    
    var smallest: Index {
        return x.capacity < y.capacity ? .x : .y
    }
    
    func next(forward: Bool = true) -> JugTransaction.Step {
        let from    = forward ? largest : smallest
        let fromJug = jug(for: from)
        let to      = forward ? smallest : largest
        let toJug   = jug(for: to)
        
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
    
    func filling(at index: Index) -> JugTransaction.State {
        switch index {
        case .x:
            return JugTransaction.State(x: Jug(x.capacity, contents: x.capacity),
                                        y: Jug(y.capacity, contents: y.contents))
            
        case .y:
            return JugTransaction.State(x: Jug(x.capacity, contents: x.contents),
                                        y: Jug(y.capacity, contents: y.capacity))
            
        }
    }
    
    func emptying(at index: Index) -> JugTransaction.State {
        switch index {
        case .x:
            return JugTransaction.State(x: Jug(x.capacity, contents: 0), y: y)
            
        case .y:
            return JugTransaction.State(x: x, y: Jug(y.capacity, contents: 0))
        }
    }
    
    func transfering(_ from: JugTransaction.State.Index,
                     _ to: JugTransaction.State.Index) -> JugTransaction.State {
        let f = self[from]
        let t = self[to]
        
        if t.isFull { fatalError() }
        if f.isEmpty { fatalError() }
        
        let space = t.capacity - t.contents
        
        if space >= f.contents {
            switch from {
            case .x:
                return JugTransaction.State(x: Jug(x.capacity, contents: 0),
                                            y: Jug(y.capacity, contents: y.contents + x.contents))
                
            case .y:
                return JugTransaction.State(x: Jug(x.capacity, contents: x.contents + y.contents),
                                            y: Jug(y.capacity, contents: 0))
            }
        } else {
            switch from {
            case .x:
                return JugTransaction.State(x: Jug(x.capacity, contents: x.contents - space),
                                            y: Jug(y.capacity, contents: y.capacity))
                
            case .y:
                return JugTransaction.State(x: Jug(x.capacity, contents: x.capacity),
                                            y: Jug(y.capacity, contents: y.contents - space))
            }
        }
        
    }
    
    func transactionApplyingStep(_ step: JugTransaction.Step) -> JugTransaction {
        step.output()
        let state: JugTransaction.State
        
        switch step {
        case .fill(let i):
            state = filling(at: i)
            
        case .empty(let i):
            state = emptying(at: i)
            
        case .transfer(let fromTo):
            state = transfering(fromTo.from, fromTo.to)
        }
        
        return JugTransaction(step: step, state: state)
    }
    
    func output() {
        os_log(.default, log: OSLog(subsystem: "net.davidjackman.WaterJugChallenge", category: "Solution"), "%@", "x: \(x.contents)/\(x.capacity) y: \(y.contents)/\(y.capacity)")
    }
    

}
