//
//  ViewController.swift
//  WaterJugChallenge
//
//  Created by David Jackman on 4/22/19.
//  Copyright © 2019 David Jackman. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var yLabel: UILabel!
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var stepLabel: UILabel!
    
    @IBOutlet weak var xField: UITextField!
    @IBOutlet weak var yField: UITextField!
    @IBOutlet weak var zField: UITextField!
    
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var autoButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    
    @IBOutlet weak var xJugView: UIView!
    @IBOutlet weak var yJugView: UIView!
    @IBOutlet weak var xWaterView: UIView!
    @IBOutlet weak var yWaterView: UIView!
    
    @IBOutlet weak var xHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var yHeightConstraint: NSLayoutConstraint!
    
    /**
     Used to pace the animation of the solution.
     */
    var timer: Timer?
    
    var controller: JugController?
    
    /**
     Updating the `stepIndex` causes an animation to occur
    */
    var stepIndex = -1 {
        didSet {
            guard stepIndex >= 0 else { displayInitialResults(); return }
            updateDisplay()
        }
    }
    
    /**
     Attempts to find a solution to the values in the `TextField`s using a `JugController`
     which is stored in the instance property `controller`
     
     This resets the `stepIndex` to -1
     */
    @IBAction func go(_ sender: Any) {
        guard
            let xText = xField.text, let xValue = Int(xText),
            let yText = yField.text, let yValue = Int(yText),
            let zText = zField.text, let zValue = Int(zText) else { return }
        
        xField.resignFirstResponder()
        yField.resignFirstResponder()
        zField.resignFirstResponder()

        controller = JugController(x: xValue, y: yValue, z: zValue).solved()
        
        reset()
    }
    
    /**
     Toggles the automatic animation of the solution.

     This resets the animation if it had previously reached the end.

     - parameters:
        - sender: the button that invoked this method
     */
    @IBAction func auto(_ sender: UIButton) {
        if sender.titleLabel?.text == "Auto Play Solution" { reset() }
        
        if let t = timer {
            t.invalidate()
            timer = nil
            sender.setTitle("Continue Animating", for: .normal)
        } else {
            sender.setTitle("Stop Animating", for: .normal)
            
            timer = Timer.scheduledTimer(withTimeInterval: 0.75, repeats: true, block: { (t) in
                if self.stepIndex < self.controller?.bestSolution.count ?? 0 {
                    self.next(self)
                } else {
                    t.invalidate()
                    self.timer = nil
                    sender.setTitle("Auto Play Solution", for: .normal)
                }
            })
        }
    }
    
    /**
     Updates the `stepIndex` to the beginning
    */
    func reset() {
        stepIndex = -1
    }
    
    /**
     Updates the `stepIndex` to the next index
     */
    @IBAction func next(_ sender: Any) {
        stepIndex += 1
    }

    /**
     Updates the `stepIndex` to the previous index
     */
    @IBAction func previous(_ sender: Any) {
        stepIndex -= 1
    }
    
    /**
     Update the ui for the initial state
    */
    func displayInitialResults() {
        let solved = controller?.bestSolution.count != 0
        nextButton.isEnabled     = solved
        autoButton.isEnabled     = solved
        previousButton.isEnabled = false

        stepLabel.text   = "0/\(controller?.bestSolution.count ?? 0)"
        
        xLabel?.text     = solved ? "0/\(controller?.state.x.capacity ?? 0)" : "?/?"
        yLabel?.text     = solved ? "0/\(controller?.state.y.capacity ?? 0)" : "?/?"
        actionLabel.text = solved ? "Solved!" : "No\nSolution"
        
        self.xHeightConstraint.constant = 0
        self.yHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.25) {
            self.xJugView.layoutIfNeeded()
            self.yJugView.layoutIfNeeded()
        }

    }
    
    func updateDisplay() {
        guard let c = controller, c.bestSolution.count > stepIndex, c.bestSolution.count > stepIndex else { return }
        
        animateStep()
    }
}

extension ViewController {

    func animateStep() {
        
        func updateXYLabels() {
            guard let c = controller else { return }
            
            let state = c.bestSolution[stepIndex].state
            xLabel?.text = "\(state.x.contents)/\(state.x.capacity)"
            yLabel?.text = "\(state.y.contents)/\(state.y.capacity)"
        }
        
        func updateActionLabel() {
            guard let c = controller else { return }
            
            switch c.bestSolution[stepIndex].step {
            case .empty(let i):
                actionLabel?.text = "Empty \(i)"
                
            case .fill(let i):
                actionLabel?.text = "Fill \(i)"
                
            case .transfer(let ft):
                actionLabel?.text = "Transfer \(ft.from) to \(ft.to)"
                
            }
        }
        
        func updateStepLabel() {
            guard let c = controller else { return }
            
            stepLabel.text = "\(stepIndex + 1)/\(c.bestSolution.count)"
        }
        
        guard let c = controller else { return }
        
        let state = c.bestSolution[stepIndex].state
        
        nextButton.isEnabled     = false
        previousButton.isEnabled = false
        
        let xScale = CGFloat(state.x.contents)/CGFloat(state.x.capacity)
        let xHeight = xJugView.bounds.height * xScale
        self.xHeightConstraint.constant = xHeight
        
        let yScale = CGFloat(state.y.contents)/CGFloat(state.y.capacity)
        let yHeight = yJugView.bounds.height * yScale
        self.yHeightConstraint.constant = yHeight
        
        UIView.animate(withDuration: 0.25, animations: {
            self.xJugView.layoutIfNeeded()
            self.yJugView.layoutIfNeeded()
            
            updateStepLabel()
            updateActionLabel()
            updateXYLabels()
        }) { (_) in
            self.nextButton.isEnabled     = self.stepIndex + 1 < c.bestSolution.count
            self.previousButton.isEnabled = self.stepIndex >= 0
        }
    }

}

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
