//
//  WaterJugController.swift
//  WaterJugChallenge
//
//  Created by David Jackman on 4/22/19.
//  Copyright © 2019 David Jackman. All rights reserved.
//

import Foundation
import os.log

class JugController {
    
    var state: JugTransaction.State
    let z: Int
    
    var forwardSolution = JugTransaction.Solution()
    var backwardSolution = JugTransaction.Solution()
    
    init(x: Int, y: Int, z: Int) {
        self.state = JugTransaction.State(x: JugTransaction.State.Jug(x), y: JugTransaction.State.Jug(y))
        self.z = z
    }
    
    /**
     The best solution is the shortest. so we return the shorted `JugTransaction.Solution`
    */
    var bestSolution: JugTransaction.Solution {
        if backwardSolution.count > 0 && backwardSolution.count < forwardSolution.count {
            return backwardSolution
        }
        return forwardSolution
    }
    
    /**
     Append `transaction` to list coresponding to the direction indicated by the boolean input `forward`.
     
     - parameters:
        - transaction: the `JugTransaction` to append to coresponding list
        - forward: direction for this solution as Bool

     - returns:
        The inserted `transaction`
     */
    @discardableResult
    func appendTransaction(_ transaction: JugTransaction, forward: Bool = true) -> JugTransaction {
        if forward {
            forwardSolution.append(transaction)
        } else {
            backwardSolution.append(transaction)
        }
        return transaction
    }
    
    /**
     Fill the `Jug` at index
     
     - parameters:
        - index: The index of the `Jug` to be filled
        - forward: direction for this solution as Bool
     */
    func fill(at index: JugTransaction.State.Index, forward: Bool = true) {
        state = appendTransaction(state.transactionApplyingStep(.fill(index)), forward: forward)
            .state
        state.output()
    }
    
    /**
     Empty the `Jug` at index
     
     - parameters:
        - index: The index of the `Jug` to be filled
        - forward: direction for this solution as Bool
     */
    func empty(at index: JugTransaction.State.Index, forward: Bool = true) {
        state = appendTransaction(state.transactionApplyingStep(.empty(index)), forward: forward)
            .state
        state.output()
    }
    
    /**
     Transfer the contents of `Jug` at index `from` to `Jug` at `to`
     
     - parameters:
        - from: The index source `Jug`
        - to: The index of destination `Jug`
        - forward: direction for this solution as Bool
     */
    func transfer(_ from: JugTransaction.State.Index, _ to: JugTransaction.State.Index, forward: Bool = true) {
        state = appendTransaction(state.transactionApplyingStep(.transfer((from, to))), forward: forward)
            .state
        state.output()
    }
    
    /**
     Convenient Method for asking the state if we can solve for a target `n`
    */
    func canSolve(for n: Int) -> Bool {
        return state.canSolve(for: n)
    }
    
    /**
     In order to solve, we check for some terminal conditions:
        - are we solving for zero?
        - do we have a `Jug` with the same capacituy as the target volume?
        - is it possible to solve?
     
     Next we run a solution in each direction.
     
     This is not currently optimized to stop when a best solution is known,
        although that would be easy to add.
     
     Once solve completes the user can access `bestSolution`
    */
    func solve() {
        os_log(.default, log: oslog, "%@", "Solving for x: \(state.x.capacity) y: \(state.y.capacity) z: \(z)")
        
        if state.x.capacity == z && z >= 0 {
            fill(at: .x)
            return
        } else if state.y.capacity == z && z >= 0 {
            fill(at: .y)
            return
        } else {
            guard canSolve(for: z) else { return }
            
            [true, false].forEach { [weak self] (forward) in
                os_log(.default, log: OSLog(subsystem: "net.davidjackman.WaterJugChallenge", category: "Solution"), "%@", forward ? "FORWARD:\n=======" : "BACKWARD\n=========")
                self?.state = JugTransaction.State(x: JugTransaction.State.Jug(state.x.capacity), y: JugTransaction.State.Jug(state.y.capacity))
                
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
        
        os_log(.default, log: OSLog(subsystem: "net.davidjackman.WaterJugChallenge", category: "Solution"), "%@", "Forward Steps: \(forwardSolution.count)  BackwardSteps: \(backwardSolution.count)")

    }
    
    func solved() -> JugController {
        solve()
        return self
    }
    
    /**
     Test current state for having the solution for `amount` in one of its `Jug` `contents`
     
     - parameters:
        - amount: The amount which will solve the puzzle
     
     - returns:
        `Bool` indicating the presence of the exact `amount`
    */
    func has(amount: Int) -> Bool {
        return [state.x.contents, state.y.contents].contains(amount)
    }
        
}

extension JugTransaction.State {

    /**
     - parameters:
        - n: The target value
     
     - returns:
        `Bool` indicating the solvability of the current `Jug`s' `capacity` values in relation to `n`
     */
    func canSolve(for n: Int) -> Bool {
        return n > 0
            && x.capacity > 0
            && y.capacity > 0
            && (x.capacity >= n || y.capacity >= n)
            && x.capacity.primeFactors.isDisjoint(with: y.capacity.primeFactors)
    }

}

extension JugTransaction.Step {
    
    /**
     User Friendly String representing the `JugTransaction.Step`
    */
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

extension JugTransaction.Solution {
    
    /**
     User Friendly String representing the `JugTransaction.Solution`
     
     this is a concatenated descrition of the steps
     */
    var description: String {
        guard self.count > 0 else { return "No Solution" }
        return self.map { $0.step.description }.joined(separator: "\n")
    }
    
}

extension Int {
    
    /**
     Unique prime factors of the given `Int`
    */
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
    
    /**
     Is the `Int` prime?
    */
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

