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
        struct Jug {
            enum Index {
                case x
                case y
            }
            
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
        case fill(JugTransaction.State.Jug.Index)
        case empty(JugTransaction.State.Jug.Index)
        case transfer((from: JugTransaction.State.Jug.Index, to: JugTransaction.State.Jug.Index))

        func output() {
            os_log(.default, log: oslog, "%@", "\(description)")
        }

    }

    let step: Step
    let state: State
    
    var description: String {
        return step.description
    }
    
    func output() {
        os_log(.default, log: oslog, "%@", description)
    }

}

extension JugTransaction.State {
    
    /**
     Returns the `Jug` corresponding to `index`
     
     - parameters:
        - index: A `Jug.Index` representing either `Jug` `x` or `Jug` `y`
    */
    subscript(index: Jug.Index) -> Jug {
        switch index {
        case .x:
            return x
        case .y:
            return y
        }
    }
    
    /**
     Index of the `Jug` with the largest capacity
    */
    var largest: Jug.Index {
        return x.capacity >= y.capacity ? .x : .y
    }
    
    /**
     Index of the `Jug` with the smallest capacity
     */
    var smallest: Jug.Index {
        return x.capacity < y.capacity ? .x : .y
    }
    
    /**
     Returns a `JugTransaction.Step` which advances the solution toward the finish
    */
    func nextStep(forward: Bool = true) -> JugTransaction.Step {
        let from    = forward ? largest : smallest
        let fromJug = self[from]
        let to      = forward ? smallest : largest
        let toJug   = self[to]
        
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
    
    /**
     Returns a new `JugTransaction.Step` by filling a `Jug` at `index`
    */
    func filling(at index: Jug.Index) -> JugTransaction.State {
        switch index {
        case .x:
            return JugTransaction.State(x: Jug(x.capacity, contents: x.capacity),
                                        y: Jug(y.capacity, contents: y.contents))
            
        case .y:
            return JugTransaction.State(x: Jug(x.capacity, contents: x.contents),
                                        y: Jug(y.capacity, contents: y.capacity))
            
        }
    }
    
    /**
     Returns a new `JugTransaction.Step` by emptying a `Jug` at `index`
     */
    func emptying(at index: Jug.Index) -> JugTransaction.State {
        switch index {
        case .x:
            return JugTransaction.State(x: Jug(x.capacity, contents: 0), y: y)
            
        case .y:
            return JugTransaction.State(x: x, y: Jug(y.capacity, contents: 0))
        }
    }
    
    /**
     Returns a new `JugTransaction.Step` by transfering until a limit is reached
            (either the target fills up or the source is emptied)
        from `Jug` `Index` at `from` to the `Jug` at `Index` `to`
     
     - parameters:
        - from: Source Index
        - to: Destination Index
     
     - returns:
        The newly created `State`
     */
    func transfering(_ from: Jug.Index,
                     _ to: Jug.Index) -> JugTransaction.State {
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
    
    /**
     Appends the step to the current solution
     
     - parameters:
         - step: the step to apply to the current state
     
     - returns:
        the step that was passed in
    */
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
        os_log(.default, log: oslog, "%@", "x: \(x.contents)/\(x.capacity) y: \(y.contents)/\(y.capacity)")
    }
    

}
