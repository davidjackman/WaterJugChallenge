//
//  JugAnimator.swift
//  WaterJugChallenge
//
//  Created by David Jackman on 4/28/19.
//  Copyright © 2019 David Jackman. All rights reserved.
//

import Foundation
import UIKit //TODO: Get rid of this dependency

//TODO: Implement this as a random access collection

class JugAnimator {
    let viewModel: JugViewModel
    
    /**
     Used to pace the animation of the solution.
     */
    var timer: Timer?
    
    var button: UIButton?
    
    
    init(viewModel: JugViewModel, button: UIButton) {
        self.viewModel = viewModel
        self.button = button
    }
    
    func toggleAnimation() {
        if button?.titleLabel?.text == "Auto Play Solution" {
            viewModel.reset()
        }
        
        if let t = timer {
            t.invalidate()
            timer = nil
            button?.setTitle("Continue Animating", for: .normal)
        }
            
        else {
            button?.setTitle("Stop Animating", for: .normal)
            
            timer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(nextFrame), userInfo: nil, repeats: true)
        }
        
    }
    
    /**
     Attempts to advance the animation or cancels the animation
    */
    @objc
    func nextFrame() {
        if !next() {
            timer?.invalidate()
            timer = nil
            button?.setTitle("Auto Play Solution", for: .normal)
        }
    }
    
    /**
     Updates the `stepIndex` to the next index
     */
    @discardableResult
    func next() -> Bool {
        if viewModel.hasMoreSteps { viewModel.advance(); return true }
        return false
    }
    
    /**
     Updates the `stepIndex` to the previous index
     */
    @discardableResult
    func previous() -> Bool {
        if !viewModel.isAtBeginning { viewModel.retreat(); return true }
        return false
    }
    
}

